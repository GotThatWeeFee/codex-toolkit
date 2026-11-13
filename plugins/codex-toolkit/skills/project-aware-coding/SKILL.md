---
name: project-aware-coding
description: "Apply project-aware engineering standards to every coding task: creating, modifying, debugging, refactoring, or reviewing code, whether or not a repository is already present. Use across languages, especially for C#/.NET work requiring XML documentation, reuse of existing project or dependency APIs, root-cause diagnosis, test integrity, adherence to repository conventions, minimal changes, and appropriate verification. Do not use for clearly non-coding requests."
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# Project-Aware Coding

Produce maintainable code that fits the repository instead of imposing a generic style.

## Activation Boundary

Apply this skill to every request that would create, change, debug, refactor, review, test, or otherwise inspect code, including a projectless task or a request before a repository has been identified. If it is genuinely unclear whether a request is coding, apply the relevant project conventions without adding an approval gate. Exclude only requests that are clearly non-coding.

## Follow the Instruction Hierarchy

Apply guidance in this order:

1. The user's explicit request for the current task.
2. Applicable repository instructions and documentation, including `AGENTS.md` and relevant Markdown guidance.
3. Established project conventions and architecture.
4. Language and framework best practices.
5. General coding preferences in this skill.

Surface conflicts that materially affect correctness or design.

## Model Selection

Follow model-selection instructions only when supplied by the recipient. This shared skill imposes no recommendation gate.

## Respect the Requested Scope

- For explanation, review, status, or diagnosis requests, inspect and report without modifying code unless implementation is also requested.
- For implementation requests, complete and verify the requested change without unnecessary pauses.
- When requirements, acceptance criteria, desired behavior, or a consequential implementation choice are unclear, ask the user for clarification before choosing an interpretation. Do not guess or silently fill the gap with an assumption.
- Ask before making a consequential unrequested choice such as adding a dependency, changing a public API, modifying a database schema, changing authentication or authorization behavior, or introducing a breaking change.

## Establish Local Conventions

1. Before substantive code inspection or editing, discover the repository's applicable documentation. Search for `AGENTS.md` and relevant Markdown files such as root or subtree `README.md`, `CONTRIBUTING.md`, `DEVELOPMENT.md`, architecture or decision records, and guidance under documentation directories.
2. Read the documentation that governs the task and the files in scope. Treat root-level guidance as repository-wide unless it says otherwise, and closer subtree guidance as applying to that subtree. Follow links to additional project documentation when they are needed to understand the requirements.
3. Do not indiscriminately load every Markdown file. Exclude generated output, vendored dependencies, package caches, build artifacts, and unrelated product or historical documentation unless the task touches them or an applicable guide points to them.
4. Extract relevant requirements, conventions, commands, and acceptance criteria from the applicable documentation, and use them as constraints throughout implementation and verification. Surface material conflicts between documents or with the user's request before choosing an interpretation.
5. Inspect nearby code, project configuration, formatters, analyzers, compiler settings, tests, and dependency manifests.
6. Treat explicit user instructions as highest priority. Otherwise, prefer documented guidance first, then established project structure, naming, patterns, formatting, and error-handling conventions over generic preferences.
7. Depart from local conventions only when required for correctness, security, compatibility, or the requested behavior. Keep the departure narrow and explain it.

## Reuse Before Creating

1. Before adding a method, helper, service, utility, extension method, abstraction, or test fixture, search the repository for an existing one that supplies the needed behavior.
2. Inspect the nearby implementation, shared helper locations, declared dependencies, and attached packages for an appropriate supported API before adding a new implementation or dependency.
3. Reuse or extend an existing implementation when its semantics, visibility, compatibility, and ownership fit the task.
4. Do not duplicate behavior merely to obtain a preferred name or shape. Adapt at the smallest reasonable boundary when needed.
5. Create new code only when no suitable implementation exists or reuse would introduce incorrect coupling, unsafe behavior, or a breaking change. State that reason when it is not obvious.

## Document Changed C# Members

- In C#/.NET code, add XML documentation to every newly created class and method, regardless of visibility, unless the file is generated or repository rules explicitly exclude it. Also document newly created public or protected interfaces, records, structs, enums, delegates, constructors, properties, events, and other API members.
- For each new or changed documented member, write a useful `<summary>` and keep the XML tags aligned with its current signature and behavior: one `<param>` per parameter, `<typeparam>` for type parameters, `<returns>` for a returned value (including `Task<T>` and tuple results), and `<value>` or `<exception>` when they add useful contract information. Follow any stricter repository rule. A `void` or non-generic `Task` method does not need `<returns>` unless local guidance requires it.
- Use `<inheritdoc/>` only when the inherited documentation already covers the implementation's parameters, return value, and behavior. If the source declaration is incomplete, improve that declaration when it is in scope or write the missing documentation explicitly on the implementation. Do not use `<inheritdoc/>` to conceal missing contract information.
- Update existing XML documentation when changing a member's signature or documented behavior. Avoid unrelated documentation churn.
- Outside C#/.NET, use the language's idiomatic documentation format rather than inserting invalid XML comments, while preserving the same documentation intent.

