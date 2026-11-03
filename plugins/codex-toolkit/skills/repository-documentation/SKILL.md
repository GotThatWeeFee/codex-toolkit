---
name: repository-documentation
description: Plan, audit, or substantially revise repository-wide developer documentation and documentation standards. Use for contributor guides, architecture or operational docs, documentation inventories, and repo-wide style policy; routine code/API comments belong to project-aware-coding.
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# Repository Documentation

Make repository guidance accurate, discoverable, and maintainable for its intended readers.

## Scope and sources

- Start with the requested audience and deliverable. Inspect applicable `AGENTS.md`, README and contributor guides, relevant docs, build and tool configuration, and the implemented behavior before drafting. Treat code, configuration, and validated behavior as evidence; flag claims that cannot be confirmed.
- Identify the existing entry points and source of truth. Update the nearest owned document and its navigation links; avoid copying the same instructions into multiple files or inventing a new guide for a small local change.
- Cover the areas actually relevant to the repository and request, such as setup, build, verification, public contracts, configuration, architecture, operations, migration, and troubleshooting. Explain prerequisites, commands, expected outcomes, and limits where readers need them. Keep examples and paths consistent with the current implementation.
- Respect the approved file ownership and scope. Do not change source, tests, or configuration when assigned documentation-only work without separate authorization.

## Documentation standards and formatting policy

- Follow existing repository terminology, structure, Markdown conventions, links, and documentation generation settings. Keep headings and examples useful for scanning; remove stale or contradictory guidance in the documents being revised.
- When establishing repository-wide formatting standards, inspect applicable `.editorconfig` files (including parent directories), formatter/analyzer settings, and existing conventions. A repository `.editorconfig` is useful when it provides a clear, shared policy; create or revise one only when configuration changes are in scope, avoid conflicting rules, and keep language-specific choices intentional. It is configuration, not a substitute for API or contributor documentation.
- For C# API XML documentation and changed-code formatting, apply `project-aware-coding`. A documentation standard should state where authoritative rules live and how contributors use them, rather than duplicate every rule in a second guide.

## Review

- Check changed links, paths, commands, examples, and claims against available source or configuration. Run tests only when the user requested them. Report checks performed and any unverified behavior or environment-dependent instructions.
- Review the diff for unintended document churn and conflicting standards. Summarize the audience, files changed, decisions made, and remaining gaps.
