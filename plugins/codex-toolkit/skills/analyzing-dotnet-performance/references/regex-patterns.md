> Read the parent SKILL.md first. Patterns and severity labels below are review candidates, not automatic findings. Preserve semantics and verify framework support; upstream example timings are not measurements of this workload.

# Regex Patterns

### Choose the Right Regex Engine Mode
🟡 **DO** consider `[GeneratedRegex]` for repeatedly used constant patterns; preserve timeouts and nonbacktracking safety requirements | .NET 7+

❌
```csharp
var r = new Regex(dynamicPattern, RegexOptions.Compiled);
```
✅
```csharp
[GeneratedRegex("pattern")]
private static partial Regex MyRegex();

var safe = new Regex(untrustedPattern, RegexOptions.NonBacktracking);

var oneOff = new Regex("pattern");
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use IsMatch When You Only Need a Boolean Result
🟡 **DO** use `IsMatch` instead of `Match(...).Success` | .NET 7+

❌
```csharp
bool found = Regex.Match(input, pattern).Success;
```
✅
```csharp
bool found = Regex.IsMatch(input, pattern);
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use Regex.Count/EnumerateMatches Instead of Matches
🟡 **DO** use `Count()` and `EnumerateMatches()` for allocation-free match processing | .NET 7+

❌
```csharp
int count = 0;
Match m = regex.Match(text);
while (m.Success) { count++; m = m.NextMatch(); }
```
✅
```csharp
int count = regex.Count(text);

foreach (ValueMatch m in Regex.EnumerateMatches(text, @"\b\w+\b"))
{
    ReadOnlySpan<char> word = text.AsSpan(m.Index, m.Length);
}
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
### Use Span-Based Regex APIs for Allocation-Free Matching
🟡 **DO** use `ReadOnlySpan<char>` overloads for regex matching on spans | .NET 7+

❌
```csharp
string sub = largeBuffer.Substring(start, length);
bool found = Regex.IsMatch(sub, pattern);
```
✅
```csharp
ReadOnlySpan<char> text = largeBuffer.AsSpan(start, length);
foreach (ValueMatch m in Regex.EnumerateMatches(text, @"\b\w+\b"))
{
    ReadOnlySpan<char> word = text.Slice(m.Index, m.Length);
}
```

**Impact:** Candidate benefit depends on runtime, input, and workload; establish it from relevant evidence.
## Detection

Scan recipes for regex anti-patterns. Use these only as candidate search hints; inspect matches in context.

```bash
# Compiled regex count (startup cost budget — compare ratio to GeneratedRegex)
grep -rn --include='*.cs' 'RegexOptions.Compiled' --exclude-dir=bin --exclude-dir=obj . | wc -l

# GeneratedRegex count (already optimized — verify the inverse)
grep -rn --include='*.cs' 'GeneratedRegex' --exclude-dir=bin --exclude-dir=obj . | wc -l

# Uncached new Regex() calls (construction cost per call)
grep -rn --include='*.cs' 'new Regex(' --exclude-dir=bin --exclude-dir=obj . | wc -l
```

When `RegexOptions.Compiled` appears inside a class constructor or field initializer of an instantiated class (not a static singleton), count how many instances of that class are created at startup to determine total compiled regex budget. For example, if a `Rule` class compiles a regex in its constructor and 122 rules are registered, that is 122 compiled regexes at startup.

### Patterns Requiring Manual Review

- **`new Regex(` uncached**: Field assignment may span multiple lines — grep on one line is unreliable. Verify that matched instances are stored in `static readonly` fields or `[GeneratedRegex]`.
