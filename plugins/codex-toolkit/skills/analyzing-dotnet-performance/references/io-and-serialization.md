> Read the parent SKILL.md first. Patterns and severity labels below are review candidates, not automatic findings. Preserve semantics and verify framework support; upstream example timings are not measurements of this workload.

# I/O, Serialization & General Patterns

### Use HttpCompletionOption.ResponseHeadersRead for Streaming
🟡 **DO** use `ResponseHeadersRead` when downloading large responses | .NET Core 3.0+

❌
```csharp
var response = await client.GetAsync(uri);
```
✅
```csharp
using var response = await client.GetAsync(uri, HttpCompletionOption.ResponseHeadersRead);
using var stream = await response.Content.ReadAsStreamAsync();
await stream.CopyToAsync(destinationStream);
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use Async FileStream Operations
🟡 **DO** use `FileStream` with `useAsync: true` for scalable file I/O | .NET 6+

❌
```csharp
using var fs = new FileStream(path, FileMode.Open);
```
✅
```csharp
await using var fs = new FileStream(path, FileMode.Open, FileAccess.Read,
    FileShare.Read, bufferSize: 4096, useAsync: true);

byte[] buffer = new byte[1024];
while (await fs.ReadAsync(buffer) != 0) { /* process */ }
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use Memory\<byte\> Overloads for Stream.ReadAsync/WriteAsync
🟡 **DO** use `Memory<byte>`-based stream overloads instead of `byte[]` overloads | .NET 5+

❌
```csharp
await stream.ReadAsync(buffer, 0, buffer.Length);
await stream.WriteAsync(buffer, 0, buffer.Length);
```
✅
```csharp
await stream.ReadAsync(buffer.AsMemory());
await stream.WriteAsync(buffer.AsMemory());
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use Span-Based TryFormat for Number Formatting
🟡 **DO** use `TryFormat` to format numbers into `Span<char>` buffers | .NET Core 2.1+

❌
```csharp
string formatted = value.ToString();
destination.Write(formatted);
```
✅
```csharp
Span<char> buffer = stackalloc char[20];
if (value.TryFormat(buffer, out int charsWritten))
    destination.Write(buffer[..charsWritten]);
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use static readonly for Runtime Devirtualization
🟡 **DO** store implementations in `static readonly` fields for JIT devirtualization | .NET Core 3.0+

❌
```csharp
private static Base s_impl = new DerivedImpl();
s_impl.Process();
```
✅
```csharp
private static readonly Base s_impl = new DerivedImpl();
s_impl.Process();

private static readonly bool s_feature =
    Environment.GetEnvironmentVariable("Feature") == "1";
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Avoid Explicit Static Constructors — Use Field Initializers
🟡 **AVOID** explicit `static` constructors when field initializers suffice | .NET Core 3.0+

❌
```csharp
class Foo
{
    static readonly int s_value;
    static Foo() { s_value = ComputeValue(); }
}
```
✅
```csharp
class Foo
{
    static readonly int s_value = ComputeValue();
}
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Detection

Scan recipes for I/O and serialization anti-patterns. Use these only as candidate search hints; inspect matches in context.

```bash
# new HttpClient() (socket exhaustion risk)
grep -rn --include='*.cs' 'new HttpClient(' --exclude-dir=bin --exclude-dir=obj . | wc -l

# new JsonSerializerOptions() not cached (592x slower in .NET 6)
grep -rn --include='*.cs' 'new JsonSerializerOptions' --exclude-dir=bin --exclude-dir=obj . | grep -v 'static\|readonly' | wc -l
```

### Patterns Requiring Manual Review

- **`JsonSerializer.Serialize/Deserialize` without source-gen context**: Can't determine from grep if a context parameter is passed
