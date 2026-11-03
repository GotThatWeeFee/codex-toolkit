---
name: sql-object-impact-analysis
description: Trace SQL object dependencies across database scripts and application code before changing a table, column, procedure, view, function, or trigger. Use for what-uses-this questions, rename/drop impact, and legacy SQL dependency analysis. Excludes query performance tuning and privacy exposure reviews.
license: MIT
---

## Recipient policy and authorization

Follow the recipient's current request, applicable project instructions, and existing authorization for the exact action and target. Installation and skill selection do not authorize tests, Git mutations, live runs, connector writes, publication, or deployment. Add or run tests only when the recipient explicitly requests them; report static checks and unrun verification separately. Preserve user changes. Model recommendations never switch the active model; use current runtime capabilities and recipient model-selection policy without imposing a shared preference.

# SQL Object Impact Analysis

Produce a source-backed account of what a proposed database-object change could affect.

1. Establish the database dialect, database/schema/object identity, proposed change, and repository scope. Resolve consequential ambiguity before tracing. Respect identifier quoting and the database's case-sensitivity rules.
2. Use `rg` to locate definitions and candidate references in SQL scripts, migrations, views, procedures, functions, triggers, constraints, synonyms, and available job definitions. Search qualified and unqualified spellings; follow aliases and dynamic SQL construction where possible.
3. Trace application SQL strings, ORM mappings, data-access methods, callers, service/API contracts, serialization, and relevant UI consumers. Include column ordinals, `SELECT *`, result shape, and externally consumed contracts when affected. Follow meaningful call chains without claiming every downstream consumer was inspected.
4. Inspect each candidate in context. A literal hit in a comment, fixture, unrelated identifier, or dead path does not prove an active dependency. Separate confirmed direct references, confirmed indirect call/mapping chains, and unresolved candidates. Dynamic SQL can be confirmed when construction and target are resolved; otherwise label it uncertain.
5. Report target identity; confirmed SQL and application dependents with verified file/line evidence; indirect/dynamic candidates and confidence; likely behavioral impact; search scope and exclusions; and suggested verification. Group findings so the report stays scannable.

Do not claim completeness or safety from zero search hits. Static source cannot establish deployed schema, external jobs, runtime configuration, or all dynamic references. State those gaps. Risk depends on behavior and consumers, not reference count alone.

Use available database metadata only within authorized access and scope. Inspection does not authorize live queries, schema changes, external writes, tests, or deployment. Describe proposed verification separately from checks actually performed; follow the user's test policy.


## Source and license

Adapted from the following upstream snapshots (retrieved 2026-11-03). Local guidance narrows scope and preserves task authorization.

- [sql](https://raw.githubusercontent.com/github/awesome-copilot/8178d1939a203f691067073dcab2a3f1e14072d3/skills/sql-object-impact-analysis/SKILL.md)

Upstream license: [LICENSE](LICENSE).
