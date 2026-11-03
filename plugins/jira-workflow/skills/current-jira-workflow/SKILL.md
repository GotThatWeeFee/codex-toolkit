---
name: current-jira-workflow
description: Create, update, assess, or plan Jira work, including automatic worklogs, progress comments, and status updates after code changes when authorized by standing instructions. Use current connected-project context and verified issue state.
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# Current Jira Workflow

Use this skill for Jira searches, issue planning, creation, updates, sprint assignment, estimation, or verification. Also load it at the start of coding tasks when standing instructions require automatic Jira updates after implementation.

## Discover Available Operations

- Discover the connected Jira and Atlassian tools available in the current chat. An available Jira app connection may expose reads only; plugin metadata does not supply missing API operations.
- Before each kind of write, establish that available tools support both the requested operation and its readback. Reuse an existing connected write-capable Atlassian tool when available; never assume its availability from another chat or invent an endpoint or tool.
- Follow the available tools' schemas and routing instructions. Resolve the same verified Jira site and issue across connectors; do not assume matching project keys establish site identity.
- If a write or its required verification is unavailable, report the affected operation as blocked, retain any pending ledger state, and complete independent supported work. Do not claim success, blindly retry, provision another integration, or request credentials as a workaround.
- Installation is not authorization to modify Jira. Apply the user's current request and standing instructions to each operation.

## Discover Current Context

- Use an available connected Atlassian capability when it is available for the requested work.
- Before acting, discover the accessible site or cloud, current user, project, board when relevant, and active sprint when the task refers to the current sprint.
- Treat sprint IDs, board IDs, custom-field IDs, assignments, statuses, and issue content as time-sensitive. Re-query them rather than relying on a prior task or memory.
- Search for existing or overlapping work before proposing or creating new issues when the user asks for backlog planning or issue creation.

## Prevent Overlapping Issues

Before proposing new issues or creating each issue, establish that its implementation scope and acceptance criteria do not duplicate work already tracked or completed.

- Search current Jira content using the requested outcome, affected component or integration, relevant identifiers, and alternate terminology. Inspect likely matches beyond their summaries: read descriptions, acceptance criteria, status, and relevant parent, child, or linked issues. Include related projects when the work crosses project boundaries and completed issues when they may already satisfy the request. Different titles, issue types, projects, assignees, or sprint assignments do not establish distinct work.
- Compare the actual deliverables and acceptance criteria. Shared components or a dependency alone do not mean overlap; requiring the same implementation or deliverable in multiple issues does. A parent may summarize child scope, but must not independently assign the same implementation again.
- If an existing issue fully covers the requested work, identify that issue and reuse its coverage rather than creating another. If completed work appears to satisfy the request, verify whether a distinct regression or unmet requirement remains before proposing another issue. Do not reopen, expand, or otherwise modify existing issues without authorization for that action.
- If coverage is partial, create only the remaining distinct work. State what the new issue includes, explicitly exclude work owned by the existing issue, and reference its key. Make the new acceptance criteria independently verifiable without requiring the existing issue's deliverables to be implemented again. Add dependency links when authorized and supported; links alone do not resolve duplicate scope.
- For a batch, compare every proposed issue against the other drafts as well as existing Jira issues. Give each deliverable one implementation owner and put shared prerequisites in one issue that others reference. Recheck current Jira coverage before each creation, including issues already created in the batch, and after a material scope change.
- If overlap cannot be resolved from current evidence, ask the single consequential scope question and hold the affected creation. If search is unavailable or materially incomplete, report the limitation and hold creation until coverage can be checked; direct retrieval of one issue does not establish that no overlapping issues exist.
- Briefly record the coverage decision with the proposal or creation result: relevant existing issue keys and the distinct remaining scope, or that no overlap was found within the searched scope. Do not claim exhaustive coverage when access or search results were limited.

## Apply Project and User Conventions

- Resolve estimation, issue hierarchy, naming, assignment, and required fields from the current request, applicable project guidance, and verified Jira metadata. This shared plugin does not impose its author's personal conventions on other users.
- Keep estimated future effort separate from measured actual time. When an estimate is required, use the project's supported field, duration format, and estimation method. Clarify materially ambiguous scope before writing an estimate. Do not assume AI-assisted estimation unless the applicable instructions request it.
- Create only a permitted issue type with supported hierarchy and parent relationships. Do not assume that subtasks are either required or forbidden; apply the user's and project's actual policy.
- Some users require Original estimate on every new issue, estimates that account for AI assistance plus remaining human work, and independently tracked issue types instead of subtasks. Apply these conventions only when their instructions establish them. If a required convention cannot be persisted, hold that creation and explain the blocker.
- Sharing or installing this plugin never grants standing authorization for automatic worklogs, comments, or transitions. Use the procedure below only when that user has authorized its scope; otherwise follow the explicit Jira request.

