# Inspect, reuse, and close subagent threads

The coordinator owns lifecycle management before each dispatch and after each stage.
Check actual exposed capabilities rather than assuming a close tool exists. The
[official subagent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents)
describes an open-thread cap and closing completed threads; the current tool surface
determines whether this run can perform that operation. Runtime concurrency and
configured open-thread limits may differ. An unset configuration uses a default;
do not invent its effective value or equate it to a lifetime spawn budget.

## Registry and durable handoff

Maintain a compact run registry outside reviewed candidate files unless the record
itself belongs in the approved deliverable. For each agent record:

- Stable ID/name, role, actual model/effort, assigned scope, and current task
- Last observed state and observation time: running, idle/completed, failed, or unknown
- Latest candidate fingerprint, result/findings, validation and evidence location
- Keep/reuse/close decision and reason; close request/result and confirmed status

Before closing, preserve the substantive handoff: approved intent/architecture,
ownership, candidate identity, commands/results, findings/dispositions, unresolved
questions, and enough context to resume a bounded correction. A chat title or bare
PASS is insufficient. Never save secrets or rely solely on a disappearing UI item.
Closing does not invalidate preserved review evidence for unchanged candidate bytes.

## Before dispatch

1. Inspect the current task's live-agent inventory using its supported list operation.
   Reconcile it with the registry; do not infer open/closed from completion alone.
2. Reuse an available agent of the required role for related work through a supported
   follow-up/resume operation. Give the new candidate and full correction contract.
   Do not impersonate another custom role to work around capacity.
3. Retain agents expected to own near-term corrections or clarification. Prefer keeping
   the implementer and documentation owner while correction loops remain possible.
   Process independent review lenses sequentially when capacity is tight.
4. Close only completed, task-owned threads whose handoffs are preserved and whose
   immediate responsibilities are finished. Do not close running work, agents awaiting
   unresolved required evidence, unrelated chats, or the primary coordinator.
5. Invoke an actual exposed close operation (or a supported product control) when
   available. Record its result and inspect the inventory again. Mark CLOSED only
   after explicit confirmation; do not claim the slot was released without evidence.
6. Dispatch the next stage within observed capacity. Avoid repeated unchanged polling
   or speculative creation attempts. No configuration-limit increase is automatic.

When a retained owner or reviewer must be closed, preserve its ownership and full
handoff first. If later correction requires it, resume it only if the runtime supports
that; otherwise dispatch a replacement of the same role with the restored contract.
Record the substitution, route model/effort again, and reapply the ordinary correction
and candidate gates. This is an explicit ownership transfer, not simulated review.

## After a stage or capacity failure

After a stage, save its result and decide whether to retain it for corrections or close
it. A completed stage is not automatically a closed thread. Close terminal read-only
stages once their evidence is preserved and no immediate clarification is pending.

If a spawn/resume reports a thread limit, perform one inspection and bounded cleanup
of eligible agents, then retry the intended dispatch once only if supported cleanup
has changed capacity. If reuse already works, continue through that existing role.
If the same blocker remains, preserve the run evidence and report the exact error,
observed agents, known limits, unavailable capabilities and next supported action.
Do not silently substitute coordinator-only work for required independent gates.

If no close operation is exposed, record CLOSE_UNAVAILABLE. Interrupting work,
marking a stage complete, archiving a sidebar chat, or deleting agent/config/session
files is not evidence of closure or released capacity. Do not use those as workarounds
or reach into unsupported app-server/storage interfaces. Report that cleanup cannot
be executed from this tool surface; use a supported client control if available,
otherwise leave a resumable handoff for a fresh user-opened session. Do not create
a new user chat without the user's explicit request.

## Validation and reporting

Verify before/after inventory and actual close results when available. Distinguish
successful cleanup and dispatch from configured instructions that have not been
exercised. Include retained/closed/replaced agents, preserved evidence locations,
capacity errors and limitations in the final handoff. Lifecycle management never
changes candidate bytes, bypasses review, or grants commit/push/deployment authority.
