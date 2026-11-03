# Candidate identity

Bind every review and test result to the same code candidate without requiring a commit. A mutable branch name, working-tree label, or prose description is insufficient.

## Establish the baseline

Before implementation, record:

- repository root and current `HEAD` commit when Git is available;
- initial staged, unstaged, and untracked state;
- pre-existing user changes and paths excluded from the task;
- in-scope paths and relevant build, dependency, schema, configuration, test, documentation, and agent-guidance files;
- application-source and documentation ownership, with serialized writer handoffs.

Do not absorb unrelated user changes into the candidate merely because they are present in the working tree.

## Create the fingerprint

After both implementation and documentation handoffs, and after each authorized correction, create a reproducible candidate record containing:

- baseline identity;
- sorted in-scope changed-path list;
- a hash of the canonical tracked patch against the baseline;
- SHA-256 content hashes for in-scope untracked files and any changed file not fully represented by that patch;
- explicit exclusions;
- creation time and correction-cycle number.

Use the same canonicalization method throughout a run and record the resulting identifier. A commit or tree hash may serve as the candidate fingerprint when the user has already authorized and created it, but this workflow never creates a commit merely to obtain an identifier.

## Verify at gates

Every assigned specialist, senior, QA and final reviewer states the fingerprint evaluated; any separately requested teaching or human review uses the same identity. QA also captures Git status before and after authorized checks and distinguishes declared caches, reports, and build products from unexpected source or test changes.

If included bytes or the scoped patch change outside the coordinator-assigned implementation/documentation correction path:

1. record `CANDIDATE_CHANGED` and the changed paths;
2. stop the current gate sequence;
3. determine whether the change is authorized, unrelated, generated, or conflicting;
4. create a new fingerprint after ownership is resolved;
5. repeat every assigned gate whose evidence may have been invalidated.

Do not claim that code was reviewed or tested when its fingerprint differs from the evidence package.

Documentation and instruction prose are candidate bytes, not post-review extras. Include changed README/AGENTS/rule registers, referenced examples and new docs in scope. Documentation research handoffs identify the source examined; downstream gates evaluate the combined fingerprint after final prose writes. No writer may append docs after gates without fingerprint reassessment and repeating affected gates.
