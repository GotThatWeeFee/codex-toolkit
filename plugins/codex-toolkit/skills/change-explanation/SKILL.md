---
name: change-explanation
description: Explain code changes and draft detailed commit messages from the actual diff and inspected call paths. Use whenever the user asks for a commit message, including changes, step-by-step local and live test instructions, previous results, and expected results; also use for implementation, debugging, refactoring, and code reviews.
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# Change Explanation

## Commit message requests

Whenever the user asks for a commit message, read [references/commit-messages.md](references/commit-messages.md) and return a ready-to-copy subject and detailed body following that guide. Include the change breakdown, previous test results, current observed results, expected results after testing, and numbered local and live testing walkthroughs inside the message itself. Preserve the ordinary explanation workflow below for other requests.

After changing or reviewing code, give the user an evidence-backed explanation that makes the change understandable without requiring them to reconstruct the diff.

Account for every changed file in scope, including relevant untracked files, and distinguish pre-existing user changes from the changes being explained. Verification reporting follows the applicable AGENTS.md; an explanation request does not authorize adding or running tests.

Base every claim on the current diff and the relevant source, tests, configuration, or call paths that were inspected. Do not infer that a workflow was exercised merely because a build or unit test passed. Clearly label unknown or unverified effects.

## Explain cohesive behavior

Group related edits into a single change. Do not narrate every changed line unless the user asks for a line-by-line walkthrough. For each meaningful change, explain:

- **What changed:** The observable before-and-after behavior and the files or components involved.
- **Why it changed:** The requirement, defect, compatibility constraint, safety concern, or simplification it addresses. Do not invent a rationale; state when intent is not established by the request, issue, or source evidence.
- **How it works technically:** The relevant control flow, branching, data transformation, validation, state transition, error handling, API interaction, persistence behavior, or dependency boundary. Connect the explanation to identifiers from the code where that improves clarity.
- **Workflow impact:** Callers, user journeys, jobs, integrations, storage, configuration, deployment behavior, compatibility, or operational consequences that are directly affected. Distinguish direct impact from likely-but-unverified downstream impact.
- **Risk and verification:** Regressions worth watching; checks performed and what each check establishes; remaining untested boundaries, especially external services and live environments.

## Reporting standard

Lead with a short change summary, then use one subsection per cohesive behavior. Keep it proportionate: simple local edits need brief explanations; cross-cutting changes need a clear flow from entry point to affected boundary.

Use this structure when it improves readability:

```md
## Change summary

### <behavior or component>
- Changed: <before-and-after behavior>
- Why: <evidence-backed reason>
- Technical behavior: <how the relevant code executes>
- Workflow impact: <direct effects and qualified downstream effects>
- Verification: <checks run, their scope, and remaining gaps>
```

When no code was changed, say so plainly and describe only the review findings or investigation evidence. Link changed workspace files when possible. Avoid claiming production, deployment, authorization, data migration, or external-integration success unless it was explicitly verified.
