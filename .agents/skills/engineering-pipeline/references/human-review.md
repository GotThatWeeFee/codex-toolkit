# Human engineering review gate

The accountable engineer reviews the final result and owns the technical approval decision. Agent agreement, passing tests, or `READY_FOR_HUMAN_APPROVAL` cannot substitute for this gate.

## Review package

Present a compact package rather than requiring the reviewer to read every agent conversation:

- approved requirements, scope, and acceptance criteria;
- architecture decision and approval state;
- final diff with relevant surrounding code;
- implementation summary and dependency, configuration, schema, or operational changes;
- exact validation results and environmental limitations;
- senior, QA, final-review, and prior human findings with explicit dispositions;
- specialist-routing decisions, specialist findings, and senior adjudications;
- model-routing records;
- the Language Mentor briefing and interactive delivery record when one was produced;
- candidate identity and matching fingerprints from specialist, senior, QA, final, and mentor stages;
- remaining risks, skipped checks, and unverified assumptions.

Keep the underlying agent threads available for drill-down when a summary is unsupported, inconsistent, or incomplete.

## Review sequence

1. **Intent:** Confirm the change solves the approved problem, respects scope, and has testable acceptance criteria.
2. **Architecture:** Confirm the approved stack and decision were followed and that dependencies, integrations, operations, and rollback remain acceptable.
3. **Diff:** Inspect the final code and relevant surrounding paths. Do not approve from summaries alone.
4. **Learning:** Complete the interactive Language Mentor teaching session, or explicitly request a one-shot briefing or skip it. Verify its explanations against the code, tests, and authoritative documentation. An internally generated briefing or concern status alone is not delivery. The teaching is educational context, not approval evidence and cannot establish reviewer proficiency.
5. **Evidence:** Check that tests and CI cover the acceptance criteria and important negative paths. Verify that all prior findings have explicit dispositions.
6. **Risk:** Independently verify the most consequential claims, including applicable security, authorization, privacy, data integrity, financial, compatibility, concurrency, migration, rollback, and deployment behavior.
7. **Decision:** Record exactly one gate state and the evidence or findings that support it.

Use deterministic enforcement for builds, tests, formatting, linting, type checks, dependency policies, secret detection, and other mechanically expressible requirements. Use agent and human judgment for intent, architecture, compatibility, security boundaries, maintainability, missing scenarios, and accepted risk.

## Checklist

### Intent

- [ ] Requirements, scope, and acceptance criteria are clear.
- [ ] The final behavior solves the approved problem without unapproved scope expansion.

### Architecture

- [ ] The architecture gate is satisfied and the implementation follows the decision.
- [ ] New dependencies, integrations, operational effects, and rollback needs are acceptable.

### Implementation

- [ ] The reviewer inspected the final diff and relevant surrounding code.
- [ ] The candidate fingerprint matches the exact bytes evaluated by every required gate.
- [ ] The Language Mentor teaching record is `TEACHING_COMPLETED`, `ONE_SHOT_BRIEFING_REQUESTED`, or `TEACHING_SKIPPED_BY_REVIEWER` when a mentor was used.
- [ ] Unfamiliar language or framework concepts were understood sufficiently for an ordinary-risk decision.
- [ ] For a high-consequence change in an unfamiliar stack, an identified language- or framework-proficient human co-reviewer approved it; otherwise the decision is `ESCALATE_TO_OWNER`.
- [ ] Applicable security, privacy, data-integrity, compatibility, and failure risks were considered.
- [ ] The change is maintainable by the owning team.

### Evidence

- [ ] Relevant automated checks passed or each limitation is explicit.
- [ ] Important negative paths were exercised proportionately to risk.
- [ ] Every material agent or prior human finding has an explicit disposition.
- [ ] Remaining assumptions and residual risks are visible.

## Decisions

- `REQUEST_CHANGES`: Return specific, bounded findings to the implementer. The corrected diff must repeat senior review, QA, final review, and human review.
- `APPROVED_FOR_MERGE`: Record technical approval and accepted residual risks. This does not authorize Codex to commit, push, merge, publish, release, or deploy.
- `ESCALATE_TO_OWNER`: Stop for an accountable architecture, security, product, compliance, data, or operations owner whose authority is required.

A Language Mentor briefing, specialist agent, test suite, or reviewer self-study cannot satisfy the proficient-human requirement for a high-consequence unfamiliar-stack change. Use the organization's code-ownership or competency policy when one exists. Otherwise require an identified human who can independently review the relevant language and framework semantics.

For `REQUEST_CHANGES`, identify concrete locations, expected behavior, severity, and the evidence needed to demonstrate resolution. For `ESCALATE_TO_OWNER`, identify the owner role and unresolved decision without inventing the answer.

## Documentation and rule review

Review the combined source/documentation candidate and both writer handoffs. Check
that agent guidance is discoverable, docs match implemented behavior, new documents
serve a concrete need, and researched rules match detected versions and actual tools.
Distinguish authoritative standards from advisory sources and local decisions;
material new policy must have its required owner decision. No documentation-stage
result or role addition replaces human approval or authorizes external delivery.
