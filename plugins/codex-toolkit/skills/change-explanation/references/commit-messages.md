# Detailed commit messages

Return a ready-to-copy commit subject and body, normally in one text code block. Follow repository subject conventions and include a verified issue key when applicable. A request for a message authorizes drafting; it does not authorize staging, committing, pushing, running tests, deploying, or making live writes.

## Gather evidence

Inspect the applicable diff and relevant implementation, tests, configuration, scripts, and project instructions. Honor an explicit staged, branch, or file scope. Otherwise use the current task context and worktree status to identify the intended changes; inspect staged, unstaged, and relevant untracked files so nothing in scope is missed. Ask only when materially different candidate scopes remain unresolved. Do not include unrelated user edits.

Use actual commands, test names, flags, working directories, environment settings, and output locations found in the project. Never invent a command or assume a generic test command exercises live integrations. If a procedure cannot be established, identify the exact missing command or prerequisite and mark that part of the walkthrough incomplete.

Include task-wide experiments and consequential configuration decisions even when they are not visible in the final diff. For model evaluations, record the supplied prompt versus deployed agent instructions, model and reasoning settings, planned/completed counts, acceptance and transport outcomes, semantic-reference method, relevant latency/retry observations, and the recommendation or selected setting. Distinguish user-reported external agent changes from repository configuration and provider-attested identity. Preserve cohort, prompt-version, and reference-quality limits.

## Required message content

Keep every section below, scaling its detail to the change. Use "Not applicable" with a concrete reason when a category does not apply, or "Not run" / "No recorded results available" when evidence is absent.

1. **Changes:** Provide a detailed breakdown grouped by behavior or component, accounting for every in-scope file. Explain what changed, why, how the relevant code works, and the observable before-and-after behavior. Include configuration, compatibility, error handling, and integration effects when affected.
2. **Previous results:** Report the available pre-change results with date, revision/environment, command or scenario, pass/fail/skip counts, failures, and artifact locations where known. Distinguish recorded test results from behavior inferred from source. Do not reuse historical results as evidence for the current revision. If no baseline was run or supplied, state that explicitly.
3. **Current observed results:** Record only checks actually performed, with their scope and outcome, warnings, blockers, and untested boundaries. Distinguish build, automated test, manual, and live evidence. Preserve failures and skipped checks; do not imply a live workflow passed because a build or unit test passed.
4. **How to test locally:** Give a numbered walkthrough covering prerequisites, working directory, setup, exact commands or UI actions, inputs, expected observations at each step, and where to inspect logs or output. Include the relevant regression and error cases established by the changes. Make the steps executable without reconstructing the conversation.
5. **How to test live:** Always include a separate numbered walkthrough for relevant live integrations. State the environment and target, required access and configuration variable names without secret values, test data, exact opt-in command/filter/flags or UI actions, and expected evidence in each external system. Include publishing/write settings, relevant side effects, cleanup, and stop conditions when applicable. Preserve project safeguards and default to a non-publishing or read-only mode where supported; distinguish that coverage from a real write/publish test. Mark any further authorization needed for live writes. If no live test exists, state that and give a source-grounded manual integration walkthrough where feasible; otherwise identify the missing procedure. If live testing does not apply, explain why.
6. **Expected results after testing:** Describe concrete pass criteria for each local and live scenario, the old failure or behavior that should change, and behavior that should remain stable. Tie these expectations to implementation or requirements, including external state and output fields where relevant. Label them as expected until actually observed; do not invent passing totals, scores, timings, or live outcomes.

## Portable test instructions and evidence attachments

Start local instructions at the repository root using repository-relative paths. Never require a personal username, drive, checkout, or worktree location. When an absolute path is required by a tool, derive it with the platform's path-resolution command. Include restore/build prerequisites before commands using no-restore or no-build; retain verified project filters and opt-in safeguards.

When the user requests before/after files, provide separate attachable files and a comparison, using existing evidence where available. Label derived summaries as derived, preserve source/run provenance, compare matched cases where possible, and distinguish workflow acceptance from semantic correctness. State unmatched cohorts, prompt/revision differences, missing historical captures, and final-run coverage gaps. Never fabricate raw responses, combine separate runs into a passing cohort, or expose customer narratives or credentials. A request for attachments does not itself authorize new tests or live calls.

## Suggested layout

Use this structure inside the commit body, replacing prompts with project-specific content:

```text
<subject>

Changes
- <component/files, reason, implementation, and before/after behavior>

Previous results
- <recorded baseline and its scope, or no recorded results>

Current observed results
- <checks actually performed, outcomes, and gaps>

How to test locally
1. <prerequisites and working directory>
2. <setup and exact command/action>
3. <expected observation and evidence to inspect>

How to test live
1. <target, access, configuration, test data, and authorization prerequisites>
2. <exact opt-in command/action and relevant write settings>
3. <expected external evidence, cleanup, and stop conditions>

Expected results after testing
- <scenario-specific pass criteria; clearly marked as expected>
```

Before returning the message, check that every change claim has evidence, each walkthrough has actionable steps and expected observations, historical and current results are distinct, and proposed testing is never reported as completed. A follow-up asking only to shorten or reformat the drafted message may narrow this format as the user directs.

## Evidence attachments

When the user asks for MR/commit evidence files or attachable evidence, look for relevant outputs already produced during the task and bundle the smallest useful set when practical. Provide the bundle as a direct chat link, with a README that records each file's source, whether it is captured or reconstructed, what it supports, and material limits. Prefer sanitized, focused excerpts over full logs or payloads. Never present a reconstruction as a captured before/after run, expose secrets or PII, or imply the bundle proves more than its evidence supports. If no suitable evidence files exist, say so and offer only evidence-grounded alternatives. Creating a bundle does not authorize running tests, live calls, or uploading/publishing it to an external service.
