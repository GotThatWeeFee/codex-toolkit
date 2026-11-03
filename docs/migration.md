# Migration from older copies

This release replaces the former project-copy distribution with native plugins and a bounded role helper. Migration is manual: inspect existing installations, preserve local policy, and retire obsolete copies yourself only after resolving duplicate triggers.

| Older source | Current destination | Migration action |
| --- | --- | --- |
| `engineering-pipeline` | Core `engineering-subagent-pipeline` | Review duplicate invocation triggers, then retire the old copy deliberately. |
| `request-model-gate` | `examples/personal-policy.md` | Optional personal policy only; no shared mandatory model gate. |
| Eight old roles: `pipeline-documentation.toml`, `pipeline-final-reviewer.toml`, `pipeline-implementer.toml`, `pipeline-language-mentor.toml`, `pipeline-planner.toml`, `pipeline-qa.toml`, `pipeline-senior-engineer.toml`, and `pipeline-specialist-reviewer.toml` | 13 canonical TOMLs under `plugins/codex-toolkit/skills/engineering-subagent-pipeline/custom-agents/` | Install separately; plugin add does not prove role registration. Compare old `.codex/agents/` copies before retiring them. |
| Standalone/personal/team Jira variants | Optional `current-jira-workflow` | Keep one active guidance source after comparing local policy. |
| `Install-Toolkit.ps1`, manifest, verifier, inventories | Native marketplace and `Install-Agents.ps1` | The old copy/verification contract is retired. |
| Personal `AGENTS`/configuration examples | `examples/` | Merge manually; never overwrite recipient configuration. |
| Vendored Playwright copy | [Maintained Playwright CLI upstream](https://github.com/microsoft/playwright-cli) | This repository does not redistribute vendor plugin caches. |

Common old locations are `.agents/skills/engineering-pipeline/`, `.agents/skills/request-model-gate/`, and `.codex/agents/`. Recommended sequence: inventory those skills and roles; add the core plugin; preflight then explicitly install roles if wanted; resolve duplicate dispatch; then add Jira only if useful and re-establish recipient-owned connections. Plugin upgrades do not update role copies, and each Codex home/machine requires its own role setup.

Install and Update adopt identical canonical roles and back up differing existing canonical roles before replacing them. Remove includes adopted roles but refuses locally modified or missing owned files. Backups are stored under the selected Codex home's `agent-role-backups` directory; unrelated role filenames stay untouched. Do not use broad deletion to clean up older locations. Project `AGENTS.md`, architecture, business rules, Jira mappings, internal examples, test data, and operations remain in their owning repositories.
