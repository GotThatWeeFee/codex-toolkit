---
name: dotnet-integration-validation
description: Validate .NET integrations, unpublished package changes, external-service contracts, and restore/build failures with focused evidence and opt-in live tests.
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# .NET Integration Validation

Use this skill when changing or validating a .NET integration, NuGet package contract, service client, or test harness that may interact with external systems, or when diagnosing a .NET restore/build failure.

## Choose the Validation Boundary

- Apply the shared verification and authorization policy in the applicable AGENTS.md. When tests are requested, prefer focused unit or contract tests that observe the public behavior being changed.
- When a sibling package is unpublished, pack it into a repository-local package feed and restore the consumer against that feed; do not assume an unpublished version is externally available.
- Keep generated `bin` and `obj` directories in their normal project locations. Redirect package output rather than intermediate build output.
- When tests are requested, use loopback HTTP stubs for request routes, headers, serialization, null handling, deserialization, and invalid-input behavior before any network access.

## Keep Live Tests Explicit

- Make tests that read or write real external systems explicitly opt-in through the repository's established configuration.
- Keep real IDs, credentials, response bodies, and sensitive payloads out of tracked fixtures. Track examples only.
- Do not enable a live write or broaden its target set without explicit authorization.

## Verify and Report

- Select the narrowest relevant restore/build checks using repository conventions; add or run tests only when requested under the shared verification policy. For focused .NET checks, prefer `--no-restore --disable-build-servers --maxcpucount:1` when compatible with the task.
- Run `git diff --check` after code or test changes.
- Separate new failures from pre-existing warnings, incompatible projects, unavailable infrastructure, and intentionally skipped opt-in tests. Do not represent a successful local contract test as live-system validation.


## NuGet Artifact Identity

When investigating a package/API mismatch, keep these identities as separate evidence:

1. Consumer project: requested package/project reference and central version source.
2. Restore: the version and compile/runtime asset recorded in `project.assets.json`.
3. Package: `.nupkg.metadata` source, nuspec identity, and package location.
4. Assembly: the actual restored DLL and the required type/member identity.
5. Feed: independently identify the published artifact when publication matters.
6. Runtime/build: distinguish a successful restore/build from the assembly actually loaded or deployed.

Do not use "published" to mean that the consumer restored that artifact. Inspect the targeted identity before clearing caches or changing caller contracts. Preserve source, local package, feed, consumer, and runtime evidence as separate claims.


## Restore and Build Diagnosis

When ordinary errors do not reveal the cause, load [MSBuild binary-log diagnosis](references/msbuild-binlog-diagnosis.md). Prefer existing evidence; capture a new log only when the relevant build is authorized and useful.
