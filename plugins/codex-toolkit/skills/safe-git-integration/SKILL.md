---
name: safe-git-integration
description: Merge, rebase, review, or prepare branch integrations while preserving dirty work, validating graph and content integrity, and avoiding unrequested remote changes.
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# Safe Git Integration

Use this skill for merges, rebases, replacement cutovers, conflict resolution, branch-integration reviews, or preparing a branch for remote publication.

## Preserve the Starting State

- Inspect the current branch, worktree status, remotes, and source/target refs before changing history.
- Preserve unrelated user changes. Use an isolated worktree when the primary checkout is dirty or when integration work would otherwise make recovery difficult.
- Refresh relevant refs before relying on graph conclusions. Before an authorized rebase, history rewrite, or consequential merge, preserve a recoverable local backup ref within the authorized Git scope. Ref and branch creation are mutations, not read-only inspection.

## Resolve Intent Before Content

- For unrelated histories, replacement branches, or root-level conflicts, compare ancestry and tree overlap before resolving.
- Surface a choice that changes ownership, removes a legacy tree, or treats one branch as a cutover replacement; do not make that decision implicitly.
- Resolve conflicts according to component ownership, registrations, dependencies, and intended runtime behavior—not solely by Git rename heuristics or path similarity.

## Validate Locally First

- Confirm there are no unmerged entries or conflict markers.
- Verify the intended ancestry and, for replacement work, the required tree identity.
- Run `git diff --check`; for a completed merge, also run `git diff-tree --check HEAD^1 HEAD` when applicable.
- Apply the shared verification policy in the applicable AGENTS.md to builds and tests; report baseline warnings and unperformed checks separately.
- Follow the applicable AGENTS.md Git and branch-creation policy, including the stage/commit/push boundary. Check existing authorization for the exact mutation. A requested local branch does not itself authorize a remote write; report branch creation incomplete if the required matching remote cannot be authorized. Opening a merge request also requires user authorization.
