---
name: request-model-gate
description: "Show a brief minimum reliable model and reasoning-effort recommendation at the start of each new substantive objective; skip trivial requests and ordinary follow-ups."
---

# Request Model Gate

Show a brief model and reasoning-effort recommendation at the start of every new substantive objective, including when the current setting is suitable. Proceed without pausing when verified active settings meet the recommendation, the recommendation is unavailable, or the user clearly directs continuation with their current settings. Accept `Ready`, `r`, or `R` as clear intent to continue. When active settings are unknown or below the recommendation, acknowledge that distinction without falsely claiming verification or a switch. Otherwise present the checkpoint and wait for the user's choice. Never infer the active picker settings from the recommendation, model availability, or the assistant identity.

The objective is the **minimum reliable recommendation**, not the strongest available setting. Treat usage as a real constraint: recommend a more expensive model or higher effort only when the expected quality gain is necessary to complete this specific request safely and correctly. Do not use Astra as a precautionary default.

## When to gate

Invoke this skill before task work at the start of each new substantive objective, whether in a new project or an existing project. A new objective is a distinct requested outcome, not an ordinary follow-up toward the same outcome.

Substantive objectives include bounded implementation, non-trivial debugging, architecture or design decisions, research and synthesis, and consequential decisions. Always show the recommendation for these objectives, even when no setting change would help.

Skip trivial requests such as brief factual questions, status checks, simple explanations or rewrites, translations, formatting, narrow file discovery, straightforward commands, and small reversible edits with clear acceptance criteria, unless the user explicitly asks for a recommendation.

For borderline objectives, show a concise recommendation and proceed when the current setting is suitable. Do not make the visible checkpoint conditional on a switch being beneficial.

Do not repeat the checkpoint for ordinary follow-ups within the same objective, whether the previous checkpoint required a switch or proceeded immediately. Reassess if scope, risk, or complexity materially changes.

## Model checkpoint

Before browsing, inspecting files, drafting a plan, or doing task work **when the request meets the gate criteria**:

1. Classify the request by complexity, coding depth, research freshness, risk, tool use, latency sensitivity, and whether independent workstreams would help.
2. Validate model names and reasoning-effort options against the current Codex picker, then recommend one available model and effort. Do not rely on stale aliases or hard-coded model tiers.
3. Give one short reason and, when useful, a faster or cheaper fallback.
4. Always state the recommended model and reasoning effort with the short reason, then compare them with the verified active settings. Treat model and effort as separate settings: a model match alone does not establish an effort match. Do not infer picker settings from model availability, the assistant identity, or the recommendation itself.
5. If the recommended setting is unavailable, retain the current selection, say so, and proceed without a switch request. Otherwise, if either active setting cannot be verified from trusted session context or the user's latest confirmation, state that uncertainty and ask the user to confirm settings or signal readiness to continue with their current settings. Wait only until either instruction arrives; do not require exact wording.
6. If verified active settings meet the recommendation, say that no switch is needed and proceed. If an available recommended setting requires a change, end with: `Please switch to that model and reasoning effort, then reply Ready. I will wait.` End the turn immediately after this request; do not browse, inspect files, plan, or perform task work until the user confirms changed settings or directs continuation, including `Ready`, `r`, or `R`. A readiness reply permits current settings; it does not prove a switch occurred.
Accept `Ready`, `r`, and `R`, ignoring surrounding whitespace, as clear intent to continue with current settings. Do not ask again for model/effort confirmation for the same checkpoint. Preserve the recommendation and disclose unknown settings; readiness does not independently verify them or authorize unrelated external actions.
For requests outside the gate criteria, do the task immediately.

Use a lightweight scoring rubric rather than a rigid lookup table. Consider these dimensions independently:

- Scope: one file or localized behavior versus multiple files, packages, or systems.
- Ambiguity: clear failure and acceptance criteria versus an unclear root cause or requirements.
- Risk: easy-to-revert changes versus security, data, migration, production, or other costly consequences.
- Reasoning depth: a mechanical edit or known pattern versus architecture, competing designs, or subtle behavior.
- Verification: fast targeted tests versus broad, integration, flaky, or otherwise difficult validation.

Choose the model tier and reasoning effort separately. Follow this escalation ladder, subject to what the current picker makes available:

- **Luna at none or low:** narrow factual, status, formatting, file-discovery, and straightforward command requests. Usually do not gate these tasks.
- **Terra at low or medium:** clear, bounded implementation; routine troubleshooting; focused research; and modest multi-file changes with targeted verification.
- **Sol at medium:** the default for substantial professional work—broad but understandable implementations, non-trivial debugging, design tradeoffs, or several connected workstreams. Do not skip Sol merely because a task is technical, tool-heavy, or spans multiple files.
- **Sol at high:** hard but bounded investigations, ambiguous failures, complex designs, or verification that needs careful synthesis. Start here before Astra when Sol plausibly has enough capability.
- **Astra at low or medium:** reserve for the hardest end-to-end work where there is a concrete reason Sol is unlikely to complete the task reliably: unusually deep cross-domain reasoning, an unresolved hard problem after a Sol attempt, a long-horizon investigation with interacting unknowns, or a consequential decision that must synthesize difficult evidence. State that concrete reason in the recommendation. Never choose Astra solely because the task is important, high-risk, multi-file, tool-intensive, parallelizable, or because two rubric dimensions are elevated.
- **High, xhigh, max, or ultra:** increase effort one step at a time only when lower effort is unlikely to resolve the actual ambiguity or verification burden. Reserve xhigh/max for demonstrated or clearly exceptional difficulty; reserve ultra or multi-agent work for genuinely independent streams whose coordination benefit exceeds the added usage.

For borderline cases, prefer Terra at medium for clear bounded work and Sol at medium for substantial or ambiguous work. A high-risk label alone does not justify Astra: prefer targeted verification, safer execution, and Sol unless the task also meets Astra's concrete-reason test. Escalate only after new evidence reveals greater scope, ambiguity, risk, or verification difficulty than initially indicated. Do not automatically raise both model tier and effort for the same factor. If the selected model is user-specified, preserve it and recommend only an appropriate effort, explaining any capability conflict instead of silently substituting.

If the user explicitly selects a model, preserve that choice and recommend only the reasoning effort unless the selected model is unavailable or clearly cannot perform the requested modality. Explain any conflict instead of silently substituting another model.

## Safety exception

Do not delay essential guidance when the request indicates imminent medical danger, poisoning, fire, violence, self-harm, or another time-critical threat. Give the immediate safety action first, then provide the model recommendation only if continued non-urgent analysis would help. Never make emergency help conditional on changing models.
