# Diagnose MSBuild failures with binary logs

Use when the failing target/task, evaluated configuration, or dependency path remains unclear after reading the error and nearby project configuration. Prefer an existing log before rebuilding. A log is evidence of its recorded invocation, not proof of the current runtime or deployment.

1. Record the SDK/MSBuild version, project/solution, command, configuration, target framework, and relevant properties. Identify the first causal error; later failures may be consequences. Distinguish restore, evaluation, target scheduling, and task execution failures.
2. Inspect an existing `.binlog` with an available compatible structured-log viewer or binlog tool. Discover tool availability; installing this reference does not install the upstream BinlogMcp server. Narrow queries to errors, failed target/task, properties, item inputs, imports, and timing. Avoid dumping the whole log.
3. If another build is necessary and authorized, capture a uniquely named log with the narrowest relevant build, for example `dotnet build <project> -bl:<local-path>/build-<unique-id>.binlog`. On supported MSBuild versions, quote `'-bl:{}'` in PowerShell for a unique generated filename; otherwise use an explicit unique name. Verify that the log exists and corresponds to that command. Logging every successful build is unnecessary.
4. If structured tooling is unavailable, MSBuild can replay a binary log into text without rerunning its recorded build: `dotnet msbuild <existing.binlog> -noconlog -fl '-flp:v=diag;logfile=<local-path>/full.log;performancesummary' -fl1 '-flp1:errorsonly;logfile=<local-path>/errors.log'`. Substitute paths and quote logger arguments containing semicolons in PowerShell. This can create large local output; use a task-local destination. Do not treat a binary log as ordinary text.
5. Trace the earliest causal failure to evaluated inputs, imported configuration, and the exact task/tool identity. Compare a known-working invocation where available. Change the smallest supported cause; do not clear caches, disable analyzers, or alter contracts merely to suppress symptoms.

Binary logs and replayed output can contain environment variables, credentials, paths, embedded project files, and sensitive build data. Keep them local; share only authorized, reviewed excerpts. Log capture, tool installation, builds, tests, and live operations remain subject to task authorization. This reference never authorizes running tests.


## Source and license

Adapted from the following upstream snapshots (retrieved 2026-11-03). Local guidance narrows scope and preserves task authorization.

- [binlog-analysis](https://raw.githubusercontent.com/dotnet/skills/95e7d0cb7994d47b5789baa68e13f7a2f348b956/plugins/dotnet-msbuild/skills/binlog-failure-analysis/SKILL.md)
- [binlog-generation](https://raw.githubusercontent.com/dotnet/skills/95e7d0cb7994d47b5789baa68e13f7a2f348b956/plugins/dotnet-msbuild/skills/binlog-generation/SKILL.md)

Upstream license: [dotnet-LICENSE.txt](dotnet-LICENSE.txt).
