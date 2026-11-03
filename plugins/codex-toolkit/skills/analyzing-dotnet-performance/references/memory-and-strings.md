> Read the parent SKILL.md first. Patterns and severity labels below are review candidates, not automatic findings. Preserve semantics and verify framework support; upstream example timings are not measurements of this workload.

# Memory & String Patterns

### Use ReadOnlySpan\<byte\> for Constant Byte Data
🟡 **DO** assign constant byte arrays to `ReadOnlySpan<byte>` | .NET 5+

❌
```csharp
byte[] data = new byte[] { 0x48, 0x65, 0x6C, 0x6C, 0x6F };
```
✅
```csharp
ReadOnlySpan<byte> data = [0x48, 0x65, 0x6C, 0x6C, 0x6F];
ReadOnlySpan<int> primes = [2, 3, 5, 7, 11, 13];
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use stackalloc for Small Temporary Buffers
🟡 **DO** use `stackalloc` for small, fixed-size temporary buffers | .NET Core+

❌
```csharp
char[] buffer = new char[64];
guid.TryFormat(buffer, out int written);
```
✅
```csharp
Span<char> buffer = stackalloc char[64];
guid.TryFormat(buffer, out int written);
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use Span.TryWrite for Allocation-Free Interpolation
🟡 **DO** use `MemoryExtensions.TryWrite` to format into `Span<char>` buffers | .NET 6+

❌
```csharp
string formatted = $"Date: {dt:R}";
destination.Write(formatted);
```
✅
```csharp
Span<char> buffer = stackalloc char[64];
buffer.TryWrite($"Date: {dt:R}", out int charsWritten);
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use Span.Split() for Zero-Allocation Splitting
🟡 **DO** use `MemoryExtensions.Split` for allocation-free string splitting | .NET 9+

❌
```csharp
string[] parts = input.Split(',');
```
✅
```csharp
foreach (Range range in input.AsSpan().Split(','))
{
    ReadOnlySpan<char> segment = input.AsSpan(range);
}
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use UTF8 String Literals (u8 suffix)
🟡 **DO** use the `u8` suffix for compile-time UTF8 `ReadOnlySpan<byte>` | .NET 7+

❌
```csharp
byte[] header = Encoding.UTF8.GetBytes("Content-Type");
```
✅
```csharp
ReadOnlySpan<byte> header = "Content-Type"u8;
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use ReadOnlySpan\<char\> Pattern Matching with switch
🟡 **DO** use `switch` on `ReadOnlySpan<char>` for allocation-free string matching | C# 11+

❌
```csharp
switch (attr.Value.Trim()) { case "preserve": /* ... */ break; }
```
✅
```csharp
switch (attr.Value.AsSpan().Trim())
{
    case "preserve": return Preserve;
    case "default": return Default;
}
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use params ReadOnlySpan\<T\> to Eliminate Array Allocations
🟡 **DO** add `params ReadOnlySpan<T>` overloads to library methods | C# 13 / .NET 9+

❌
```csharp
public static void Log(params string[] messages) { /* ... */ }
Log("Starting", "Processing", "Done");
```
✅
```csharp
public static void Log(params ReadOnlySpan<string> messages) { /* ... */ }
Log("Starting", "Processing", "Done");
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Avoid Chained String-Returning Operations
🟡 **AVOID** chains of 3+ string-returning method calls that each allocate intermediates | .NET Core+

**Pattern 1: Chained .Replace() calls**

❌
```csharp
string result = input.Replace("a", "b").Replace("c", "d").Replace("e", "f");
```
✅
```csharp
var sb = new StringBuilder(input.Length);
// single pass replacing all patterns
```

**Pattern 2: Chained Regex.Replace() calls**

❌
```csharp
public static string Underscore(this string input) =>
    Regex3.Replace(Regex2.Replace(Regex1.Replace(input, "$1_$2"), "$1_$2"), "_").ToLower();
```
✅
```csharp
return string.Create(totalLength, state, (span, s) => { /* write directly */ });
```

**Pattern 3: += string concatenation in loops**

❌
```csharp
string result = "";
foreach (var part in parts)
    result += separator + part;
```
✅
```csharp
var sb = new StringBuilder();
foreach (var part in parts)
    sb.Append(separator).Append(part);
return sb.ToString();
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Cache char.ToString() for Known Character Sets
🟡 **DO** cache `char.ToString()` results when the set of characters is small and known | .NET Core+

❌
```csharp
return symbol.ToString();

foreach (var prefix in UnitPrefixes)
    input = input.Replace(prefix.Value.Name, prefix.Key.ToString());
```
✅
```csharp
private static readonly FrozenDictionary<char, string> s_charStrings =
    new Dictionary<char, string>
    {
        ['k'] = "k", ['M'] = "M", ['G'] = "G",
    }.ToFrozenDictionary();

return s_charStrings[symbol];
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Detection

Scan recipes for memory and string anti-patterns. Use these only as candidate search hints; inspect matches in context.

```bash
# .ToLower()/.ToUpper() without culture parameter (allocates + culture-sensitive)
grep -rn --include='*.cs' -E '\.(ToLower|ToUpper)\(\)' --exclude-dir=bin --exclude-dir=obj . | wc -l

# Chained .Replace( calls (3+ on one line — intermediate string allocations)
grep -rn --include='*.cs' '\.Replace(.*\.Replace(.*\.Replace(' --exclude-dir=bin --exclude-dir=obj . | wc -l

# params in method signatures (array allocation per call)
grep -rn --include='*.cs' 'params ' --exclude-dir=bin --exclude-dir=obj . | wc -l

# LINQ on strings — .All/.Any on IEnumerable<char> (replace with foreach loop)
grep -rn --include='*.cs' -E '\.(All|Any)\(char\.' --exclude-dir=bin --exclude-dir=obj . | wc -l
```

### Patterns Requiring Manual Review

- **Boxing via string.Format**: Can't determine argument types from grep — needs type analysis
- **`+=` string concatenation in loops**: `+=` matches all types (int, list, event, string) — needs type context to confirm string
- **`char.ToString()`**: Requires knowing the variable type is `char` — not reliably greppable
