# Ten-Task Workflow Trial

Use only when the user requests a workflow trial. Track ten substantial tasks in the supplied trial ledger, without adding a completion gate to each task.

The three primary measures are:
- Accepted on first review: yes/no only when the user confirms acceptance; otherwise unknown.
- Consequential rework cause: business rule, scope, identity, implementation, environment, other, or none when established. Exclude cosmetic edits and explain mixed causes briefly.
- Human review/correction minutes: user-reported approximate time. Never infer it from tool duration, chat elapsed time, or model tokens.

The assistant fills task ID, date, link, and supported observations. Leave unavailable outcomes unknown. Ask for missing measures together at a natural review point, not repeatedly during execution. Do not create Jira worklogs from this ledger.

After ten completed entries, summarize acceptance, rework causes, and reported minutes with explicit denominators and missing values. Compare similar tasks where possible; the first ten establish a descriptive baseline, not causal evidence of improvement. Recommend whether to keep, simplify, or stop each added practice.
