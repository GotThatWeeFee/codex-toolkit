> Read the parent SKILL.md first. Patterns and severity labels below are review candidates, not automatic findings. Preserve semantics and verify framework support; upstream example timings are not measurements of this workload.

# Critical .NET Performance Anti-Patterns

17 patterns that cause deadlocks, order-of-magnitude regressions, or excessive allocations.

## Async / Tasks

### Never Block on Async (Sync-over-Async)
🔴 **AVOID** | .NET Core+

❌
```csharp
public string GetData()
    => GetDataAsync().Result;
```
✅
```csharp
public async Task<string> GetDataAsync()
    => await GetDataInternalAsync();
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Never Await a ValueTask Multiple Times
🔴 **AVOID** | .NET Core 2.1+

❌
```csharp
ValueTask<int> vt = SomeMethodAsync();
int a = await vt;
int b = await vt;
```
✅
```csharp
int result = await SomeMethodAsync();
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Memory / Allocation

### Use Span\<T\> / AsSpan Instead of Substring for Slicing
🔴 **DO** | .NET Core 2.1+

❌
```csharp
string sub = input.Substring(5, 10);
```
✅
```csharp
ReadOnlySpan<char> sub = input.AsSpan(5, 10);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use ArrayPool\<T\> for Temporary Buffers
🔴 **DO** | .NET Core+

❌
```csharp
byte[] buf = new byte[4096];
```
✅
```csharp
byte[] buf = ArrayPool<byte>.Shared.Rent(4096);
Process(buf);
ArrayPool<byte>.Shared.Return(buf);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Avoid stackalloc in Loops
🔴 **AVOID** | .NET 5+

❌
```csharp
for (int i = 0; i < 10_000; i++)
    Span<byte> buf = stackalloc byte[1024];
```
✅
```csharp
Span<byte> buf = stackalloc byte[1024];
for (int i = 0; i < 10_000; i++) { Process(buf); }
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Avoid Boxing Value Types
🔴 **AVOID** | .NET 6+

❌
```csharp
string s = string.Format("{0}.{1}", major, minor);
```
✅
```csharp
string s = $"{major}.{minor}";
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Strings

### Use StringComparison.Ordinal for Non-Linguistic Comparisons
🔴 **DO** | .NET Core+

❌
```csharp
bool found = text.IndexOf("Content-Type") >= 0;
```
✅
```csharp
bool found = text.Contains("Content-Type", StringComparison.Ordinal);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use AsSpan Instead of Substring
🔴 **DO** | .NET Core 2.1+

❌
```csharp
int val = int.Parse(str.Substring(5, 3));
```
✅
```csharp
int val = int.Parse(str.AsSpan(5, 3));
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Regular Expressions

### Use Source-Generated Regex [GeneratedRegex]
🔴 **ALWAYS** use `[GeneratedRegex]` for all static regex patterns | .NET 7+

❌
```csharp
private static readonly Regex s_re =
    new(@"\w+@\w+\.\w+", RegexOptions.Compiled);
```
✅
```csharp
[GeneratedRegex(@"\w+@\w+\.\w+")]
private static partial Regex EmailRegex();
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Avoid Nested Quantifiers (Catastrophic Backtracking)
🔴 **AVOID** | .NET Core+

❌
```csharp
var r = new Regex(@"^(\w+)+$");
```
✅
```csharp
var r = new Regex(@"^\w+$", RegexOptions.NonBacktracking);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use TryGetValue Instead of ContainsKey + Indexer
🔴 **DO** | .NET Core+

❌
```csharp
if (dict.ContainsKey(key))
    Use(dict[key]);
```
✅
```csharp
if (dict.TryGetValue(key, out var value))
    Use(value);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Avoid LINQ in Hot Paths
🔴 **AVOID** | .NET Core+

❌
```csharp
bool found = items.Any(x => x.Name == target);
```
✅
```csharp
bool found = false;
foreach (var item in items)
    if (item.Name == target) { found = true; break; }
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Don't Iterate IEnumerable Multiple Times
🔴 **AVOID** | .NET Core+

❌
```csharp
foreach (Type t in types) { Validate(t); }
_types = types.ToArray();
```
✅
```csharp
Type[] arr = types.ToArray();
foreach (Type t in arr) { Validate(t); }
_types = arr;
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## JSON Serialization

### Use System.Text.Json Source Generator
🔴 **DO** | .NET 6+

❌
```csharp
string json = JsonSerializer.Serialize(post);
```
✅
```csharp
[JsonSerializable(typeof(BlogPost))]
internal partial class AppJsonCtx : JsonSerializerContext { }
string json = JsonSerializer.Serialize(post, AppJsonCtx.Default.BlogPost);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Cache JsonSerializerOptions
🔴 **DO** | .NET 5+

❌
```csharp
JsonSerializer.Serialize(obj, new JsonSerializerOptions());
```
✅
```csharp
private static readonly JsonSerializerOptions s_opts = new();
JsonSerializer.Serialize(obj, s_opts);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Networking

### Reuse HttpClient Instances
🔴 **DO** | .NET Core 2.1+

❌
```csharp
using var client = new HttpClient();
await client.GetStringAsync(url);
```
✅
```csharp
private static readonly HttpClient s_http = new(new SocketsHttpHandler
{ PooledConnectionLifetime = TimeSpan.FromMinutes(5) });
await s_http.GetStringAsync(url);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## General

### Use SearchValues\<T\> for Repeated Set Searches
🔴 **DO** | .NET 8+

❌
```csharp
int pos = text.IndexOfAny("ABCDEF".ToCharArray());
```
✅
```csharp
private static readonly SearchValues<char> s_hex = SearchValues.Create("ABCDEF");
int pos = text.AsSpan().IndexOfAny(s_hex);
```
**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Detection

Scan recipes for critical anti-patterns. Use these as search hints; inspect matches before identifying issues.

```bash
# .IndexOf(string) without StringComparison (culture-aware, 2-3x slower)
grep -rn --include='*.cs' -E '\.IndexOf\("[^"]+"\)' --exclude-dir=bin --exclude-dir=obj . | wc -l

# .Substring( calls (allocates new string — consider AsSpan)
grep -rn --include='*.cs' '\.Substring(' --exclude-dir=bin --exclude-dir=obj . | wc -l

# .StartsWith/.EndsWith without StringComparison (culture-aware, 2-3x slower)
grep -rn --include='*.cs' -E '\.(StartsWith|EndsWith)\("[^"]+"\)' --exclude-dir=bin --exclude-dir=obj . | wc -l

# .Contains(string) without StringComparison — NOTE: will also match collection .Contains() calls; filter to string receivers
grep -rn --include='*.cs' -E '\.Contains\("[^"]+"\)' --exclude-dir=bin --exclude-dir=obj . | wc -l
```
