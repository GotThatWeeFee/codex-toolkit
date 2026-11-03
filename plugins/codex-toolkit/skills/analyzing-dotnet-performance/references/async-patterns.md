> Read the parent SKILL.md first. Patterns and severity labels below are review candidates, not automatic findings. Preserve semantics and verify framework support; upstream example timings are not measurements of this workload.

# Async & Concurrency Patterns

### Don't Expose Async Wrappers for Sync Methods
🟡 **AVOID** wrapping sync methods with `Task.Run` in libraries | .NET Core+

❌
```csharp
public Task<int> ComputeHashAsync(byte[] data) =>
    Task.Run(() => ComputeHash(data));
```
✅
```csharp
public int ComputeHash(byte[] data) { /* CPU-bound work */ }
// Consumer decides: var hash = await Task.Run(() => lib.ComputeHash(data));
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Don't Expose Sync Wrappers for Async Methods
🟡 **AVOID** creating sync wrappers that block on async implementations | .NET Core+

❌
```csharp
public string GetData() => GetDataAsync().Result;
```
✅
```csharp
public async Task<string> GetDataAsync() { /* ... */ }
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use ValueTask for Hot Paths with Frequent Sync Completion
🟡 **DO** use `ValueTask<T>` on hot paths where sync completion is common | .NET Core 2.1+

❌
```csharp
public async Task<int> ReadAsync(Memory<byte> buffer)
{
    if (_bufferedCount > 0)
        return ReadFromBuffer(buffer.Span);
    return await ReadAsyncCore(buffer);
}
```
✅
```csharp
public ValueTask<int> ReadAsync(Memory<byte> buffer)
{
    if (_bufferedCount > 0)
        return new ValueTask<int>(ReadFromBuffer(buffer.Span));
    return new ValueTask<int>(ReadAsyncCore(buffer));
}
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use Channels for Producer/Consumer
🟡 **DO** use `System.Threading.Channels` for producer-consumer patterns | .NET Core 3.0+

❌
```csharp
var queue = new BlockingCollection<WorkItem>();
var item = queue.Take();
```
✅
```csharp
var channel = Channel.CreateUnbounded<WorkItem>();

// Producer
await channel.Writer.WriteAsync(item);

// Consumer
await foreach (var item in channel.Reader.ReadAllAsync())
    Process(item);
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Avoid False Sharing with Thread-Local State
🟡 **AVOID** adjacent mutable fields written by different threads | .NET 7+

❌
```csharp
class SharedCounters
{
    public long Counter1;
    public long Counter2;
}
```
✅
```csharp
[StructLayout(LayoutKind.Explicit, Size = 128)]
struct PaddedCounter
{
    [FieldOffset(0)] public long Value;
}
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Detection

Scan recipes for async anti-patterns. Use these only as candidate search hints; inspect matches in context.

```bash
# async void methods (correctness issue — crashes on exception)
grep -rn --include='*.cs' 'async void' --exclude-dir=bin --exclude-dir=obj . | grep -v 'event' | wc -l
```

### Patterns Requiring Manual Review

- **Sync-over-async** (`.Result`, `.Wait()`): `.Result` matches any property named Result — needs type context to confirm it's `Task.Result`
