# Reviewer learning

Help the accountable reviewer understand unfamiliar code without constraining architecture or implying approval. The approved stack and actual diff determine the target languages and frameworks. The reviewer profile controls only explanation depth, analogies, and learning emphasis.

## Learning profile

Record what the reviewer provides or what is already established:

```yaml
reviewer:
  familiar_languages:
    - language: csharp
      level: familiar
  preferred_comparison_languages:
    - csharp
  target_familiarity: review-capable
  explanation_depth: focused
  delivery_mode: interactive
  learning_goals: []
```

This is an example, not a language allowlist. Accept any programming, query, configuration, infrastructure, or domain-specific language. Use `unknown` instead of inventing familiarity. Ask only when the missing preference would materially change the briefing; otherwise use plain language and cautious analogies. `interactive` is the default delivery mode when the Language Mentor runs. Honor a reviewer request for a one-shot briefing or to skip the teaching session.

Reviewer familiarity may be considered as one maintainability factor during architecture analysis, but it never automatically selects, rejects, or changes a stack. Keep the learning profile out of `APPROVED_STACK` and `EXISTING_STACK_CONFIRMED`.

## When to create a briefing

Create one when the reviewer requests it, the diff uses an unfamiliar language or framework, or non-obvious semantics materially affect review even in a familiar language. Record `LEARNING_BRIEFING_NOT_REQUIRED` only when the reviewer opts out or the change contains no meaningful learning or review aid.

For polyglot work, organize the briefing by component and add a cross-language contract section covering serialization, nullability, numeric and time representations, errors, authentication, versioning, generated clients, deployment ordering, and contract tests as applicable.

## Language Mentor contract

Provide `pipeline_language_mentor` the final diff, approved intent and architecture, test evidence, relevant surrounding code, reviewer learning profile, and resolved engineering findings. Require:

- a plain-language execution-path walkthrough;
- explanations of non-obvious syntax, semantics, framework lifecycle, and idioms;
- analogies to familiar languages only when useful, plus where each analogy breaks down;
- language- and framework-specific review risks tied to the actual diff;
- a test-to-behavior map;
- concrete questions the reviewer should be able to answer before approval;
- links to authoritative language or framework documentation when available;
- clear separation of verified behavior, interpretation, and unknowns;
- exactly one concern result: `NO_REVIEW_CONCERN` or `REVIEW_CONCERN`.

Do not recommend changing the approved stack merely because another language is more familiar. Do not produce a generic language tutorial, inflate obvious syntax, edit source, adjudicate findings, or approve the change.

If explaining the code reveals a plausible material defect or unsupported assumption, return `REVIEW_CONCERN` with locations and evidence. The coordinator must send it to the senior engineer before the Human Engineering Review Gate. Educational explanation is not correctness evidence and cannot replace a proficient human owner.

## Interactive delivery contract

The mentor response is internal pipeline evidence until the coordinator teaches it to the reviewer. Never treat the concern result, a summary that a briefing exists, or an internal agent completion as delivery.

By default, deliver the briefing as a short interactive teaching exercise before requesting human approval:

1. Organize the final candidate into small execution-path or component lessons in review order.
2. For each lesson, show the relevant final-candidate file or tight code excerpt, explain its purpose and non-obvious language or framework behavior, connect it to the approved requirement, and identify the tests that support it.
3. Ask one or more concrete comprehension or review questions that test whether the reviewer can reason about the code rather than merely repeat the explanation.
4. Pause for the reviewer after each lesson. Address misunderstandings or requested depth before continuing; do not silently answer the questions on the reviewer's behalf.
5. Finish with remaining risks, unknowns, and the questions the reviewer should resolve before approval.

Record the lessons delivered, reviewer questions or concerns, unresolved misunderstandings, and one completion state: `TEACHING_COMPLETED`, `ONE_SHOT_BRIEFING_REQUESTED`, or `TEACHING_SKIPPED_BY_REVIEWER`. Do not enter the Human Engineering Review Gate while teaching is incomplete. A one-shot briefing must still include the full mentor deliverable; never reduce it to `NO_REVIEW_CONCERN`.

If the mentor returns `REVIEW_CONCERN`, stop the teaching sequence and route that concern to the senior engineer first. Regenerate or update the briefing against the corrected candidate before resuming.

For a high-consequence change in a stack unfamiliar to the accountable reviewer, require an identified language- or framework-proficient human co-reviewer. If none is available, the Human Engineering Review decision must be `ESCALATE_TO_OWNER`; completing the briefing does not change that requirement.
