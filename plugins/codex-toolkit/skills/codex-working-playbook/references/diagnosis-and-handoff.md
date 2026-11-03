# Diagnosis Before a Patch

Use when the user reports a defect and evidence is incomplete. Keep it concise and fill only what is useful:

- **Observed failure:** Exact symptom, operation, and evidence.
- **Current identity:** Checkout, build, restored dependency, or effective configuration.
- **Most likely cause:** A falsifiable explanation and its supporting evidence.
- **Alternative:** The closest credible alternative and how to distinguish it.
- **Smallest next inspection:** One step that changes confidence.

Then diagnose before proposing a focused fix. Do not patch around an unverified API or business assumption.

## Focused debugging techniques

- State one falsifiable hypothesis and the observation that would distinguish it from the nearest alternative. Inspect or change one meaningful variable at a time rather than bundling speculative fixes.
- Compare the failing path with a working equivalent, including inputs, effective configuration, dependency versions, and lifecycle. Explain relevant differences before copying its implementation.
- Trace an invalid value or failure backward through callers to the first incorrect input or decision. At service/process boundaries, inspect relevant input/output shape and configuration identity without capturing secrets or sensitive payloads.
- Keep a brief record of attempted fixes and what each established. After repeated failures (roughly three distinct failed hypotheses), pause the patch loop and reconsider the root cause, architecture, and missing evidence. Escalate a consequential design decision under existing authorization rules; do not force another speculative patch.
- Distinguish evidence gathering from tests and live execution. These techniques do not authorize tests, external writes, Git mutations, deployment, or a broader implementation scope.

# Portable Handoff

Use when context must move to another chat. Include only current, actionable context:

- Goal and acceptance.
- Repository, worktree, branch, and revision when the work involves a checkout.
- Dirty changes and ownership.
- Approved decisions and business invariants.
- Exact package, prompt, or effective configuration identity only when it affects the next action.
- Completed changes and paths.
- Evidence obtained and where it lives.
- What remains unproven.
- Open hypothesis or blocker.
- Next smallest action.
- Authorization still in force and any boundary requiring a new decision.

Keep it short enough to use without rereading the transcript. Exclude secrets, obsolete alternatives, and full tool logs.


## Source and license

Adapted from the following upstream snapshots (retrieved 2026-11-03). Local guidance narrows scope and preserves task authorization.

- [debugging](https://raw.githubusercontent.com/obra/superpowers/2ce8aa15d05bd57213e6f746f953aafb7ded7a8b/skills/systematic-debugging/SKILL.md)

Upstream license: [superpowers-LICENSE.txt](superpowers-LICENSE.txt).
