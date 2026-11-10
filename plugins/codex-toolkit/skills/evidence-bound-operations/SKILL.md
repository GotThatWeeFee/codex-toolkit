---
name: evidence-bound-operations
description: Diagnose, change, validate, or deploy integration and operational systems while distinguishing source, artifact, configuration, and live-system evidence.
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# Evidence-Bound Operations

Use this skill for reliability, incident, deployment, integration, and operational work where a conclusion can be invalidated by a mismatch between source, artifacts, configuration, or the running system.

## Classify Evidence

State which of these categories supports each material conclusion:

- **Source evidence:** repository code, tests, and configuration templates.
- **Artifact evidence:** the built or published files that would run.
- **Runtime-configuration evidence:** settings, service definitions, schedules, and environment variables actually in use.
- **Live-system evidence:** current logs, telemetry, external APIs, databases, indexes, and query plans.

Do not infer evidence in one category from evidence in another. In particular, a source fix does not establish deployment, and historical logs do not establish current runtime behavior.

## Work Safely

- Recheck time-sensitive state before acting; do not reuse dated environment identifiers, schedules, artifact paths, or operational conclusions as current facts.
- Treat read-only diagnosis, a local build, and a proposed runbook as distinct from a live change.
- Apply the shared authorization policy in the applicable AGENTS.md to deployments, production calls, external writes, destructive recovery, publishing, and schedule changes. Check that existing explicit authorization covers the exact action and target; ask only for a new scope or consequential unresolved choice.
- Preserve secret-bearing and environment-specific configuration. Do not copy it into source control, examples, logs, or deliverables.

## Close the Loop

For a change, verify the narrowest safe evidence chain available: source and any authorized test evidence, artifact identity, target configuration, then live behavior when authorized. Report each unavailable link as a verification gap, not as a passed check.

Present investigation findings, evidence boundaries, and remaining questions in the chat by default. Add a report to the project only when the user requests a durable repository artifact or the investigation results in a lasting change to project guidance. Keep sensitive or temporary evidence in appropriate ignored locations and link to it from chat rather than adding it to tracked project documentation.
