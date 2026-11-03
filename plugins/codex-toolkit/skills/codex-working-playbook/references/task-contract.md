# Short Task Contract

Derive this brief from the request and inspected context. Maintain it internally; show it only when useful for a decision. Omit irrelevant fields and avoid asking the user to repeat known information.

- **Outcome:** The user-visible result, in one sentence.
- **Acceptance:** The observable conditions needed to establish the requested result; no fixed quota.
- **Business invariants:** Rules that would invalidate an otherwise plausible design.
- **Out of scope:** Specific adjacent work that must not enter this change.
- **Identity:** The identity relevant to the task. For code, establish checkout and dirty work; investigate package/assembly identity for dependency mismatches and actual prompt/settings identity for evaluations. Do not require every identity on every task.
- **Operating constraints:** Topology, persistence, permitted infrastructure, and deployment boundaries.
- **Authorized actions:** Inspection/editing and any explicitly authorized tests, external actions, or Git actions.
- **Evidence needed:** Source, build, checks, user flow, or live evidence that establishes acceptance.
- **Decision needed:** Only a consequential unresolved question; otherwise proceed with reversible choices.

Inspect the existing implementation and contracts first. State the smallest coherent plan. Ask only about an unknown that could change the design. Maintain scope. At completion, report the actual diff, rationale, evidence, and limits. Follow the current model-selection and authorization policy; do not add another kickoff gate.
