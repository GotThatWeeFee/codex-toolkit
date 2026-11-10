---
name: task-model-selection
description: Apply the user's model and reasoning selection policy when explicitly requested or required by applicable instructions.
---

Apply this policy when the user or applicable instructions request it. Skill discovery is not guaranteed before the first response; users who require the gate for every task should adapt this guidance into their own AGENTS.md. Follow higher-priority instructions and offer only model and reasoning choices actually available in the current chat.

# Task Model Selection

Before beginning a new substantive task, provide two ordered model-and-reasoning recommendations and wait for the user's selection. Apply this across coding, research, document, data, planning, operational, creative, analytical, and tool-using work. Once the user selects an option, treat that selection as active for the current task and continue without presenting the same recommendation gate again.

# Mandatory Task Kickoff

After model selection is resolved, treat the user's selection as authorization to begin task-specific research, inspection, planning, drafting, and tool use. Do not send a separate kickoff prompt solely to ask whether to proceed.

- If a material detail is unresolved, ask the single most important clarifying question and wait for my response.
- If the request is already sufficiently specified, proceed without an additional confirmation.
- Keep the kickoff prompt short; do not repeat information I already supplied.
- This applies to every substantive task, including coding, research, document work, planning, operational work, and tool-using tasks.

If the number-one recommendation is gpt-5.6-terra with medium reasoning and that matches the user's configured default, treat Terra Medium as already selected and continue without presenting the recommendation prompt. Still evaluate the available combinations and choose Terra Medium only when it is genuinely the best fit; do not use this exception to suppress a prompt when another model-and-reasoning pair is the better recommendation.

Within an existing chat, re-evaluate and prompt again only when the user begins a distinct task whose demands could reasonably make the current selection a poor fit. A material change includes primary modality or tools, scope or expected duration, reasoning difficulty, reliability or safety stakes, or need for current external evidence. Do not re-prompt merely because the topic changes, the user asks a routine follow-up, the user confirms a selection, or the new work has the same practical demands.

Also re-evaluate after every context compaction. At the first substantive user request after a compaction, provide a new recommendation before task-specific work, even when the request is a routine follow-up or its practical demands are unchanged. Prompt only once for each compaction; retain the usual exemptions for clearly casual conversation, simple factual questions, translations, rewrites, formatting, and other one-step requests.

Do not prompt for clearly casual conversation, simple factual questions, translations, rewrites, formatting, or other one-step requests. Respect an explicit user request not to receive a recommendation.

For every recommendation, evaluate the complete set of valid model-and-reasoning combinations available in the current chat before selecting the two shown. Do not use a fixed shortlist, default pairing, prior recommendation, example, task category, materiality, production sensitivity, multi-file scope, or cross-system scope as a substitute for that comparison. Give exactly two numbered options:

1. **Best fit (Recommended):** model, reasoning effort, applicable skill or minimal skill set, and concise task-specific rationale.
2. **Credible backup:** a genuinely different valid model-and-effort pair, applicable skill or minimal skill set, and concise tradeoff.

Choose capacity and reasoning effort independently. Treat every stronger pair as ineligible until its rationale identifies both: (a) the task-specific capability or unresolved reasoning problem it needs, and (b) why the closest lower-capacity or lower-effort pair cannot reliably handle it. Give the best task-fit and expected outcome more weight than cost: choose the pair most likely to handle the task reliably when there is a meaningful capability, reasoning, or uncertainty difference. Use cost, latency, and lower capacity/effort to break ties only among pairs with materially comparable expected outcomes. A task's importance, production sensitivity, multi-file scope, cross-system scope, supplied logs, or external-service boundary does not establish either condition by itself. Do not treat Terra Medium and Sol High as a default pair. Both pairs must be valid for the current chat. A recommendation does not itself switch the model.

Define the credible backup as the nearest viable alternative to the best fit, not as a generic safety upgrade. It should normally be the lowest-cost or lowest-latency materially different pair that still satisfies the task. A backup that is stronger in both capacity and reasoning than the best fit is allowed only when its rationale identifies a concrete incremental capability and explains why the nearest lower pair is insufficient. A different pair is not automatically a better backup merely because it uses a different model family.

Before presenting the two options, internally rank all valid combinations first by expected task outcome and fit, including the likelihood that their capability and reasoning effort resolve the task without avoidable uncertainty. Then use lower reasoning effort/capacity and practical cost or latency among materially comparable candidates. Perform a final self-check: confirm that the displayed backup is genuinely viable, that any stronger setting is specifically justified, that cost did not displace a meaningfully better task fit, and that the pair was not selected from a recurring model-family or effort-level template. Do not expose the full candidate matrix unless the user asks for it.

Repeatedly selecting the same model family or effort level without task-specific justification is a policy-compliance failure. When recent recommendations show that pattern, recalibrate the selection behavior and prefer the lowest sufficient pair on the next applicable task.

The initial response to the substantive task must contain only the two recommendations and the request to choose, unless the Terra Medium default exception applies; otherwise wait for the user before task-specific work. If fewer than two valid choices are exposed, state that and proceed with the current pair.
