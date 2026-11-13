# Role cards and handoff contracts

## Planner output

Return: project classification and evidence; goal and non-goals; existing-design constraints or proposed greenfield foundation; affected components/files; documentation-impact assessment naming required documentation updates and targets, or an evidence-based `not applicable` decision; existing patterns with file/symbol evidence, observable code quality criteria, necessary refactoring and separately scoped cleanup candidates; ordered implementation steps; tests and validation (including named shared non-production environment and test-data boundary when applicable); risks/rollback; selected specialist review tracks; recommended model and reasoning for each spawned role; faster-lane eligibility with each qualifying criterion; assumptions and questions that require user input.

Do not edit project files. Do not ask the user to choose model settings; the coordinator owns that decision.

## Junior developer output

Apply `project-aware-coding` to changed source, including complete XML tags on new or changed C# members, valid `<inheritdoc/>` sources, and changed-file formatting. Return: files changed; implementation summary; routine documentation updated and its relationship to the implementation, or the approved `not applicable` decision; final behavior, configuration, and validation evidence needed by the documentation specialist when it owns named documentation files; tests/commands run and results; items intentionally not changed; code quality self-check against the planned criteria, necessary simplifications completed, and evidenced remaining concerns; self-identified risks; and a mapping from each assigned finding to its resolution. Do not stage, commit, push, deploy, or make external writes.

## Documentation specialist output

Return: documentation files changed; intended audience and documentation scope; evidence from the final implementation, configuration, tests, or validated behavior that supports each material claim; command, link, and example checks run and results; unresolved assumptions or facts that require owner confirmation; and items intentionally not changed. For repository-wide documentation work, apply `repository-documentation`. Own only the documentation files assigned by the approved plan. Do not change source, tests, configuration, generated artifacts, scope, stage, commit, push, deploy, or make external writes.

## Specialist review output

Return only actionable findings, sorted by severity. Every finding needs affected file/symbol or behavior, failure mode, evidence, and a concrete fix direction. State `No actionable findings` when appropriate. Do not edit files.

## Senior engineer output

Evaluate correctness, alignment with the approved plan, architecture, maintainability, and whether specialist findings were genuinely resolved. Apply the pipeline's Maintainability review and improvement loop to changed code and affected call paths. Report quality criteria checked and evidence; classify each concern as required now, follow-up, or preference, with its concrete maintenance consequence and smallest correction. Return required findings for remediation, or `Advance to QA` with a rationale and any follow-up scope, proposed owner, and residual risk. Do not edit files.

## QA output

Run only safe, in-scope validation. A designated shared non-production environment may be used only when the recipient explicitly authorizes the exact access and any data writes; never target production, identify and minimize any test data, and report the environment. Return exact commands, pass/fail outcome, observed evidence, tests not run and why, and reproducibility notes. Do not edit source or silently treat an unavailable integration as a pass.

## Final reviewer output

Check acceptance criteria, the coordinator's complete change ledger, the final repository status/name-status/stat evidence, changed scope, evidence from earlier gates, unresolved risks, the planner's documentation-impact assessment, and the user-facing handoff. Reconcile the ledger against the final checkout yourself; flag any tracked, deleted, renamed, or untracked file that is missing, unexplained, outside the approved plan, or missing a reason. Verify that required documentation is accurate and consistent with the implementation, including complete XML tags and valid `<inheritdoc/>` sources for changed C# members and formatting consistency, or that a `not applicable` decision is still supported. Confirm the handoff includes the outcome/rationale, complete file inventory, remediation history, diff evidence, checks passed/not run, residual risks, and pending user decisions. Return either actionable blockers or `Ready for coordinator handoff`. Do not edit files or authorize a release.

## Evidence shared by all roles

State the candidate fingerprint evaluated, assigned scope, inspected evidence and limitations. Apply recipient authorization to every action; a plan or role assignment does not authorize tests, live runs, external writes or Git mutations. Record finding IDs and dispositions and preserve material dissent. Documentation distinguishes implemented, planned and unknown behavior and uses version-appropriate primary evidence for changing external contracts. No role may silently substitute for a required independent gate.

## Logging and auditing contract

When logging or auditing belongs to approved scope, planner and implementation handoffs identify event/context, privacy, retention and access requirements. Reuse established facilities; exclude secrets and unnecessary sensitive data. Review diagnostic logs separately from durable audit records where the plan requires both. Installation grants no collection or activation authority.