## Automatic Implementation Updates

Apply this procedure when the user's standing instructions authorize Jira updates after code changes. Load it at task start to capture time, then complete it before the final response of each turn that changes code. Group related edits into one update per associated issue for that turn; do not post after every file save.

### Capture time and identify issues

- Record task/turn identity, start/end timestamps, and active intervals using available clock or execution timestamps. Count Codex task elapsed time, including implementation-related investigation and tool execution; exclude idle periods and waits for user input. Preserve timing and pending operations across a handoff or compaction. If timing cannot be recovered reliably, report the gap and ask for the missing duration instead of inventing it.
- Resolve exact issue keys and the connected site from the user request, branch, or verified task context. Read current issues and confirm that their scope matches the work. Ask only if the target or time allocation remains materially ambiguous. Do not create tickets as part of automatic completion updates.
- Log only measured time not already logged. Allocate a shared interval once across associated issues; allocations must not exceed the elapsed interval. Concurrent work counts once as elapsed task time. Sum intervals before rounding once to Jira-supported precision. Keep estimates separate from worklogs.

### Prepare and apply the update

- Read current status, acceptance criteria, relevant comments/worklogs, and available transitions. Use the connected Jira tools for worklogs, comments, and transitions; do not assume a transition name or ID from another issue.
- Keep a durable task-local operation ledger in the permitted workspace with a stable key based on task/turn, issue, and operation. Record measured intervals, allocated duration, intended operation, returned IDs, and readback state. Reuse this ledger on retries and resumed turns; keep sensitive payloads out of it.
- Add a worklog using the allocated Codex task time and an ordinary description of the work performed. No model/tool-execution disclaimer is required. Do not infer human labor or derive actual time from an estimate.
- Add one concise progress comment covering changes completed, checks actually performed and their limits, and remaining work or blockers. Include useful existing code/PR references when available. Never claim unrun tests, deployment, live-service success, or completion of unverified acceptance criteria.
- Transition only when current evidence warrants it: use an appropriate active status for started work, a review/QA status when implementation is ready for the required next gate, and Done only when acceptance criteria and required project completion gates are satisfied. Leave status unchanged when it already fits. Do not reopen closed work automatically when the intended scope is unclear.

### Verify and resume safely

- After each write, re-read the corresponding worklog, comment, or issue status and record verification in the ledger. A successful tool response alone does not confirm persistence.
- Before retrying an uncertain write, query by the returned ID or match the exact intended operation against current Jira data. Retry only after establishing that it is absent. If the available tools cannot establish whether it exists, retain it as pending and report the blocker instead of risking a duplicate.
- Finish independent operations when one operation is blocked, retaining each result separately. In the final response, briefly report issues updated, time logged, any status changes, and pending failures. Do not claim Jira synchronization succeeded unless readback confirms it.

## Make and Verify Changes

- Derive the requested issue type, project, summary convention, assignee, sprint, original estimate, labels, links, and acceptance criteria from the request and current metadata before writing; ask only for a material missing choice. Verify from current Jira metadata that the chosen issue type and hierarchy comply with the applicable policy.
- Re-fetch every created or updated issue and verify the requested fields actually persisted, especially assignee and sprint membership.
- For every created issue, also verify any required estimate, returned issue type, and requested hierarchy or parent relationship.
- If broad search is unavailable but direct issue retrieval works, use the direct issue and state the search limitation. Do not replace missing current evidence with stale notes.
- Apply the shared authorization policy in the applicable AGENTS.md to the exact Jira issues and fields; reuse authorization already granted for that scope.
- For batch writes, keep a durable local ledger of each intended operation, its stable logical key, returned issue/worklog ID, and readback status. Before retrying an uncertain write, query for the recorded ID or exact intended operation to avoid duplicates; stop when existence cannot be established. Keep sensitive payloads out of the ledger.
- Keep Original Estimates and measured worklogs separate. When the user authorizes Codex task time, log that measured duration using ordinary work descriptions; never fabricate human labor or create worklogs from an estimate.
