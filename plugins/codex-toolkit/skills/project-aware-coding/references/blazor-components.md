# Blazor component changes

Use for Razor component composition, parameters/events, lifecycle, state, async work, and related interop. First inspect the actual Blazor hosting model, target framework, render mode, prerendering, existing component library, and nearby patterns.

- Sketch the affected component tree and state owner when the change crosses components. Reuse existing components and services. Pass values through parameters and notify owners through typed callbacks such as `EventCallback<T>` when appropriate; avoid mutating parent-owned parameter values. Keep parameter contracts and XML documentation aligned with local rules.
- Choose component boundaries by behavior, reuse, and comprehensibility, not line-count thresholds. Preserve established code-behind, styling, and data-fetching conventions unless the requested behavior requires a change.
- Use initialization for instance setup and parameter lifecycle hooks for state that depends on changing parameters. Account for repeated initialization during prerendering and for asynchronous reentrancy. Render valid loading/empty/error states while awaiting work. Prevent stale completions from overwriting newer state when parameters or selections change.
- Prefer awaitable `Task` event handlers; avoid `async void` except where a required delegate shape leaves no alternative. Use the renderer synchronization context for external notifications, commonly through `InvokeAsync`; add `StateHasChanged` only where the framework is not already scheduling the necessary render.
- Cancel owned in-flight work when it is superseded or the component is disposed. Unsubscribe events and dispose owned timers, cancellation sources, subscriptions, and interop handles using `IDisposable` or `IAsyncDisposable` as their actual cleanup requires. Do not call `StateHasChanged` from disposal; distinguish owned resources from injected shared services.
- Perform DOM-dependent JS interop only once the element/interactive renderer is available, typically after render. Account for prerendering and circuit disconnection for the hosting model in use. Avoid unbounded render/interop loops and broad exception suppression.
- Use stable keys for repeated stateful components when identity matters. Preserve focus, keyboard operation, labels, validation, semantic markup, and accessible loading/error feedback as part of the affected behavior. Avoid unrelated visual redesign.

Inspect component and browser evidence at the scope authorized by the task. Source/build evidence alone does not establish browser behavior, render-mode correctness, or live-service success. Add or run tests only when requested; report browser verification that remains unperformed.


## Source and license

Adapted from the following upstream snapshots (retrieved 2026-11-03). Local guidance narrows scope and preserves task authorization.

- [blazor-author](https://raw.githubusercontent.com/dotnet/skills/95e7d0cb7994d47b5789baa68e13f7a2f348b956/plugins/dotnet-blazor/skills/author-component/SKILL.md)
- [blazor-plan](https://raw.githubusercontent.com/dotnet/skills/95e7d0cb7994d47b5789baa68e13f7a2f348b956/plugins/dotnet-blazor/skills/plan-ui-change/SKILL.md)

Upstream license: [dotnet-LICENSE.txt](dotnet-LICENSE.txt).
