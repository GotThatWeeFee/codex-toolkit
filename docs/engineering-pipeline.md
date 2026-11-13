# Engineering pipeline

`engineering-subagent-pipeline` is an approval-gated coordinator workflow for non-trivial development work. It is not a mandate for a small one-file change or a standalone review.

## Flow

1. **Discover and plan:** inspect project instructions, implementation, configuration, tests, documentation, and change state; classify the project and documentation impact; identify established patterns, observable quality criteria, and refactoring required for the change.
2. **Approve:** material features, architecture/contracts, migrations, authorization-sensitive work, shared-environment impact, or unresolved decisions use the standard lane and wait for explicit approval. Faster-lane eligibility is recorded, not assumed.
3. **Implement:** one junior developer owns source, tests, configuration, and routine documentation. A documentation specialist owns only explicitly assigned substantial guides after behavior is settled.
4. **Review and remediate:** use relevant read-only specialists, record finding IDs/dispositions/dissent, and re-run only reviews affected by corrections.
5. **Gate:** senior review explicitly checks maintainability against planned quality criteria and returns concrete required corrections to the implementation owner before authorized QA. Final review reconciles the complete working tree before coordinator handoff.

The implementation owner checks code quality before handoff. The senior reviewer independently checks duplicated rules, unclear responsibilities, unnecessary complexity, coupling, and departures from established patterns. Findings need evidence, a concrete maintenance consequence, and a bounded correction. Required corrections return to the same owner and are re-reviewed within the existing remediation budget. Broader cleanup is recorded with scope, rationale, proposed owner, and risk; preferences alone do not block progression. A substantial refactor needs its own approved scope, behavior invariants, and authorized validation, performed sequentially by the implementation owner. The workflow adds no automatic refactor agent or cleanup phase.

The coordinator owns routing and phase progression. Candidate evidence binds baseline HEAD, initial state, patch, and relevant non-patch hashes, including instructions and docs; byte changes invalidate affected review evidence. The workflow distinguishes implemented, planned, and unknown behavior and preserves already authorized project constraints.

## Roles and authorization

The 13 canonical role files deliberately omit fixed model settings; the coordinator selects currently supported model/reasoning under recipient policy. A recommendation never switches the active model. Install roles separately as described in [installation](installation.md); plugin packaging alone does not prove automatic registration.

Give each role a standalone brief with the candidate, scope, and evidence paths. Route routine checks to a lightweight model and use stronger reasoning where the change warrants it. For long tests, retain the run ID, log, and native exit receipt and consult them before restarting. After a correction, rerun the affected checks and document why any earlier evidence still applies.

Neither a skill, plan, nor role authorizes tests, Git changes, connector writes, live runs, deployments, or publication. The normal remediation budget is three implementation cycles and two QA reruns; exceptions require visible coordinator reasoning or a user decision.

## Optional audit facts

When separately authorized, the metadata-only audit helper can record ordered coordinator facts using a recipient-approved local audit root and opaque precomputed fingerprints. Observations are historical evidence only; they do not establish approval, trust, completion, or live readiness.
