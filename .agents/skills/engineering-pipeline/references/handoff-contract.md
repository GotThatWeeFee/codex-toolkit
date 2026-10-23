# Pipeline handoff contract

Use only the sections relevant to the receiving stage. Keep handoffs concise and evidence-based.

## Task contract

- Objective
- In scope
- Out of scope
- Constraints and repository instructions
- Acceptance criteria
- User decisions and unresolved questions

## Candidate identity

Use [candidate-identity.md](candidate-identity.md). Include the baseline identity, in-scope and excluded paths, candidate fingerprint, creation time, and any declared generated test artifacts. Every specialist, senior, QA, final-review, Language Mentor, and human-review handoff must state the candidate fingerprint it evaluated.

## Model-routing record

Include one record for every stage dispatch or repeat:

- Role and cycle number
- Selected model and reasoning effort
- Decision difficulty: low, medium, or high
- Consequence level: low, medium, or high
- Reasons for the selection
- Prior findings, uncertainty, or disagreement that caused an escalation
- Requested setting, actual setting, and reason when a fallback was required

Do not infer quality from the model name alone. Preserve the stage's evidence and gate result separately.

## Reviewer learning profile

- Reviewer identity when provided
- Familiar languages, frameworks, and approximate familiarity levels
- Preferred comparison languages or learning style
- Target languages and frameworks derived from the approved stack and final diff
- Requested explanation depth and specific learning goals
- Delivery mode: interactive by default, one-shot when requested, or skipped by the reviewer

Keep this profile separate from the architecture decision. Familiarity may inform maintainability tradeoffs, but it does not restrict candidate or approved stacks.

## Planning handoff

- Verified repository facts with file or symbol references
- Proposed design and affected components
- Alternatives considered when the choice is material
- Risks and rollback considerations
- Implementation sequence
- Verification strategy

## Architecture decision handoff

- Greenfield or brownfield classification and supporting evidence
- Existing organizational and repository constraints
- Candidate stacks when a choice or exception is genuinely open
- Comparison across maintainability, deployment, security and compliance, integrations, operations, testing, performance, and total cost
- Recommended stack and material tradeoffs
- Rejected alternatives and reasons
- Accountable human approver
- Gate state: `APPROVED_STACK`, `EXISTING_STACK_CONFIRMED`, or `AWAITING_ARCHITECTURE_APPROVAL`

## Implementation handoff

- Files changed and behavior implemented
- Tests added or updated
- Commands run with exact outcomes
- Deviations from the approved plan
- Known limitations or unverified assumptions
- Current diff and Git status
- Architecture decision followed and any deviations

## Review handoff

- Findings ordered by severity with locations
- Reproduction or supporting evidence
- Required corrections versus advisory observations
- Disposition of findings from the previous cycle
- Gate decision

## Specialist-routing and review handoff

- Actual diff risks and repository evidence used for routing
- Selected specialist lenses, or `SPECIALIST_REVIEW_NOT_REQUIRED` with reasons
- Model-routing record for each specialist invocation
- Exact scope supplied to each specialist
- Findings with locations, evidence, confidence, and verification suggestions
- Senior adjudication for every finding: required, advisory, duplicate, unsupported, accepted risk, or requires human ownership
- Specialist findings affected by a correction and re-review disposition

## QA handoff

- Acceptance criteria exercised
- Commands or manual procedures run
- Exact pass, fail, skip, and blocked results
- Reproducible failures with expected and actual behavior
- Environmental limitations
- Gate decision

## Final evidence package

- Approved task and design
- Architecture decision and gate state
- Final diff
- Implementation summary
- Senior-review disposition
- QA results
- Final-review findings and decision
- Specialist-routing decisions, findings, and senior adjudications
- Model-routing records for all stages and correction cycles
- Every finding from senior review, QA, final review, and prior human review with its disposition
- Remaining risks, skipped checks, environmental limitations, and unverified assumptions
- Language Mentor briefing or documented reason it was not required
- Candidate fingerprint evaluated by every gate and evidence that QA did not change reviewed source or tests

## Reviewer learning handoff

Use [reviewer-learning.md](reviewer-learning.md). Record:

- Reviewer learning profile used
- Target languages and frameworks found in the final diff
- Behavior and execution-path walkthrough
- Non-obvious concepts and cautious analogies
- Language- or framework-specific review risks
- Test-to-behavior map and suggested reviewer questions
- Authoritative documentation consulted when available
- `NO_REVIEW_CONCERN` or material `REVIEW_CONCERN` items returned to engineering review
- Lessons actually delivered to the reviewer, not merely generated internally
- Reviewer answers, questions, requested depth, and unresolved misunderstandings
- Completion state: `TEACHING_COMPLETED`, `ONE_SHOT_BRIEFING_REQUESTED`, or `TEACHING_SKIPPED_BY_REVIEWER`

## Human engineering review

Use [human-review.md](human-review.md). Record:

- Accountable reviewer and date when provided
- Intent and architecture review result
- Final-diff review result
- Independently verified high-risk claims
- CI, test, and branch-protection evidence available to the reviewer
- Accepted residual risks
- Language Mentor briefing reviewed when one was produced
- Candidate fingerprint verified against the exact reviewed and tested bytes
- Reviewer stack-familiarity assessment and identified proficient co-reviewer for high-consequence unfamiliar-stack changes
- Human findings with locations, severity, and required correction
- Decision: `REQUEST_CHANGES`, `APPROVED_FOR_MERGE`, or `ESCALATE_TO_OWNER`

`APPROVED_FOR_MERGE` is a review state, not an instruction to perform the merge or any other external action.

## Documentation and researched project rules

Use [documentation.md](documentation.md) in planning and before the combined fingerprint:

- Phase and source candidate used; detected component languages/frameworks/versions with repository evidence and implemented/planned/unknown status
- Existing guidance inventory, documentation impact, assigned writer paths and preserved instructions
- Proposed/new/updated documents and the concrete need each addresses, or reasoned NO_DOCUMENTATION_CHANGES_NEEDED
- Rule register with scope, authority, existing/adopted/proposed status, applicable version, primary source/section/checked date, local overrides, and actual enforcement or manual checks
- Commands, links, paths/examples and rule/config consistency checked; verified outcomes versus unrun checks
- Material conflicts/decisions returned to owner, unavailable research and remaining unknowns
- DOCUMENTATION_READY, NO_DOCUMENTATION_CHANGES_NEEDED or BLOCKED; coordinator then fingerprints all source and prose

Implementation handoffs identify source/config/test ownership and doc impacts. Review,
QA, final, mentor and human handoffs include the documentation evidence and exact
combined fingerprint. Route corrections to the assigned writer, refresh documentation
after code changes, and invalidate affected gates when any included prose changes.

## Agent lifecycle record

Use [agent-lifecycle.md](agent-lifecycle.md) before dispatch and after stage completion.
Record role/ID/scope/model/effort, observed state/time, candidate and durable result
location, retain/reuse/close rationale, actual close result and confirmed status.
Record restored contracts for same-role replacements, pre/post inventory, capacity
errors and unavailable controls. A completed result is not evidence of closure.
