# Components

## Plugins

| Plugin | Purpose | Contents |
| --- | --- | --- |
| `codex-toolkit` | Reusable engineering guidance | Eleven canonical skills, the engineering-pipeline references, optional audit helper, and canonical custom-agent TOMLs. |
| `jira-workflow` | Optional team-neutral Jira guidance | One `current-jira-workflow` skill and icon asset. |

The manifests describe package metadata; they provide no credentials, fixed Jira bindings, forced model setting, or guarantee of client discovery.

## Core skills

| Skill | Use |
| --- | --- |
| `analyzing-dotnet-performance` | Review known or suspected .NET hot paths. |
| `change-explanation` | Explain actual changes and draft commit messages. |
| `codex-working-playbook` | Maintain a concise brief, diagnose, or hand off work. |
| `dotnet-integration-validation` | Bound integration evidence and opt-in live validation. |
| `engineering-subagent-pipeline` | Coordinate approved multi-agent engineering work. |
| `evidence-bound-operations` | Separate source, artifact, configuration, and live evidence. |
| `project-aware-coding` | Apply project conventions to coding and reviews. |
| `repository-documentation` | Plan or substantially revise repository documentation. |
| `safe-git-integration` | Prepare integration while preserving changes. |
| `sql-object-impact-analysis` | Trace database-object dependencies before SQL changes. |
| `task-model-selection` | Apply an explicitly requested model and reasoning selection policy. |

Each skill is stored once under `plugins/codex-toolkit/skills/`. Guidance never grants permission for tests, Git mutations, deployment, publication, connector writes, or live runs.

## Roles, audit, and local boundaries

The pipeline supplies 13 canonical roles: accessibility, contract, documentation, .NET practices, final, performance/operability, reliability, security, and test-strategy reviewers; planner, junior developer, QA engineer, and senior engineer. `Install-Agents.ps1` manages these TOMLs, its ledger, and recovery backups. On Windows it can install/update the required PowerShell runtime after permission is granted; it does not install plugins/skills or change configuration/hooks. See [installation](installation.md).

The pipeline also contains an optional metadata-only local audit helper and schema. It is inactive unless separately authorized with a recipient-approved local audit location; no hooks are installed or activated. Its documented privacy boundary excludes prompts, transcripts, raw workspace paths, tool data, and credentials.

The examples are for deliberate adaptation; the workflow review example can be used to configure an automation after its permissions are reviewed. Project architecture, business rules, service mappings, Jira rules, internal examples, tests, and operations stay with each project. Caches, credentials, account state, sessions, logs, and audit output are excluded.
