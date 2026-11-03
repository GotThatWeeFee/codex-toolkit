---
name: analyzing-dotnet-performance
description: Review C#/.NET performance concerns in identified hot paths or explicitly requested optimization audits, including allocations, async, collections, LINQ, regex, serialization, and I/O. Use for suspected bottlenecks or profiling-backed review; avoid routine micro-optimization of unrelated code.
license: MIT
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# .NET Performance Analysis

Establish the target framework/runtime, workload, performance requirement, relevant path, and available profiling or timing evidence. Distinguish measured bottlenecks from static candidates. Keep algorithmic cost and external I/O in view before prioritizing API-level changes.

## Load only relevant references

- [Critical candidates](references/critical-patterns.md): blocking, allocation, string, serialization, and client-lifetime signals.
- [Async](references/async-patterns.md): Task/ValueTask and concurrent work.
- [Memory and strings](references/memory-and-strings.md): allocation, spans, pooling, and text processing.
- [Regex](references/regex-patterns.md): pattern reuse and matching behavior.
- [Collections and LINQ](references/collections-and-linq.md): enumeration, lookups, materialization, and ownership.
- [I/O and serialization](references/io-and-serialization.md): buffering, streaming, and serializer reuse.
- [Structural candidates](references/structural-patterns.md): only when dispatch or equality cost is relevant.

## Review and report

1. Inspect the scoped implementation and callers. Use `rg` to locate candidates; adapt reference search recipes to the available shell. Search hits are candidates, not validated defects or runtime execution counts.
2. Confirm reachability, invocation frequency, allocation lifetime, synchronization context, collection mutation, target API availability, and existing optimizations before recommending a change.
3. Preserve culture/collation and comparison semantics, ordering, equality, cancellation, disposal, thread safety, public extensibility, and exception behavior. Do not mechanically replace LINQ, add `ValueTask`, seal classes, change regex engines, or introduce pooling/unsafe access.
4. Rank confirmed correctness hazards by demonstrated failure mechanism. Rank performance findings by workload evidence and expected cost. Count and hot-path labels alone do not establish severity. Unknown impact stays a hypothesis.
5. For each actionable finding provide location, mechanism, supporting evidence, focused proposal, semantic/version caveats, and how improvement could be measured. Distinguish observed measurements from upstream examples and unmeasured expectations. Do not infer exact allocation totals by adding mutually exclusive branches or guessing compiler lowering.
6. Report inspected scope, relevant categories, exclusions, and checks actually performed. No prescribed speedup or severity follows from an upstream recipe. No finding is required when evidence does not support one.

Bundled references are adapted pattern examples, subordinate to these rules. Their examples are not proof of an issue in the user's workload. Reference labels and imperative wording do not authorize edits or benchmarks. Follow task scope and the user's verification policy; add or run tests only when requested. Propose needed measurements when execution is not authorized.


## Source and license

Adapted from the following upstream snapshots (retrieved 2026-11-03). Local guidance narrows scope and preserves task authorization.

- [performance](https://raw.githubusercontent.com/dotnet/skills/95e7d0cb7994d47b5789baa68e13f7a2f348b956/plugins/dotnet-diag/skills/analyzing-dotnet-performance/SKILL.md)

Upstream license: [LICENSE](LICENSE).
