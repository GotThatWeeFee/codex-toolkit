---
name: codex-working-playbook
description: Use when substantive work needs a structured task brief, root-cause diagnosis before changes, or a portable handoff between chats. Load only the relevant template; avoid ceremony for simple requests.
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# Codex Working Playbook

The assistant derives and maintains a concise internal task brief from the user request and inspected context. Track only the outcome, acceptance conditions, invariants, scope, relevant identity, operating constraints, authorized actions, evidence, and consequential decisions that materially affect the work. Do not make the user fill out or restate a template. Surface a short brief only when it helps a decision or the user requests it; ask only for a consequential missing detail.

Report investigation findings, evidence, and handoffs in the chat by default. Do not add investigation reports, task summaries, or handoff notes to project documentation unless the user requests a repository artifact or the work changes durable project guidance that belongs there. Keep temporary evidence in ignored task artifacts when needed, and link to it in chat.

- For a new substantive task or plan, use [task-contract.md](references/task-contract.md).
- For debugging before a patch, use the diagnosis section in [diagnosis-and-handoff.md](references/diagnosis-and-handoff.md).
- When carrying work into another chat, use the portable handoff section in [diagnosis-and-handoff.md](references/diagnosis-and-handoff.md).

For an explicitly requested ten-task workflow trial, use [ten-task-trial.md](references/ten-task-trial.md). Do not introduce a scorecard into unrelated tasks.

The applicable AGENTS.md owns shared model-selection, task-scope, verification, and authorization policy. Follow it rather than reconstructing that policy here. A template never grants permission for external writes, live tests, Git mutations, or deployment.
