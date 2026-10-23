---
name: engineering-pipeline
description: Run a risk-adaptive software-delivery workflow through planning, implementation, documentation and researched project rules, specialist review, senior engineering, QA, final review, reviewer education, and human approval. Use when the user requests the engineering pipeline, staged agent development, formal handoffs, or implementation with independent gates. Do not use for simple questions, read-only reviews, or tiny edits that do not warrant a staged workflow.
---

# Engineering Pipeline

Coordinate an evidence-based software change using the core custom agents `pipeline_planner`, `pipeline_implementer`, `pipeline_documentation`, `pipeline_senior_engineer`, `pipeline_qa`, and `pipeline_final_reviewer`, plus the risk-triggered `pipeline_specialist_reviewer` and reviewer-focused `pipeline_language_mentor` when applicable.

## Before starting

- Confirm the workspace is the intended Git repository and read all applicable `AGENTS.md` instructions.
- Inspect Git status and preserve unrelated work. If concurrent writes could overlap, use an isolated worktree when available or stop for direction.
- Establish the task, scope, constraints, and human acceptance boundary. Ask only for a missing decision that would materially change the result.
- Apply [Agent Lifecycle](references/agent-lifecycle.md) before each dispatch and after each stage: inspect, reuse, preserve handoffs, and close eligible completed threads only through supported controls.
- Do not substitute API-backed agents or API keys. This workflow is intended to use the active Codex subscription session.
- Select and record each stage's model and reasoning effort using the [Model Routing Gate](references/model-routing.md). Keep the custom role files model-neutral so the coordinator can route each run according to its actual risk and complexity.
- Record any reviewer learning preferences using [Reviewer Learning](references/reviewer-learning.md). Familiar languages are explanation anchors and maintainability evidence, never automatic stack constraints.
- Assign application-source and documentation paths to their separate owners using [Documentation and Project Rules](references/documentation.md). Serialize all candidate writes; include both outputs in review.
- Include source reviewability in the implementation acceptance criteria: the implementer owns useful comments, docstrings, and language-native documentation within changed source; the senior engineer checks their accuracy and meaningful explanation gaps. Follow repository conventions, avoid narrating obvious code, and keep assigned prose files with the documentation agent.
- Establish the scoped baseline and candidate fingerprint using [Candidate Identity](references/candidate-identity.md). Every downstream gate must evaluate the same candidate bytes.

## Architecture Decision Gate

Classify the work before implementation:

- **Greenfield:** a new system whose language and architecture are not already established. A rewrite remains brownfield when existing behavior, data, or integrations constrain it.
- **Brownfield:** a change to or replacement of an existing system with inherited code, behavior, data, integrations, or operational constraints.

For brownfield work, use the existing language, framework, build system, and operational conventions by default. Record `EXISTING_STACK_CONFIRMED` once repository evidence shows the established stack can meet the task. A proposed exception requires the same human approval as a greenfield choice.

For greenfield work, or any exception to an existing stack, require the planner to create the decision record in [references/architecture-decision.md](references/architecture-decision.md). The accountable human technical owner makes the final decision; agents only recommend. Do not start implementation until the coordinator records `APPROVED_STACK`.

If the user already explicitly selected the language and stack for this task, treat that as human approval, record the decision and `APPROVED_STACK`, and do not ask them to approve it again. If organizational approval belongs to someone else, stop until that named approver provides it.

## Model Routing Gate

Before spawning each role, read [references/model-routing.md], classify that stage's decision difficulty and consequence level, and create a model-routing record. Use the least costly model and reasoning effort that can reliably perform the stage. Do not apply one high-cost setting to the entire pipeline merely because one stage is difficult.

Reassess the next dispatch when repository evidence raises the risk, an agent reports low confidence, a gate finds a material defect, or two agents materially disagree. A correction cycle may use a stronger setting than the initial implementation, but escalation is not automatic for ordinary test failures. Record unavailable requested settings and the fallback actually used.

Model routing changes analytical capacity, not authority. It never bypasses the Architecture Decision Gate, human approvals, repository instructions, sandboxing, or the workflow's stopping rules.

## Risk-adaptive Specialist Review

After implementation and before the senior gate, use [Specialist Routing](references/specialist-routing.md) to decide whether the diff needs focused read-only review. Spawn `pipeline_specialist_reviewer` once per selected lens and give each invocation exactly one bounded concern. Independent specialist reviews may run in parallel; the implementer remains the sole application-source writer and the documentation agent the sole writer of its assigned prose paths. Their candidate writes run sequentially.

Use no specialist when repository evidence shows that ordinary senior review and QA provide sufficient coverage. Record `SPECIALIST_REVIEW_NOT_REQUIRED` and the reason instead of spending usage merely to populate the stage. Ordinarily select no more than three lenses. More require a documented high-consequence justification.

Specialists return evidence, not gate decisions. The senior engineer adjudicates every specialist finding as required, advisory, duplicate, unsupported, accepted risk, or requiring human ownership.

## Run the stages

Run dependent stages sequentially. The coordinator owns state and relays feedback between agents; agents do not independently broaden scope. Before any spawn/resume, apply the lifecycle capacity check; after each result, preserve its handoff and decide whether its thread should remain open. If a needed agent was closed, restore its contract into an explicitly recorded same-role replacement.

