# Installation

## Prerequisites

- Access to this repository and a Codex client that supports plugin marketplaces.
- A local checkout only if you want custom roles.
- PowerShell 7.2 or later for `Install-Agents.ps1`.
- For optional Jira use, a recipient-approved connection and authorization for each operation.

The marketplace manifest is `.agents/plugins/marketplace.json`; its paths are repository-root relative and it provides `codex-toolkit` and `jira-workflow`.

## Plugins

Add the marketplace and core plugin with the current CLI verbs:

```powershell
codex plugin marketplace add <owner/repo>
codex plugin add codex-toolkit@codex-toolkit
```

If PowerShell cannot find `codex`, locate the executable bundled with the Codex desktop app and invoke it directly:

```powershell
$codexExe = Get-ChildItem "$env:LOCALAPPDATA\OpenAI\Codex\bin" -Filter codex.exe -Recurse -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($codexExe) {
    & $codexExe.FullName plugin marketplace add <owner/repo> --ref main
} else {
    Write-Host "No bundled Codex executable found."
}
```

Restart Codex after adding the marketplace. Open **Plugins**, select the **Codex Toolkit** marketplace, then install **Codex Toolkit**. The marketplace registration only adds the catalog; each plugin must be installed separately. Install **Jira Workflow** when its Jira guidance is needed.

`codex plugin add` is the documented command, not `codex plugin install`. Consult your client help for its marketplace locator syntax and UI route. This documentation does not claim a fresh-client install or discovery was exercised.

To add the optional Jira guidance:

```powershell
codex plugin add jira-workflow@codex-toolkit
```

It carries no credentials, site selection, fixed account binding, or write permission. Recipient connections and authorization control all Jira behavior.

## Roles from a local checkout

Canonical role TOMLs are under `plugins/codex-toolkit/skills/engineering-subagent-pipeline/custom-agents/`. Plugin installation does not establish automatic custom-role registration. Run the bounded role helper explicitly, beginning with a preflight:

```powershell
pwsh -File .\Install-Agents.ps1 -Action Install -WhatIf
pwsh -File .\Install-Agents.ps1 -Action Install
```

The target home resolves in this order: explicit absolute `-CodexHome`, `CODEX_HOME`, then the current profile's `.codex` directory. For example:

```powershell
pwsh -File .\Install-Agents.ps1 -Action Install -CodexHome 'D:\CodexProfile'
```

The target cannot be a filesystem root, and its parent must exist before the helper creates a selected home or `agents` directory. The helper never edits `config.toml`, `AGENTS.md`, skills, plugins, or hooks.

## Update or remove roles

Plugin updates and copied roles are separate. After reviewing the local checkout, update roles with:

```powershell
pwsh -File .\Install-Agents.ps1 -Action Update -WhatIf
pwsh -File .\Install-Agents.ps1 -Action Update
```

Remove only helper-owned roles with:

```powershell
pwsh -File .\Install-Agents.ps1 -Action Remove -WhatIf
pwsh -File .\Install-Agents.ps1 -Action Remove
```

`Update` and `Remove` require `.codex-toolkit-agents.json`. They refuse missing or modified owned roles; there is no force flag. Use `codex plugin marketplace upgrade` for marketplace updates after checking client help.

## Conflict and recovery behavior

Before writing, the helper preflights every role and ledger path, rejects reparse points/links and escaping destinations, and records only owned relative paths and hashes. An identical unowned file is reported and skipped without adoption, so removal will preserve it. A differing unowned file is a conflict. An unchanged owned install is idempotent; an owned role that differs from the canonical version requires `Update`.

Caught failures attempt guarded rollback. Operations are not multi-file atomic; abrupt termination, partial writes, and concurrent writers are unverified. If a failure or `.codex-toolkit-agents.json.tmp` remains, preserve it, compare canonical source and ledger SHA-256 hashes manually, and reconcile only affected paths. Do not recursively delete a directory. `-WhatIf` is preflight only, not a live installation test.

Existing account installations are migration inputs, not permission to replace them. Each machine and Codex home needs its own explicit role setup.
