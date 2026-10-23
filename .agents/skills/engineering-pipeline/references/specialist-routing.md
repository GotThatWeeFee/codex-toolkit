# Risk-adaptive specialist routing

Use focused, read-only specialists only when the actual diff presents a risk that benefits from expertise beyond ordinary senior review and QA. Specialists provide evidence; the senior engineer owns adjudication and the implementer remains the only source-code writer.

## Routing record

For each candidate lens, record the triggering files or behavior, consequence if missed, existing deterministic coverage, and whether a specialist adds meaningful independent scrutiny. If none does, record `SPECIALIST_REVIEW_NOT_REQUIRED` with concise evidence.

Ordinarily select no more than three distinct lenses. Additional lenses require a high-consequence justification. Combine overlapping concerns and do not spawn multiple specialists merely to seek consensus.

## Example lenses

Select by risk, not programming language:

| Evidence in the change | Candidate lens |
| --- | --- |
| Authentication, authorization, secrets, trust boundaries | Security |
| Personal, confidential, regulated, or logged data | Privacy and data handling |
| Schema, persistence, migrations, destructive operations | Data integrity and migration |
| Public APIs, events, serialization, multiple clients | Compatibility and contracts |
| Threads, tasks, locks, queues, distributed state | Concurrency and ordering |
| Hot paths, large data, strict latency or resource limits | Performance and capacity |
| Build, containers, infrastructure, release or rollback | Deployment and operations |
| Dependencies, generated artifacts, package provenance | Dependency and supply chain |
| Complex tests, mocks, nondeterminism, weak assertions | Test quality and flakiness |
| Accessibility or consequential interaction changes | Accessibility and user interaction |
| Unfamiliar language, framework, runtime, or lifecycle semantics | Language and framework correctness |
| High-impact business rules or calculations | Domain correctness |

This list is illustrative, not exhaustive. Define a new lens when repository evidence supports it.

## Specialist contract

Give each `pipeline_specialist_reviewer` exactly one lens, the approved intent, architecture state, acceptance criteria, final diff, relevant surrounding code, and known validation. Require:

- findings only within the assigned lens;
- concrete locations and evidence;
- consequence and reproduction or verification steps when practical;
- distinction between verified defects, plausible risks, and unknowns;
- no source edits and no architecture reopening unless a material requirement is unmet;
- exactly one result: `NO_FINDINGS`, `FINDINGS`, or `BLOCKED`.

Parallelize independent read-only lenses when it saves time. Do not run concurrent implementation agents against the same working tree.

## Corrections and adjudication

The senior engineer classifies each finding as required, advisory, duplicate, unsupported, accepted risk, or requiring human ownership. Only adjudicated required findings return to the implementer.

After a correction, re-run specialists whose evidence or risk area changed. Add a new lens only when the correction introduces a new material trigger. Preserve the original finding and its final disposition in the evidence package.