1. Route and spawn `pipeline_planner`. Require repository evidence, design, acceptance criteria, verification strategy, greenfield/brownfield classification, and architecture recommendation or existing-stack confirmation.
2. Route and spawn `pipeline_documentation` in its read-only planning phase using [Documentation and Project Rules](references/documentation.md). Require stack/version evidence, existing guidance inventory, documentation impact, applicable researched rules and proposals, and assigned documentation paths. Feed this handoff into the plan; resolve only material decisions before affected implementation.
3. Check the plan against the user's request and apply the Architecture Decision Gate. Record `APPROVED_STACK` or `EXISTING_STACK_CONFIRMED` before source changes. Documentation research does not approve a stack or a material new policy.
4. Route and spawn `pipeline_implementer` with the approved plan, architecture state, acceptance criteria, documentation planning handoff, and routing record. This is the sole writer of application source, tests, and executable configuration; it reports documentation impacts and freezes its writes before handing off.
5. Route or resume `pipeline_documentation` to update assigned documentation and agent guidance, introducing new docs only where justified. Require `DOCUMENTATION_READY` or evidence-backed `NO_DOCUMENTATION_CHANGES_NEEDED`. Finish both writers' handoffs, then create the combined source/documentation candidate fingerprint before review.
6. Evaluate specialist routing against the combined diff. Spawn zero to three bounded `pipeline_specialist_reviewer` lenses or record `SPECIALIST_REVIEW_NOT_REQUIRED`. Provide approved plan, architecture, acceptance criteria, documentation/rule evidence, exact fingerprint, diff, and each lens.
7. Route and spawn `pipeline_senior_engineer` with both writer handoffs, combined diff, routing records, and specialist findings. The senior engineer adjudicates findings including misleading docs, unsupported adopted rules, and missing warranted documentation.
8. For `CHANGES_REQUIRED`, route bounded findings to the assigned writer: source/config/test changes to the same implementer, prose/rule changes to the documentation agent. Serialize writes, rerun documentation impact after source changes, fingerprint the combined correction, repeat affected specialists and senior review. Allow at most two senior correction cycles unless the user specifies otherwise.
9. After `APPROVE_FOR_QA`, verify the combined fingerprint and spawn `pipeline_qa`. Require pre/post Git status and unchanged candidate bytes; validate acceptance criteria plus documented commands, links and rule/tool consistency as applicable. For `FAIL`, use the same ownership/correction sequence, refresh documentation and fingerprint, rerun affected specialist/senior gates, then QA. Allow at most two QA correction cycles.
10. After QA `PASS`, spawn `pipeline_final_reviewer` with complete source and documentation evidence. For `CHANGES_REQUIRED`, permit one bounded correction through the assigned writers followed by documentation reassessment, fingerprint, affected specialists, senior, QA and final review. Reassess routing and stop if unresolved.
11. At `READY_FOR_HUMAN_APPROVAL`, apply [Reviewer Learning](references/reviewer-learning.md). Spawn `pipeline_language_mentor` when requested, for unfamiliar languages/frameworks, or non-obvious review semantics. The coordinator teaches the briefing interactively; an internal response or bare `NO_REVIEW_CONCERN` is not delivery. Send material `REVIEW_CONCERN` to the senior engineer before teaching or approval; corrections use the same writer/documentation/fingerprint sequence. The mentor cannot adjudicate or approve.
12. After teaching is completed or the reviewer explicitly requests one-shot delivery or skips it, verify the fingerprint and apply [Human Engineering Review](references/human-review.md). Review approved intent, architecture, complete candidate, validation, finding dispositions, documentation/rule changes, learning record and risks. High-consequence unfamiliar-stack changes require an identified proficient human co-reviewer or `ESCALATE_TO_OWNER`.
13. Record exactly one human decision: `REQUEST_CHANGES`, `APPROVED_FOR_MERGE`, or `ESCALATE_TO_OWNER`. Human corrections return to the assigned writers and require documentation reassessment, new fingerprint, affected review/QA/final/learning gates and renewed human review. Escalation stops for the designated owner. Technical approval never implies authorization to commit, push, merge, publish, release or deploy.

When invoking each role, include the relevant handoff fields in [references/handoff-contract.md](references/handoff-contract.md). Do not start a downstream gate without the evidence it needs.

## Communication and stopping rules

- The coordinator mediates back-and-forth communication and keeps the user informed of gate outcomes.
- The coordinator records architecture approval but does not impersonate the accountable human approver.
- The coordinator summarizes the evidence but does not impersonate the human engineering reviewer. Agent agreement is not human approval.
- If the candidate fingerprint changes outside the coordinator-assigned implementation/documentation correction path, record `CANDIDATE_CHANGED`, stop the current gate sequence, resolve ownership of the change, and repeat every affected review and validation gate against a new fingerprint.
- Preserve dissent: relay a review finding accurately instead of silently weakening it. The implementer may rebut it with evidence; the reviewer decides whether it is resolved.
- Stop and ask the user when requirements conflict, a destructive or externally visible action needs authorization, the correction limit is reached, or required verification cannot be performed.
- If a custom role is unavailable, report which role is missing instead of silently simulating the full pipeline with one agent.

## Final handoff

Report the outcome first, followed by:

- implemented behavior and files changed;
- documentation impact, detected stack/version evidence, justified new documents, researched rule sources/status and unresolved guidance gaps;
- validation actually run and exact results;
- senior, QA, and final-review gate decisions;
- specialist-routing decisions, findings, and senior adjudications;
- the model and reasoning effort actually used for each stage, with concise escalation or fallback reasons;
- the reviewer learning profile, teaching delivery mode, completion or opt-out state, and Language Mentor briefing or reason it was not required;
- the human-review decision, reviewer identity when provided, and disposition of any human findings;
- remaining risks, unverified assumptions, or blockers;
- agent lifecycle decisions, preserved handoffs, confirmed closures or substitutions, and unverified capacity limits;
- the next user-controlled action.

Do not claim the change is production-ready merely because every agent completed its turn or because a human approved it for merge. Deployment and operational readiness require their own applicable controls.
