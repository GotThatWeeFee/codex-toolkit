# Codex Toolkit

Codex Toolkit is a reusable collection of engineering guidance distributed as native Codex plugins. It has a small, explicit role installer for people who also want the engineering pipeline's custom-agent roles.

It does not change a recipient's configuration, account permissions, connections, hooks, model selection, or project instructions. Installing it does not itself authorize tests, Git mutations, connector writes, publication, deployment, or live runs.

## Start here

1. Obtain access to this repository and use a compatible Codex client.
2. Add this repository as a marketplace, then add the core plugin:

   ```powershell
   codex plugin marketplace add <owner/repo>
   codex plugin add codex-toolkit@codex-toolkit
   ```

   If PowerShell reports that `codex` is not recognized, use the Codex executable bundled with the desktop app:

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

   Restart Codex after adding the marketplace. In **Plugins**, select **Codex Toolkit** and install the core plugin. Install **Jira Workflow** only when you need its Jira guidance.

3. If you want the 13 engineering roles, clone or otherwise obtain a local checkout and run the role helper after reviewing its preflight:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Install-Agents.ps1 -Action Install -WhatIf
   powershell -ExecutionPolicy Bypass -File .\Install-Agents.ps1 -Action Install
   ```

4. Optionally add Jira guidance when you have an approved Jira connection and authorization:

   ```powershell
   codex plugin add jira-workflow@codex-toolkit
   ```

The marketplace name in these examples is `codex-toolkit`; replace `<owner/repo>` with the repository locator you were given (for example, `GotThatWeeFee/codex-toolkit` where that locator is appropriate). These commands are documented from installed CLI help and source manifests; this repository does not claim that installation, discovery, role loading, or connector access was exercised in a fresh account.

Read [installation](docs/installation.md) for prerequisites, updates, and recovery boundaries. [Components](docs/components.md) describes the plugin contents; [engineering pipeline](docs/engineering-pipeline.md) describes the optional workflow; [migration](docs/migration.md) explains how to retire older copies deliberately.

## What is included

The **Codex Toolkit** plugin contains eleven canonical skills: `analyzing-dotnet-performance`, `change-explanation`, `codex-working-playbook`, `dotnet-integration-validation`, `engineering-subagent-pipeline`, `evidence-bound-operations`, `project-aware-coding`, `repository-documentation`, `safe-git-integration`, `sql-object-impact-analysis`, and `task-model-selection`.

The optional **Jira Workflow** plugin contains one team-neutral `current-jira-workflow` skill. Jira behavior depends on the recipient's own approved connection, permissions, project rules, and authorization; it contains no credentials or fixed account binding.

The core plugin includes no automatic custom-role registration. The separately run helper copies the 13 canonical TOMLs into the selected Codex home's `agents` directory and records only its own files in `.codex-toolkit-agents.json`.

## Boundaries and ownership

Project-specific architecture, business rules, service mappings, Jira conventions, internal examples, test data, and operational documentation belong in their project repositories. Account state, credentials, vendor caches, memories, sessions, logs, audit output, and local hooks also stay local.

The optional examples are for manual adaptation only: [personal policy](examples/personal-policy.md), [configuration](examples/config.example.toml), and [workflow review automation](examples/workflow-review-automation.md). Do not copy these wholesale into an existing account or project.

No root license is included. This repository does not grant or imply public redistribution rights; obtain the maintainer's permission before sharing outside the intended audience.

## Updating

Update installed plugins through the native marketplace mechanism, for example `codex plugin marketplace upgrade` after checking your client help. Plugin updates do not update copied role TOMLs. Review changes in a local checkout, then use `Install-Agents.ps1 -Action Update`. Install and Update back up differing existing canonical role files before replacement. See [installation](docs/installation.md#update-or-remove-roles).

## Scope and validation limits

This source provides packaging and guidance, not a managed service. Static inspection can confirm the checked-in manifests, paths, helper logic, and documented contracts. It cannot establish marketplace visibility, client dispatch, installation success, agent discovery, filesystem behavior on every machine, or live Jira operations.
