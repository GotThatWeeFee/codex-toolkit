# Architecture decision gate

Use this record for greenfield projects and proposed exceptions to an established brownfield stack. Keep it proportional: a small internal utility needs less detail than a production service, but the approval state must remain explicit.

## Decision record

### Context

- Business objective
- Greenfield or brownfield classification
- Existing code, data, integration, deployment, and organizational constraints
- Required security, compliance, reliability, and performance characteristics
- Team ownership and maintainability constraints

### Candidates

Compare only credible options. Include the existing stack for a brownfield exception.

| Criterion | Importance | Candidate A | Candidate B | Candidate C |
| --- | --- | --- | --- | --- |
| Organizational support | | | | |
| Team maintainability | | | | |
| Deployment and runtime fit | | | | |
| Security and compliance | | | | |
| Required integrations | | | | |
| Operations and observability | | | | |
| Testing and tooling | | | | |
| Measured performance needs | | | | |
| Total lifecycle cost | | | | |

Do not manufacture numeric precision. Use evidence and concise qualitative judgments unless the organization has an approved scoring method.

### Recommendation

- Proposed language, runtime, framework, datastore, and deployment model as applicable
- Reasons it best satisfies the requirements
- Material disadvantages and mitigations
- Rejected alternatives and reasons
- Consequences for testing, operations, security, and staffing

### Approval

- Accountable human technical owner
- Decision and date
- Approved deviations or conditions
- Gate state

Use exactly one gate state:

- `APPROVED_STACK`: the accountable human approved a greenfield stack or brownfield exception.
- `EXISTING_STACK_CONFIRMED`: ordinary brownfield work will use the established stack.
- `AWAITING_ARCHITECTURE_APPROVAL`: implementation must not begin.

The coordinator may record an approval already stated by the user or designated approver, but it must not infer approval from silence or from an agent recommendation.