## Explain Non-Obvious Intent Inline

- While implementing or changing code, add short comments beside logic whose purpose or constraints would otherwise slow review: business rules, required ordering, state invariants, compatibility workarounds, failure or retry behavior, and non-obvious transformations. Explain what the block accomplishes and why its approach matters when that is not clear from the code and API documentation.
- Prefer clear names and small, cohesive code first. Do not narrate syntax, repeat method headers, comment every statement, or impose a comment quota. Leave straightforward code uncommented.
- Ground rationale in the request, inspected code, contracts, or established project evidence. Never invent historical intent or claim a safety, performance, or external-service guarantee that has not been established. Put unresolved assumptions in the handoff rather than presenting them as facts in code.
- Keep comments next to the relevant branch or block and describe the enduring constraint, not the agent's editing process. Follow the language and repository's comment style; use a short example only when it materially clarifies a rule or transformation.
- Update or remove nearby comments when behavior changes. During static review, trace each added or affected comment against the actual control flow, including failure paths, and correct misleading or stale explanations. Keep unrelated comment cleanup out of scope.

## Keep Formatting Consistent

- Before editing, inspect applicable `.editorconfig`, formatter and analyzer settings, and nearby code. Preserve established indentation, braces, line breaks, and spacing in changed code.
- Format the changed files with the repository's configured formatter when that is a normal, available part of the workflow and does not cause unrelated changes. Review the resulting diff and remove incidental formatting churn.
- If formatting rules are inconsistent or absent, use nearby conventions for the current change. For repository-wide style work, recommend or add a scoped `.editorconfig` after checking for an applicable parent file and existing tool configuration; do not overwrite an established policy or create conflicting defaults.

## Implement Conservatively

- Make the minimum coherent code change that fully solves the request or bug without sacrificing the requested behavior. Prefer deleting or simplifying redundant code over adding layers.
- Treat every new line, branch, helper, abstraction, dependency, configuration setting, and test fixture as requiring a concrete need. Do not add it merely for hypothetical reuse, completeness, symmetry, or style preference.
- Express the behavior directly at the existing ownership boundary. Extend nearby code when it remains clear; extract a helper or introduce an abstraction only when it removes real duplication, clarifies a non-trivial concept, or is required by an existing convention.
- Keep conditionals, error handling, validation, and tests no broader than the behavior being changed. Reuse established paths for cross-cutting concerns rather than reimplementing them.
- Preserve public behavior and compatibility unless the user requests a breaking change.
- Avoid speculative abstractions, premature dependencies, unrelated cleanup, broad reformatting, and comment or documentation churn. Documentation must still meet the repository's API requirements and explain non-obvious intent.
- Follow the project's established approaches to nullability, async work, cancellation, disposal, logging, validation, exceptions, dependency injection, and security.
- Handle edge cases at the same level of rigor as surrounding production code.
- Follow the shared verification policy in the applicable AGENTS.md. When tests are requested, focus them on the changed behavior and repository conventions.

## Diagnose and Protect Integrity

- For defects, reproduce the failure or establish evidence for the root cause before changing code. When tests are requested, add a focused regression test when practical.
- Never weaken, remove, skip, or rewrite a valid test merely to make a change pass. Prefer tests of observable behavior over implementation details.
- Do not suppress compiler warnings, analyzer findings, type errors, or exceptions merely to obtain a passing result. Add only narrow, justified suppressions when required.
- Identify generated code, migrations, generated API clients, and compiled assets. Modify their source or generator instead of generated output unless the repository explicitly requires direct edits.
- Never place credentials or secrets in source, fixtures, logs, examples, or error messages. Avoid logging personal or security-sensitive data.
- Preserve existing security boundaries and fail safely. Do not silently swallow errors unless that behavior is intentional and consistent with the project.

## Verify

1. Review the diff for accidental scope expansion and formatting noise.
2. Choose relevant checks under the applicable AGENTS.md verification policy; run tests only when requested. Report any unperformed verification as a gap.
3. Review new and changed C# members for complete XML tags, including inherited documentation, confirm the changed files follow the applicable formatting rules, and check added or affected inline comments against the final behavior and supported rationale.
4. Report verification performed, any failures, and any checks that could not be run.
5. Summarize what changed, why it changed, remaining risks, and any decisions or follow-up work needed from the user.

## Blazor Component Guidance

For Razor component, lifecycle, state, event, or interop work, load [Blazor component guidance](references/blazor-components.md) and apply it within repository conventions and the requested scope.
