---
name: engineering-subagent-pipeline
description: Coordinate approval-gated, multi-agent software engineering from project discovery and planning through implementation, risk-based review, QA, and final handoff. Use for non-trivial development work that benefits from a planner, a single implementation owner, and independent review; do not use for a small one-file change or a standalone code review.
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# Engineering Subagent Pipeline

Act as the coordinator. Maintain a concise state record with the project classification, approved plan revision, chosen agents and model settings, findings, validation evidence, a complete change ledger, and rework counters. The coordinator owns all routing; no subagent may advance itself to another phase. The final working tree is the source of truth for scope: subagent-reported diffs are inputs, never the complete change set.

## Candidate, lifecycle, and finding discipline

Before dispatch, read [candidate identity](references/candidate-identity.md) and [agent lifecycle](references/agent-lifecycle.md). Bind all evidence to baseline HEAD, initial state, canonical patch and relevant non-patch hashes, including instruction and documentation bytes. Record the candidate fingerprint on every review; changed bytes invalidate affected evidence. Maintain the run registry outside candidate files.

Give every actionable finding a stable ID and record disposition (accepted/fixed, rejected with evidence, deferred with explicit owner/risk, or unresolved), affected candidate, and reviewer dissent. A rejected finding is not silently passed: material dissent goes to the senior/final gate and unresolved blocking risk prevents readiness. Rerun only affected reviews. Preserve already authorized design decisions and existing project constraints during rewrites. Optional reviewer teaching is provided only when requested and adds no compulsory approval gate; see [reviewer teaching](references/reviewer-teaching.md).

## 1. Discover and plan

1. Inspect applicable `AGENTS.md` files, manifests, dependency/build configuration, architecture and API documentation, relevant tests, and the current diff before proposing work. Identify the documentation affected by the requested behavior (for example, public API, configuration, operational, architecture, migration, or contributor guidance). Record either the documentation updates required for the plan or an evidence-based `not applicable` decision; do not create documentation merely because code changes.
2. Classify the target:
   - **Existing project:** any meaningful source, manifest, dependency, test, or documented architecture is present. Preserve its conventions, public contracts, and established design unless the approved plan explicitly changes them.
   - **Greenfield:** no meaningful project implementation or architecture exists. Identify the minimum architecture, stack, interfaces, and validation plan needed. Ask the user only for decisions that materially change those choices; otherwise state an explicit default.
   - If evidence conflicts, classify it as existing and report the ambiguity rather than replacing its design by assumption.
3. Send the planner the task, discovery evidence, user constraints, and current diff. Require the plan format in `references/role-cards.md`. The plan must classify required documentation as either routine implementation documentation or substantial documentation work. Use the documentation specialist only when the work has a distinct, explicitly scoped documentation deliverable such as onboarding, architecture, an operational runbook, a migration guide, or cross-project documentation reconciliation. Record assigned files, audience, behavior evidence, and sequencing. Routine README, API, configuration, and feature updates remain with the junior developer. For a repository-wide documentation audit or substantial guide, route the documentation specialist through `repository-documentation`; for source changes, require the implementation owner to apply `project-aware-coding` to XML documentation and formatting.
4. Present the planner's plan, assumptions, risks, selected review tracks, proposed model/reasoning choices, and whether it qualifies for the faster lane.
   - **Standard lane:** stop and wait for explicit approval or plan adjustments. This is mandatory for a new feature, material architecture change, public-contract or schema change, migration, authorization/security-sensitive change, production or shared-environment impact, or any unresolved material decision.
   - **Faster lane:** the coordinator may advance after reporting the plan when the work is a bounded internal bug fix, refactor, test improvement, or documentation correction with deterministic local validation; no changed public contract, persistence/schema, authorization, sensitive-data behavior, external integration behavior, or material architecture; and no unresolved user decision. The report must name the qualifying criteria and give the user a clear opportunity to stop or adjust it. If any criterion ceases to hold, return to the standard lane before implementation.

## 2. Implement

After approval, give the junior developer only the approved plan revision plus unresolved findings. The junior developer is the sole agent allowed to change project source, tests, configuration, and routine documentation. Implement routine documentation alongside its associated change, preserving user edits and established documentation conventions. Require the junior developer to check new and changed C# XML documentation for signature-complete tags, validate any `<inheritdoc/>` source, and review changed-file formatting against repository configuration. When the plan assigns substantial documentation work to the documentation specialist, give that role sole ownership of the named documentation files and give the junior developer the final behavior, configuration, and validation evidence it needs. Run the documentation specialist after the documented behavior is implemented and after each later behavior-changing remediation; do not run it concurrently with another source writer. Preserve user changes. Apply the shared Git, verification, and authorization policy in the applicable AGENTS.md; an implementation plan does not independently authorize deployment, external writes, or Git mutations. Reuse explicit authorization already granted for the exact scope.

