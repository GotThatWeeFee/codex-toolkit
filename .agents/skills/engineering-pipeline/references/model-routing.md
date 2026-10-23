# Model routing gate

Choose the least costly available model and reasoning effort that can reliably complete each stage. This workflow uses the active Codex subscription session; do not introduce API credentials or API-backed execution.

## Classify the stage

Assess the stage independently on two axes:

- **Decision difficulty:** ambiguity, novelty, architectural breadth, amount of cross-file reasoning, unfamiliar technology, subtle failure modes, or unresolved disagreement.
- **Consequence level:** potential for security or privacy harm, data loss, financial impact, regulatory exposure, production outage, difficult rollback, or a widely reused architectural commitment.

Use repository evidence rather than project size alone. A large mechanical edit can be low difficulty, while a small authorization change can be high consequence.

## Baseline routes

These are defaults, not permanent role assignments:

| Stage | Ordinary route | Use a lighter route when | Escalate when |
| --- | --- | --- | --- |
| Planner | `gpt-6.1-sol`, medium | `gpt-6-luna`, medium for a narrow brownfield plan with an established pattern | Sol, high for unresolved architecture or subtle cross-system decisions |
| Implementer | `gpt-6.1-sol`, medium | `gpt-6-luna`, low or medium for a narrow, repetitive, well-tested change | Sol, high for complex algorithms, concurrency, large refactors, or unfamiliar integrations |
| Documentation agent | `gpt-6.1-sol`, medium | `gpt-6-luna`, medium for bounded updates with verified stack and existing standards | Sol, high for unresolved polyglot contracts or consequential conflicting rules |
| Specialist reviewer | `gpt-6.1-sol`, medium | `gpt-6-luna`, medium for a narrow documentation, API-usage, or deterministic test-quality lens | Sol, high for security, authorization, privacy, data integrity, concurrency, or irreversible migrations |
| Senior engineer | `gpt-6.1-sol`, medium | `gpt-6-luna`, medium for a small, low-risk, conventional diff with complete evidence | Sol, high for consequential boundaries or material architectural dissent |
| QA | `gpt-6.1-sol`, medium | `gpt-6-luna`, low or medium for deterministic reruns with a fully specified test contract | Sol, high for subtle state behavior, complex negative paths, or consequential failure analysis |
| Final reviewer | `gpt-6.1-sol`, medium | `gpt-6-luna`, medium for a small, low-risk diff with complete independent evidence | Sol, high for production-sensitive or difficult-to-reverse changes |
| Language mentor | `gpt-6-luna`, medium | Luna, low for a short explanation of familiar syntax | `gpt-6.1-sol`, medium for cross-language semantics, framework lifecycle, concurrency, or consequential explanations |

Validate model identifiers and supported reasoning efforts against the current Codex host before dispatch. These routes were refreshed on 2026-10-04 using the [official model catalog](https://developers.openai.com/api/docs/models) and [GPT-6.1 Sol documentation](https://developers.openai.com/api/docs/models/gpt-6.1-sol). API documentation establishes model capabilities; the host determines availability for subscription-backed dispatch. Sol supports low and above; do not select none or minimal for GPT-6.1 Sol.

Reserve `gpt-6-astra` for a concrete unresolved problem that Sol at high is unlikely to complete reliably, or after a Sol attempt exposes a capability limit. A consequential task or senior role alone does not justify Astra. Keep older models available as explicit fallbacks or user-selected routes rather than treating a release as proof of better results on every task.

If these model identifiers are unavailable, choose the closest available model with the same role in the local model picker and record the fallback. Do not silently replace a requested route.

When the dispatch mechanism cannot combine a model override with full conversation inheritance, use a bounded or context-free dispatch and provide the complete task contract and required handoff evidence explicitly. Never trade away essential repository constraints or acceptance criteria merely to enable a cheaper model.

## Reasoning effort

- **Low:** deterministic, narrow, reversible work with strong existing examples and straightforward verification.
- **Medium:** the default for ordinary professional engineering work and balanced review.
- **High:** complex logic, ambiguous requirements, subtle edge cases, consequential reviews, security boundaries, data integrity, concurrency, or hard-to-reverse decisions.

Do not use `xhigh`, `max`, or `ultra` by default. Reserve them for an explicit user or organizational policy, or an exceptional task where high effort has already proven insufficient and the additional usage is justified.

## Dynamic reassessment

Escalate a later stage or repeat cycle when one or more of these are present:

- low confidence supported by a concrete unresolved question;
- a senior, QA, or final-review finding reveals a broader failure mode than the original task assumed;
- two agents materially disagree and neither position is resolved by repository or test evidence;
- the change crosses a security, privacy, data-integrity, financial, regulatory, or irreversible boundary;
- validation is nondeterministic or failures cannot be reproduced at the current reasoning level.

Do not escalate solely because a routine test failed, an agent produced a long response, or a stage is named "senior" or "final." Prefer better-scoped context, clearer acceptance criteria, or deterministic evidence when those address the problem more directly.

De-escalate repeated work when the task has become bounded and mechanical, such as applying an already-approved correction or rerunning deterministic tests. Reviews of the corrected result remain independent even when a lighter model is selected.

## Audit record

Before dispatch, record:

```yaml
role: pipeline_senior_engineer
cycle: 1
model: gpt-6.1-sol
reasoning_effort: high
decision_difficulty: high
consequence_level: high
reasons:
  - authorization boundary changed
  - negative-path behavior requires independent review
fallback: null
```

At completion, preserve the actual setting used beside the stage's evidence and gate decision. The record explains the routing decision; it is not evidence that the work is correct.
