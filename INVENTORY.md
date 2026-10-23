# Inventory

Verified from installed user configuration on 2026-10-23:

| Category | Found | Included |
| --- | --- | --- |
| Standalone skills | 3 | 2 core workflow skills; Playwright optional |
| Pipeline roles | 8 | All 8, with sandbox field adaptation |
| Pipeline references | 9 | All 9 |
| Personal instructions | 1 | Manual-merge example |
| Configuration preferences | 6 selected strings | Example only |
| Bundled system skills | 5 | None; use recipient's own installation |
| Explicit plugin config entries | 12 | Names/enabled flags inventoried, plugin files omitted |
| MCP server definitions | 1 | Omitted; local runtime setup |
| Project trust entries | 24 | Omitted; local machine state |

Pipeline roles:

- `pipeline_documentation`
- `pipeline_final_reviewer`
- `pipeline_implementer`
- `pipeline_language_mentor`
- `pipeline_planner`
- `pipeline_qa`
- `pipeline_senior_engineer`
- `pipeline_specialist_reviewer`

Selected settings:

- `model = "gpt-6.1-sol"`
- `model_reasoning_effort = "medium"`
- `model_verbosity = "medium"`
- `model_reasoning_summary = "concise"`
- `personality = "friendly"`
- `service_tier = "default"`

Explicitly configured plugins (not a full installed-plugin or connected-account inventory):

- `codex-app-tools@openai-bundled` (enabled: true)
- `browser@openai-bundled` (enabled: true)
- `visualize@openai-bundled` (enabled: true)
- `documents@openai-primary-runtime` (enabled: true)
- `pdf@openai-primary-runtime` (enabled: true)
- `spreadsheets@openai-primary-runtime` (enabled: true)
- `presentations@openai-primary-runtime` (enabled: true)
- `template-creator@openai-primary-runtime` (enabled: true)
- `computer-use@openai-bundled` (enabled: true)
- `unified-computer-use@openai-bundled` (enabled: true)
- `chrome@openai-bundled` (enabled: true)
- `code-review@openai-bundled` (enabled: true)

These are file values, not verified effective session settings. See inventory.json for relative source provenance, source hashes, adaptations and exclusions. No personal filesystem paths are stored in the inventory. Project-specific skills outside user configuration were not collected.
