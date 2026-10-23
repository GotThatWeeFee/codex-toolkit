# Codex toolkit

Portable toolkit prepared on 2026-10-23. It contains two personal workflow skills, eight pipeline agent definitions, selected configuration preferences, and an optional third-party Playwright CLI skill. Installed user configuration was not changed. The toolkit is hosted in the private [GotThatWeeFee/codex-toolkit repository](https://github.com/GotThatWeeFee/codex-toolkit).

## Contents

- `.agents/skills/engineering-pipeline/`: the complete workflow, UI metadata, and nine references.
- `.agents/skills/request-model-gate/`: model recommendation checkpoint and UI metadata.
- `.codex/agents/`: eight model-neutral pipeline roles.
- `optional/skills/playwright/`: optional CLI browser automation with its original Apache-2.0 license and attribution.
- `settings/config.example.toml`: selected model, reasoning, response, personality and service-tier preferences.
- `instructions/AGENTS.example.md`: personal instructions to review and merge manually.
- `INVENTORY.md`, `inventory.json`, `PORTABILITY.md`: scope, exclusions, dependencies and adaptations.
- `Install-Toolkit.ps1`: project installer with preview and conflict refusal.
- `Verify-Toolkit.py` and `manifest.json`: file-integrity and structural checks.

## Install into one project

Clone the repository or download and extract its ZIP. From the toolkit root folder (the folder containing this README), run the following in PowerShell. Replace the example project path with your intended existing project:

```powershell
.\Install-Toolkit.ps1 -ProjectPath 'D:\Projects\MyProject' -WhatIf
.\Install-Toolkit.ps1 -ProjectPath 'D:\Projects\MyProject'
```

The installer copies only the two workflow skills and eight agents. Add `-IncludePlaywright` to either command to include the optional skill. It refuses existing destination files before copying anything, skips config and AGENTS.md, and downloads nothing. Review/merge existing installations manually. No execution-policy change is required by this bundle; environments that block scripts can use the manual steps below.

Manual installation: copy each folder from `.agents/skills/` into the target project's `.agents/skills/`, and the eight TOML files from `.codex/agents/` into the target project's `.codex/agents/`. Preserve existing files. Optionally copy `optional/skills/playwright/` into the project's `.agents/skills/playwright/`. Merge selected settings and instruction text yourself; do not replace an existing config.toml or AGENTS.md wholesale.

Open the project in Codex, trust it only if appropriate, and restart the session if discovery has not refreshed. Confirm `$engineering-pipeline` and `$request-model-gate` appear and that all eight custom agent types are available before starting real pipeline work. Model identifiers must be checked against the recipient's account. If roles are missing, stop and resolve discovery instead of claiming a full pipeline run.

The model-gate skill intentionally asks for readiness when the current model/effort cannot be verified. Installing the example AGENTS.md text makes that checkpoint apply at the start of each substantive objective. Review this preference before adopting it.

## Verify the extracted bundle

With Python 3.11 or newer:

```powershell
py -3 .\Verify-Toolkit.py
```

The verifier uses only the standard library. It checks the manifest, TOML syntax, required skill frontmatter fields, local Markdown links, unique agent names and expected pipeline roles. It ignores the root `.git` metadata directory in a cloned checkout. This is structural validation, not a real Codex discovery or workflow test.

## Sharing and updates

The repository is private. The owner can invite friends through [repository access settings](https://github.com/GotThatWeeFee/codex-toolkit/settings/access); each friend must accept the invitation before accessing it. Then share the repository link, and friends can clone it or download a ZIP using GitHub's Code menu. A repository link alone does not grant access. No collaborator invitations were sent during setup.

For updates, compare with the prior version and merge deliberately; the installer does not overwrite. This is a repository distribution, not an installable Codex plugin package. A plugin can be prepared later if broader distribution is desired. No license was chosen for the personal workflow content; decide the intended reuse terms before public distribution. The optional Playwright content retains its own license.

Read PORTABILITY.md before use. Account connections, desktop state and permissions do not transfer with this bundle.

## Official documentation checked

- [Local skills and distribution](https://learn.chatgpt.com/docs/build-skills)
- [Custom agents and inherited permissions](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Configuration layers and project trust](https://learn.chatgpt.com/docs/config-file/config-basic)