## 3. Select specialist reviews

Run only the review tracks touched by the change. Run at most three read-only specialists concurrently, matching the current runtime capacity. For a difficult plan with independently scoped risks, the coordinator may select up to five review tracks but must batch them when the runtime cannot host them concurrently. The documentation specialist is a sequential writer, not a review track, and does not replace any selected review. Never run parallel source writers.

| Changed surface | Run this specialist |
| --- | --- |
| Any runtime source, dependency, build, or deployment-configuration change | Security baseline; deepen call-path review for authentication, authorization, secrets, untrusted input, files, network, crypto, or sensitive data |
| Writes, retries, queues, jobs, events, transactions, state transitions, concurrency, or duplicate delivery | Reliability and idempotency |
| Public APIs, schemas, database migrations, packages, configuration, serialization, or backwards compatibility | Contract and compatibility |
| Behavior changes, bug fixes, test infrastructure, validation gaps, or non-deterministic tests | Test strategy |
| C#/.NET behavior or project, package, or build changes with a concrete framework-specific concern: async/cancellation, nullability, resource or DI lifetimes, options/configuration, serialization/model binding, EF/data semantics, hosting/background services, target-framework/runtime/package settings, or test-runtime integration | C#/.NET practices specialist; this does not replace security, reliability, contract, test, performance, or accessibility reviews, and must not become a generic style review |
| Performance-sensitive paths, expensive queries, resource limits, caching, throughput, latency, background processing, logging/metrics, or operational failure handling | Performance and operability |
| User-facing flows, UI components, content, keyboard interaction, colors, forms, or generated documents | Accessibility |

Security is required for each runtime-source, dependency, build, or deployment-configuration change; it may be skipped only for a clearly non-runtime documentation-only change, with the reason recorded. Do not add a generic style reviewer: the senior engineer owns maintainability and architecture. Consolidate actionable specialist findings into one remediation packet for the junior developer. Notes without a concrete correctness, security, compatibility, test, performance, operability, or accessibility impact do not trigger rework.

## 4. Gate progression

1. Specialist reviews pass or their actionable findings are remediated and selectively re-reviewed.
2. Senior engineer reviews the approved intent, implementation diff, specialist evidence, and validation plan. Return only concrete must-fix findings to the junior developer; otherwise advance to QA.
3. QA performs the checks authorized under the applicable AGENTS.md verification policy and reports commands, outcomes, and unrun validation. QA does not alter source. Tests require a user request; a plan or project procedure alone does not authorize them or external writes. Use a designated non-production environment only when the current explicit authorization covers the exact access and any isolated test-data writes. Minimize and identify that data, report the environment and evidence, and never target production through this QA step. Failures or missing required coverage return to the junior developer.
4. Final reviewer independently checks scope, acceptance criteria, open findings, validation evidence, release-risk boundaries, and the planner's documentation-impact assessment. Before review, the coordinator must reconcile the final working tree from the repository root and record every tracked, modified, deleted, renamed, and untracked file. For each file, record the responsible phase/agent, what changed, why it changed, and the evidence or finding that caused it; explicitly identify intentional no-op files and any change not attributable to the approved plan. The final reviewer must review this complete change ledger against the checkout, not just the diffs returned by individual agents. Confirm required documentation was updated accurately and consistently with the implementation, that changed C# documentation and formatting meet applicable repository rules, or that the recorded `not applicable` decision remains supported by the final diff. Only the coordinator may declare the work ready for the user's review.

The final handoff must be coordinator-produced from the final checkout and must distinguish:

- **Outcome and rationale:** what was changed and the user/problem reason for each change.
- **Complete change inventory:** every tracked and untracked file, grouped by component, with its change type, responsible phase/agent, and rationale. Do not omit files because a subagent did not mention them.
- **Diff evidence:** final `git status --short`, `git diff --name-status`, and `git diff --stat` (plus an explicit inventory of untracked-file contents). If the chat UI cannot display the complete patch, provide/open the repository-level diff artifact and say that the file inventory is authoritative; never present an incomplete subagent diff as the final diff.
- **Checks passed, checks not run, residual risks, and any user decision still needed.**

The handoff must also include a short remediation history when more than one agent or cycle changed the working tree, showing which finding or review decision caused each follow-up change. It is not authorization to release, deploy, stage, commit, or push.

### Optional local audit facts and handoff

