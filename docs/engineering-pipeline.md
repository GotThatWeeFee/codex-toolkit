# Engineering pipeline

`engineering-subagent-pipeline` is an approval-gated coordinator workflow for non-trivial development work and its related follow-ups. Independent small one-file changes and standalone reviews do not require it; related questions, reviews, and corrections continue the existing workflow even after handoff.

## Flow

1. **Discover and plan:** inspect project instructions, implementation, configuration, tests, documentation, and change state; classify the project and documentation impact; identify established patterns, observable quality criteria, and refactoring required for the change.
2. **Approve:** material features, architecture/contracts, migrations, authorization-sensitive work, shared-environment impact, or unresolved decisions use the standard lane and wait for explicit approval. Faster-lane eligibility is recorded, not assumed.
3. **Implement:** one junior developer owns source, tests, configuration, and routine documentation. A documentation specialist owns only explicitly assigned substantial guides after behavior is settled.
4. **Review and remediate:** use relevant read-only specialists, record finding IDs/dispositions/dissent, and re-run only reviews affected by corrections.
5. **Gate:** senior review explicitly checks maintainability against planned quality criteria and returns concrete required corrections to the implementation owner before authorized QA. Final review reconciles the complete working tree before coordinator handoff.

The implementation owner checks code quality before handoff. The senior reviewer independently checks duplicated rules, unclear responsibilities, unnecessary complexity, coupling, and departures from established patterns. Findings need evidence, a concrete maintenance consequence, and a bounded correction. Required corrections return to the same owner and are re-reviewed within the existing remediation budget. Broader cleanup is recorded with scope, rationale, proposed owner, and risk; preferences alone do not block progression. A substantial refactor needs its own approved scope, behavior invariants, and authorized validation, performed sequentially by the implementation owner. The workflow adds no automatic refactor agent or cleanup phase.

The coordinator owns routing and phase progression. Candidate evidence binds baseline HEAD, initial state, patch, and relevant non-patch hashes, including instructions and docs; byte changes invalidate affected review evidence. The workflow distinguishes implemented, planned, and unknown behavior and preserves already authorized project constraints.

## Follow-up questions and fixes

The coordinator restores the approved intent, ownership, candidate, findings, counters, and evidence, then reconciles them against the current checkout. An explanation question can be answered from inspected evidence without running every role; a question alone does not authorize edits. A requested correction returns to the implementation owner, or a replacement of the same role with a restored handoff. One-file corrections follow this continuation path too.

After a correction, refresh the candidate and repeat affected specialist reviews, senior review, authorized QA, and final review. Select any newly affected review tracks. Retain earlier evidence only with a justification for its continued applicability, and identify checks not run against the new code. In-scope fixes retain existing decisions and approval; material scope or architecture changes return to planning. Missing context or unavailable roles must be reported rather than replaced with assumed approval or coordinator-only gates.

Carry finding IDs, unresolved blockers, correction history, and cumulative remediation budgets across turns and handoffs. A follow-up does not reset a budget. If optional audit facts are enabled and the earlier run has a terminal handoff, preserve it and link a new run while carrying forward counters and findings. See the skill's continuation section for the canonical procedure.

## Roles and authorization

The 13 canonical role files deliberately omit fixed model settings; the coordinator selects currently supported model/reasoning under recipient policy. A recommendation never switches the active model. Install roles separately as described in [installation](installation.md); plugin packaging alone does not prove automatic registration.

Give each role a standalone brief with the candidate, scope, and evidence paths. Route routine checks to a lightweight model and use stronger reasoning where the change warrants it. For long tests, retain the run ID, log, and native exit receipt and consult them before restarting. After a correction, rerun the affected checks and document why any earlier evidence still applies.

Neither a skill, plan, nor role authorizes tests, Git changes, connector writes, live runs, deployments, or publication. The normal remediation budget is three implementation cycles and two QA reruns; exceptions require visible coordinator reasoning or a user decision.

## Optional audit facts

When separately authorized, the metadata-only audit helper can record ordered coordinator facts using a recipient-approved local audit root and opaque precomputed fingerprints. Observations are historical evidence only; they do not establish approval, trust, completion, or live readiness.
