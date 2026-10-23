# Portability and dependencies

## Adaptations in this copy

- The two personal workflow skills and their supporting files were copied without content changes.
- Removed `sandbox_mode` from all eight agent copies. Current official documentation says custom agents inherit parent permissions. The read-only roles still instruct agents not to edit; that instruction is not an independently enforced sandbox. Set the parent session's permissions to the level appropriate for the work. QA may produce declared build/test artifacts; reviewers must preserve candidate bytes.
- Replaced the optional Playwright skill's legacy `$CODEX_HOME/skills` wrapper lookup with instructions to resolve the wrapper from its loaded location. The shell wrapper, license, icons and remaining guidance are preserved; NOTICE.txt records the adaptation. It requires Bash (for example Git Bash or WSL on Windows), Node.js/npm/npx, and browser dependencies. Its `npx --yes --package @playwright/cli` wrapper fetches a package when invoked; installation of this toolkit does not run it. Browser actions remain subject to user authorization and the host's tool rules.
- Exported only six string settings from the user config. No permission setting is active in the example. In particular, the source file's full-access sandbox preference was deliberately not transferred. These file preferences are not proof of active settings in any session.
- No original skill, agent, config or instruction file was edited.

## Requirements and remaining unknowns

- A Codex client supporting local skills and project custom agents, plus a subscription/account with the required models and subagent tools. The exact minimum client version is not established here.
- The engineering pipeline needs an intended Git repository, its project-specific build/test tools, all eight custom roles, coordinator-mediated handoffs and independent review. This packaging task did not invoke the engineering pipeline or spend usage on its review stages.
- The pipeline's model routing guide contains dated recommendations. Recheck available model identifiers and supported reasoning efforts on the recipient's host before dispatch; no API credentials are needed by the pipeline itself.
- Agent listing/reuse/close operations vary by runtime. Preserve the lifecycle contract's CLOSE_UNAVAILABLE and capacity reporting behavior when controls are absent. Do not equate completion or interruption with closure.
- Model-gate needs the host's current model options; it can require a user readiness reply when active settings are unknown. No UI/model picker integration is bundled.
- The toolkit is structurally validated. Fresh Codex discovery, custom-role loading, full workflow behavior, optional browser execution and another operating system have not been tested.
- Project-specific skills and AGENTS.md files outside the inspected user configuration were not collected. This is a user-level toolkit, not a backup of every repository on the machine.
- Skills supplied by system and plugin installations are inventoried by category but not copied. Recipients install compatible plugins and authenticate their own connectors. This bundle does not reconstruct all desktop preferences or app state.

## Privacy and scope

Only explicitly selected skill directories, pipeline TOML files, AGENTS.md and allowlisted config values were read for packaging. Configuration section metadata was used for the inventory; local paths and runtime values were omitted. Authentication files, sessions, memories, databases, account IDs, plugin caches and connector credentials were not read or exported as bundle content. A heuristic credential/path scan is an additional check, not proof that arbitrary future edits are safe to publish.