Only when the recipient has separately authorized the metadata-only audit facility, hook records are observations only. They never establish approval, completion, trust, or readiness. The coordinator records each actual gate fact in order (`PlanApproved`, `ImplementationCompleted`, `ReviewCompleted`, `ValidationCompleted`, then `HandoffBlocked` or `HandoffReady`) with `scripts/audit.ps1 -AuditRoot <recipient-approved-local-root> -CoordinatorFact ... -WorkspaceFingerprint <64-lowercase-hex> -RunFingerprint <64-lowercase-hex> -CoordinatorEventFingerprint <64-lowercase-hex>`; pass only already-computed fingerprints, never a raw workspace path. All three fingerprints are opaque and mandatory: the workspace fingerprint identifies the approved workspace scope without exposing its path, the run fingerprint scopes a fact chain within that workspace, while the coordinator-event fingerprint is unique for each logical fact or transition and must remain stable when that fact is retried. An identical retry does not append a duplicate and regenerates the summary, including after a prior summary failure. Before recording coordinator facts, verify that the current execution route is `FullLanguage`; if it is `ConstrainedLanguage`, coordinator activation is blocked. After each fact, the script atomically refreshes the compact handoff summary. The summary labels itself as historical and shows the most recent recorded UTC time for each fact and observation row; timestamps describe evidence age, never live readiness. Treat a missing, legacy/unscoped, out-of-order, or incomplete fact chain as blocked; `HandoffBlocked` and any transition recorded before its prerequisites are terminally blocked for that workspace/run; later facts cannot restore readiness. An identical-event retry is deduplicated before rendering and does not create a new transition. Hook observation failures are fail-open, but a coordinator append or summary failure blocks handoff and must be reported. Keep audit records within the documented privacy boundary: do not add prompts, assistant/user messages, transcript paths, tool data, credentials, or raw workspace paths.

## 5. Choose models and reasoning deliberately

The coordinator chooses an explicit model and reasoning pair for every spawned role. Follow any recipient model-selection instruction, then confirm the pair against the active runtime capability surface. Do not rely on dated catalogs. Role files intentionally omit fixed model settings so they do not override that choice. Use the recipient model policy when supplied; otherwise select a supported pair suited to the bounded task. Record the task-specific reason for the selected pair; do not reproduce a separate selection policy here.

Default to a fresh subagent with a standalone brief containing the exact candidate, relevant paths, ownership or decision, prior findings, and required checks. Use `fork_turns="none"` with an explicit model and effort when supported. Use full-history inheritance when the task genuinely requires it. Keep the role files model-neutral so the coordinator can select a supported pair for each task.

Prefer Standard speed when conserving allowance. Use a lightweight model at low effort for routine discovery, receipt checks, and mechanical comparisons. Use stronger reasoning when implementation or review affects identity, durable state, recovery, permissions, or a difficult test failure. Record the choice and reassess when risk changes.

## Long-running validation

Launch each check once with an exact candidate, run ID, durable log, and exit receipt. Yield while the command runs. Read the receipt first on continuation or a completion signal, when available. If the receipt is missing, check the original handle before considering a restart. An observer timeout is distinct from a native result. Keep waiting for an active original run and report only meaningful changes.

Reproduce failures with a focused check. After repairs, repeat affected gates and carry earlier evidence forward only when the reviewer can justify it against the exact delta and test environment. Run the full suite when the acceptance gate requires it or when focused checks cannot cover the impact.

## 6. Prevent loop churn

- Allow at most **three total implementation-remediation cycles** after plan approval and at most **two QA reruns**. The coordinator may approve one additional cycle for a difficult, newly evidenced issue when it records why the existing cap would otherwise leave a material risk unresolved; a second exception requires a user decision.
- Fingerprint each finding by affected behavior, file/symbol, and failure evidence. Do not resend a resolved or duplicate finding.
- Re-run only reviewers whose relevant surface changed or whose named finding was fixed; do not repeat the full matrix by default.
- If the same finding recurs after a second remediation, a required check fails twice for the same cause, or a counter is exhausted, stop at **Needs coordinator decision**. Report evidence, plausible options, and the smallest decision needed from the user.
- A material scope or architecture change invalidates the plan revision: return to the planner and request fresh user approval before implementation resumes.
- Never make retries invisible. Record every transition and why it was allowed.

## 7. Skills and agent files

Use any relevant skills normally available to the coordinator or delegate. The supplied custom-agent TOML files deliberately omit `skills.config`, which preserves inherited skill access. Install the TOML files from `custom-agents/` into the user's Codex `agents` directory; see `references/role-cards.md` for their responsibilities.
