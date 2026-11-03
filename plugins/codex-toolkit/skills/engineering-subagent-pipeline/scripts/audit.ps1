[CmdletBinding()]
param(
    [ValidateSet('SessionStart', 'UserPromptSubmit', 'SubagentStart', 'SubagentStop', 'PreCompact', 'PostCompact', 'Interrupt', 'Stop', 'SessionEnd')]
    [string]$HookEvent,

    [ValidateSet('PlanApproved', 'ImplementationCompleted', 'ReviewCompleted', 'ValidationCompleted', 'HandoffBlocked', 'HandoffReady')]
    [string]$CoordinatorFact,

    [ValidatePattern('^[a-f0-9]{64}$')]
    [string]$WorkspaceFingerprint,

    [ValidatePattern('^[a-f0-9]{64}$')]
    [string]$SessionFingerprint,

    [ValidatePattern('^[a-f0-9]{64}$')]
    [string]$AgentFingerprint,

    [ValidatePattern('^[a-f0-9]{64}$')]
    [string]$RunFingerprint,

    [ValidatePattern('^[a-f0-9]{64}$')]
    [string]$CoordinatorEventFingerprint,

    [ValidateSet('', 'AppendFailure', 'SummaryFailure', 'LockTimeout')]
    [string]$TestFault = '',

    [string]$TestCanonicalAuditRoot,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$AuditRoot
)

# Coordinator writes rely on file, cryptographic, and mutex APIs that are not
# available under constrained language. Hooks remain observational and fail open.
if ($ExecutionContext.SessionState.LanguageMode -ne 'FullLanguage') {
    if ($CoordinatorFact) {
        [Console]::Error.WriteLine('Coordinator auditing requires a trusted FullLanguage execution route.')
        exit 2
    }
    if ($HookEvent -in @('Stop', 'SubagentStop')) { [Console]::Out.Write('{}') }
    exit 0
}

# This adapter intentionally accepts a small metadata allowlist. It never persists
# hook-provided prompts, messages, transcript paths, tool input/output, or raw paths.
$ErrorActionPreference = 'Stop'
$MaximumHookInputCharacters = 65536

function Get-CanonicalAuditRoot {
    param([string]$Root)

    if ([string]::IsNullOrWhiteSpace($Root)) { throw 'The audit root is required.' }
    $fullPath = [System.IO.Path]::GetFullPath($Root)
    $filesystemRoot = [System.IO.Path]::GetPathRoot($fullPath)
    if ($fullPath -eq $filesystemRoot) { return $fullPath }
    return $fullPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
}

function Read-BoundedHookInput {
    param([int]$MaximumCharacters)

    $builder = New-Object System.Text.StringBuilder
    while ($true) {
        $character = [Console]::In.Read()
        if ($character -lt 0) { break }
        if ($builder.Length -ge $MaximumCharacters) { throw 'Hook input exceeded the permitted size.' }
        [void]$builder.Append([char]$character)
    }
    return $builder.ToString()
}

function Test-HookInputShape {
    param([object]$InputObject)

    if ($null -eq $InputObject -or $InputObject -is [array] -or $InputObject -is [string]) { return $false }
    foreach ($property in $InputObject.PSObject.Properties) {
        if ($property.Value -is [System.Collections.IDictionary] -or
            ($property.Value -is [System.Collections.IEnumerable] -and $property.Value -isnot [string])) {
            return $false
        }
        if ($null -ne $property.Value -and $property.Value -isnot [string] -and
            $property.Value -isnot [bool] -and $property.Value -isnot [ValueType]) {
            return $false
        }
    }
    return $true
}

function Get-StringProperty {
    param([object]$Object, [string]$Name, [int]$MaximumLength = 256)

    if ($null -eq $Object) { return $null }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return $null }
    if ($property.Value -isnot [string]) { return $null }
    $value = $property.Value.Trim()
    if ($value.Length -eq 0 -or $value.Length -gt $MaximumLength) { return $null }
    return $value
}

function Get-AllowedToken {
    param([string]$Value, [int]$MaximumLength = 80)

    if ([string]::IsNullOrWhiteSpace($Value) -or $Value.Length -gt $MaximumLength) { return $null }
    if ($Value -notmatch '^[A-Za-z0-9._:-]+$') { return $null }
    return $Value
}

function Get-AuditKey {
    param([string]$Root)

    $keyPath = Join-Path $Root '.workspace-key'
    foreach ($retryDelayMilliseconds in @(0, 25, 50, 100, 200)) {
        if ($retryDelayMilliseconds -gt 0) { Start-Sleep -Milliseconds $retryDelayMilliseconds }
        if ([System.IO.File]::Exists($keyPath)) { return [System.IO.File]::ReadAllBytes($keyPath) }

        $key = New-Object byte[] 32
        (New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($key)
        $temporaryPath = "$keyPath.$([Guid]::NewGuid().ToString('N')).tmp"
        [System.IO.File]::WriteAllBytes($temporaryPath, $key)
        try {
            [System.IO.File]::Move($temporaryPath, $keyPath)
            return $key
        }
        catch [System.IO.IOException] {
            if ([System.IO.File]::Exists($keyPath)) { return [System.IO.File]::ReadAllBytes($keyPath) }
        }
        finally {
            if ([System.IO.File]::Exists($temporaryPath)) {
                Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
    throw 'Unable to initialize or read the audit key.'
}

function Get-Fingerprint {
    param([string]$Domain, [string]$Value, [byte[]]$Key)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes("$Domain`0$Value")
    $hmac = [System.Security.Cryptography.HMACSHA256]::new($Key)
    try { return ([System.BitConverter]::ToString($hmac.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $hmac.Dispose() }
}

function Get-AuditMutexName {
    param([string]$Root, [string]$Purpose = 'append')

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Purpose + [char]0 + $Root.ToLowerInvariant())
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return 'Local\CodexPipelineAudit_' + (([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').Substring(0, 24)) }
    finally { $sha.Dispose() }
}

function Enter-AuditMutex {
    param([System.Threading.Mutex]$Mutex, [int]$TimeoutMilliseconds, [bool]$ForceTimeout = $false)

    if ($ForceTimeout) { return $false }
    try { return $Mutex.WaitOne($TimeoutMilliseconds) }
    catch [System.Threading.AbandonedMutexException] { return $true }
}

function Write-AtomicText {
    param([string]$Path, [string]$Content)

    $temporaryPath = "$Path.$([Guid]::NewGuid().ToString('N')).tmp"
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $stream = New-Object System.IO.FileStream($temporaryPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    try {
        $bytes = $encoding.GetBytes($Content)
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush($true)
    }
    finally { $stream.Dispose() }

    if ([System.IO.File]::Exists($Path)) {
        [System.IO.File]::Replace($temporaryPath, $Path, "$Path.previous", $true)
    }
    else {
        [System.IO.File]::Move($temporaryPath, $Path)
    }
}

function Read-AuditSequence {
    param([string]$Path)

    if (-not [System.IO.File]::Exists($Path)) { return [Int64]0 }
    [Int64]$sequence = 0
    if (-not [Int64]::TryParse([System.IO.File]::ReadAllText($Path).Trim(), [ref]$sequence) -or $sequence -lt 0) {
        throw 'The audit sequence file is invalid.'
    }
    return $sequence
}

function Repair-IncompleteTerminalRecord {
    param([string]$EventPath, [string]$Root)

    if (-not [System.IO.File]::Exists($EventPath)) { return }
    $content = [System.IO.File]::ReadAllText($EventPath)
    if ($content.Length -eq 0) { return }

    $tailMatch = $null
    foreach ($match in [regex]::Matches($content, '[^\r\n]+')) {
        if (-not [string]::IsNullOrWhiteSpace($match.Value)) {
            $tailMatch = $match
        }
    }
    if ($null -eq $tailMatch) { return }

    $prefix = $content.Substring(0, $tailMatch.Index)
    $tail = $tailMatch.Value
    $suffix = $content.Substring($tailMatch.Index + $tailMatch.Length)
    try {
        $tail | ConvertFrom-Json -ErrorAction Stop | Out-Null
        if (-not $content.EndsWith([string][char]10)) {
            Write-AtomicText -Path $EventPath -Content ($prefix + $tail + $suffix + [Environment]::NewLine)
        }
    }
    catch {
        $quarantine = Join-Path (Join-Path (Join-Path $Root 'events') 'quarantine') ('terminal-partial-' + [Guid]::NewGuid().ToString('N') + '.json')
        [System.IO.Directory]::CreateDirectory((Split-Path -Parent $quarantine)) | Out-Null
        Write-AtomicText -Path $quarantine -Content $tail
        Write-AtomicText -Path $EventPath -Content ($prefix + $suffix)
    }
}

function Test-IdenticalCoordinatorRecord {
    param([System.Collections.IDictionary]$Record, [object]$Event)

    if ($Event.source -ne 'coordinator' -or $Event.event_type -ne 'CoordinatorFact') { return $false }
    return ((Get-MetadataValue $Event 'coordinator_event_fingerprint') -eq [string]$Record.metadata.coordinator_event_fingerprint -and
        [string]$Event.fact -eq [string]$Record.fact -and
        (Get-MetadataValue $Event 'run_fingerprint') -eq [string]$Record.metadata.run_fingerprint -and
        (Get-MetadataValue $Event 'workspace_fingerprint') -eq [string]$Record.metadata.workspace_fingerprint)
}

function Add-AuditRecord {
    param([System.Collections.IDictionary]$Record, [string]$Root, [string]$Fault = '')

    $Root = Get-CanonicalAuditRoot $Root
    [System.IO.Directory]::CreateDirectory($Root) | Out-Null
    [System.IO.Directory]::CreateDirectory((Join-Path $Root 'events')) | Out-Null
    [System.IO.Directory]::CreateDirectory((Join-Path $Root 'handoffs')) | Out-Null
    $mutex = New-Object System.Threading.Mutex($false, (Get-AuditMutexName $Root 'append'))
    $lockTaken = $false
    try {
        $lockTaken = Enter-AuditMutex -Mutex $mutex -TimeoutMilliseconds 5000 -ForceTimeout ($Fault -eq 'LockTimeout')
        if (-not $lockTaken) { return $false }
        if ($Fault -eq 'AppendFailure') { return $false }

        $sequencePath = Join-Path $Root '.sequence'
        $eventPath = Join-Path (Join-Path $Root 'events') 'events.jsonl'
        Repair-IncompleteTerminalRecord -EventPath $eventPath -Root $Root
        if ($Record.source -eq 'coordinator') {
            $existingWithEventFingerprint = @(
                Get-AuditEvents -Root $Root | Where-Object {
                    $_.source -eq 'coordinator' -and
                    (Get-MetadataValue $_ 'coordinator_event_fingerprint') -eq [string]$Record.metadata.coordinator_event_fingerprint
                })
            if ($existingWithEventFingerprint.Count -gt 0) {
                foreach ($existing in $existingWithEventFingerprint) {
                    if (-not (Test-IdenticalCoordinatorRecord -Record $Record -Event $existing)) { return $false }
                }
                return $true
            }
        }
        $nextSequence = (Read-AuditSequence $sequencePath) + 1
        Write-AtomicText -Path $sequencePath -Content ([string]$nextSequence)
        $Record.sequence = $nextSequence

        $line = $Record | ConvertTo-Json -Depth 6 -Compress
        $encoding = New-Object System.Text.UTF8Encoding($false)
        $stream = New-Object System.IO.FileStream($eventPath, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
        try {
            $bytes = $encoding.GetBytes($line + [Environment]::NewLine)
            $stream.Write($bytes, 0, $bytes.Length)
            $stream.Flush($true)
        }
        finally { $stream.Dispose() }
        return $true
    }
    finally {
        if ($lockTaken) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}

function Get-AuditEvents {
    param([string]$Root)

    $eventPath = Join-Path (Join-Path $Root 'events') 'events.jsonl'
    if (-not [System.IO.File]::Exists($eventPath)) { return @() }
    $events = @()
    foreach ($line in [System.IO.File]::ReadAllLines($eventPath)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $events += ($line | ConvertFrom-Json -ErrorAction Stop) }
        catch { }
    }
    return @($events | Sort-Object -Property sequence)
}

function Get-AuditSnapshot {
    param([string]$Root, [string]$Fault = '')

    $Root = Get-CanonicalAuditRoot $Root
    [System.IO.Directory]::CreateDirectory((Join-Path $Root 'events')) | Out-Null
    $mutex = New-Object System.Threading.Mutex($false, (Get-AuditMutexName $Root 'append'))
    $lockTaken = $false
    try {
        $lockTaken = Enter-AuditMutex -Mutex $mutex -TimeoutMilliseconds 500 -ForceTimeout ($Fault -eq 'LockTimeout')
        if (-not $lockTaken) { return $null }
        $eventPath = Join-Path (Join-Path $Root 'events') 'events.jsonl'
        Repair-IncompleteTerminalRecord -EventPath $eventPath -Root $Root
        $content = if ([System.IO.File]::Exists($eventPath)) { [System.IO.File]::ReadAllText($eventPath) } else { '' }
        return [pscustomobject]@{
            Content = $content
            Sequence = Read-AuditSequence (Join-Path $Root '.sequence')
        }
    }
    finally {
        if ($lockTaken) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}

function Get-AuditEventsFromSnapshot {
    param([string]$Content)

    $events = New-Object 'System.Collections.Generic.List[object]'
    foreach ($line in $Content -split [char]10) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { [void]$events.Add(($line | ConvertFrom-Json -ErrorAction Stop)) }
        catch { }
    }
    return @($events | Sort-Object -Property sequence)
}

function Get-MetadataValue {
    param([object]$Event, [string]$Name)
    if ($null -eq $Event.metadata) { return $null }
    $property = $Event.metadata.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return [string]$property.Value
}

function Get-DisplayFingerprint {
    param([string]$Fingerprint)
    if ([string]::IsNullOrWhiteSpace($Fingerprint)) { return 'unscoped' }
    return $Fingerprint.Substring(0, [Math]::Min(12, $Fingerprint.Length))
}

function Get-LatestRecordedAtUtc {
    param([object[]]$Events)

    $timestamps = New-Object 'System.Collections.Generic.List[datetime]'
    foreach ($event in $Events) {
        $timestamp = [datetime]::MinValue
        if ([datetime]::TryParse([string]$event.recorded_at_utc, [ref]$timestamp)) {
            [void]$timestamps.Add($timestamp.ToUniversalTime())
        }
    }
    if ($timestamps.Count -eq 0) { return 'unknown' }
    return (($timestamps | Sort-Object -Descending | Select-Object -First 1).ToString('yyyy-MM-ddTHH:mm:ssZ'))
}

function Render-HardenedAuditSummary {
    param([object[]]$Events)

    $coordinatorByRun = @{}
    $hooksByWorkspace = @{}
    foreach ($event in $Events) {
        $workspace = Get-MetadataValue $event 'workspace_fingerprint'
        if ([string]::IsNullOrWhiteSpace($workspace)) { $workspace = 'unscoped' }
        if ($event.source -eq 'coordinator') {
            $run = Get-MetadataValue $event 'run_fingerprint'
            if ([string]::IsNullOrWhiteSpace($run)) { $run = 'legacy' }
            $key = $workspace + [char]0 + $run
            if (-not $coordinatorByRun.ContainsKey($key)) {
                $coordinatorByRun[$key] = [pscustomobject]@{ Workspace = $workspace; Run = $run; Events = (New-Object 'System.Collections.Generic.List[object]') }
            }
            [void]$coordinatorByRun[$key].Events.Add($event)
        }
        elseif ($event.source -eq 'hook') {
            if (-not $hooksByWorkspace.ContainsKey($workspace)) { $hooksByWorkspace[$workspace] = (New-Object 'System.Collections.Generic.List[object]') }
            [void]$hooksByWorkspace[$workspace].Add($event)
        }
    }

    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add('# Engineering pipeline audit handoff')
    $lines.Add('')
    $lines.Add('_This is a historical snapshot. Times show the latest event recorded for each row; it does not establish live readiness._')
    $lines.Add('')
    $lines.Add('## Gate facts')
    $lines.Add('')
    if ($coordinatorByRun.Count -eq 0) {
        $lines.Add('_No coordinator gate facts recorded._')
    }
    else {
        $lines.Add('| Workspace | Run | Plan approved | Implementation completed | Review completed | Validation completed | Handoff | Latest recorded (UTC) |')
        $lines.Add('| --- | --- | --- | --- | --- | --- | --- | --- |')
        foreach ($entry in @($coordinatorByRun.Values | Sort-Object -Property Workspace, Run)) {
            $state = @{ Plan = $false; Implementation = $false; Review = $false; Validation = $false; Blocked = ($entry.Run -eq 'legacy' -or $entry.Workspace -eq 'unscoped'); Handoff = 'blocked' }
            foreach ($event in @($entry.Events | Sort-Object -Property sequence)) {
                if ($state.Blocked) { continue }
                switch ([string]$event.fact) {
                    'PlanApproved' { $state.Plan = $true }
                    'ImplementationCompleted' { if ($state.Plan) { $state.Implementation = $true } else { $state.Blocked = $true } }
                    'ReviewCompleted' { if ($state.Implementation) { $state.Review = $true } else { $state.Blocked = $true } }
                    'ValidationCompleted' { if ($state.Review) { $state.Validation = $true } else { $state.Blocked = $true } }
                    'HandoffBlocked' { $state.Blocked = $true; $state.Handoff = 'blocked' }
                    'HandoffReady' {
                        if ($state.Plan -and $state.Implementation -and $state.Review -and $state.Validation) { $state.Handoff = 'ready' }
                        else { $state.Blocked = $true }
                    }
                }
            }
            if ($state.Blocked) { $state.Handoff = 'blocked' }
            $planText = if ($state.Plan) { 'yes' } else { 'no' }
            $implementationText = if ($state.Implementation) { 'yes' } else { 'no' }
            $reviewText = if ($state.Review) { 'yes' } else { 'no' }
            $validationText = if ($state.Validation) { 'yes' } else { 'no' }
            $latestRecordedAt = Get-LatestRecordedAtUtc -Events @($entry.Events | ForEach-Object { $_ })
            $lines.Add("| $(Get-DisplayFingerprint $entry.Workspace) | $(Get-DisplayFingerprint $entry.Run) | $planText | $implementationText | $reviewText | $validationText | $($state.Handoff) | $latestRecordedAt |")
        }
    }
    $lines.Add('')
    $lines.Add('## Hook observations')
    $lines.Add('')
    if ($hooksByWorkspace.Count -eq 0) {
        $lines.Add('_No hook observations recorded._')
    }
    else {
        $lines.Add('| Workspace | Observations | Event types | Latest observation (UTC) |')
        $lines.Add('| --- | --- | --- | --- |')
        foreach ($workspace in @($hooksByWorkspace.Keys | Sort-Object)) {
            $observations = $hooksByWorkspace[$workspace]
            $types = @($observations | ForEach-Object { [string]$_.event_type } | Sort-Object -Unique) -join ', '
            $latestObservedAt = Get-LatestRecordedAtUtc -Events @($observations | ForEach-Object { $_ })
            $lines.Add("| $(Get-DisplayFingerprint $workspace) | $($observations.Count) | $types | $latestObservedAt |")
        }
    }
    return (($lines -join [Environment]::NewLine) + [Environment]::NewLine)
}

function Write-HardenedAuditSummary {
    param([string]$Root, [string]$Fault = '')

    $Root = Get-CanonicalAuditRoot $Root
    if ($Fault -eq 'SummaryFailure') { return $false }
    [System.IO.Directory]::CreateDirectory((Join-Path $Root 'handoffs')) | Out-Null
    for ($attempt = 0; $attempt -lt 3; $attempt++) {
        $snapshot = Get-AuditSnapshot -Root $Root -Fault $Fault
        if ($null -eq $snapshot) { return $false }
        $content = Render-HardenedAuditSummary -Events (Get-AuditEventsFromSnapshot $snapshot.Content)
        $summaryMutex = New-Object System.Threading.Mutex($false, (Get-AuditMutexName $Root 'summary'))
        $summaryLockTaken = $false
        $appendMutex = $null
        $appendLockTaken = $false
        try {
            $summaryLockTaken = Enter-AuditMutex -Mutex $summaryMutex -TimeoutMilliseconds 500 -ForceTimeout ($Fault -eq 'LockTimeout')
            if (-not $summaryLockTaken) { return $false }

            # Keep the append lock through the final sequence check and atomic publication.
            # A new append therefore cannot make this snapshot stale between those operations.
            $appendMutex = New-Object System.Threading.Mutex($false, (Get-AuditMutexName $Root 'append'))
            $appendLockTaken = Enter-AuditMutex -Mutex $appendMutex -TimeoutMilliseconds 500 -ForceTimeout ($Fault -eq 'LockTimeout')
            if (-not $appendLockTaken) { return $false }
            $eventPath = Join-Path (Join-Path $Root 'events') 'events.jsonl'
            $sequencePath = Join-Path $Root '.sequence'
            Repair-IncompleteTerminalRecord -EventPath $eventPath -Root $Root
            $currentSequence = Read-AuditSequence $sequencePath
            if ($currentSequence -ne $snapshot.Sequence) { continue }

            Write-AtomicText -Path (Join-Path (Join-Path $Root 'handoffs') 'latest.md') -Content $content
            return $true
        }
        finally {
            if ($appendLockTaken) { $appendMutex.ReleaseMutex() }
            if ($null -ne $appendMutex) { $appendMutex.Dispose() }
            if ($summaryLockTaken) { $summaryMutex.ReleaseMutex() }
            $summaryMutex.Dispose()
        }
    }
    return $false
}

function Write-AuditSummary {
    param([string]$Root)

    [System.IO.Directory]::CreateDirectory($Root) | Out-Null
    [System.IO.Directory]::CreateDirectory((Join-Path $Root 'handoffs')) | Out-Null
    $mutex = New-Object System.Threading.Mutex($false, (Get-AuditMutexName $Root))
    $lockTaken = $false
    try {
        $lockTaken = $mutex.WaitOne(500)
        if (-not $lockTaken) { return $false }
        $events = Get-AuditEvents $Root
        $coordinatorByWorkspace = @{}
        $hooksByWorkspace = @{}
        foreach ($event in $events) {
            $workspace = Get-MetadataValue $event 'workspace_fingerprint'
            if ([string]::IsNullOrWhiteSpace($workspace)) { $workspace = 'unscoped' }
            if ($event.source -eq 'coordinator') {
                if (-not $coordinatorByWorkspace.ContainsKey($workspace)) { $coordinatorByWorkspace[$workspace] = @() }
                $coordinatorByWorkspace[$workspace] += $event
            }
            elseif ($event.source -eq 'hook') {
                if (-not $hooksByWorkspace.ContainsKey($workspace)) { $hooksByWorkspace[$workspace] = @() }
                $hooksByWorkspace[$workspace] += $event
            }
        }

        $lines = New-Object System.Collections.Generic.List[string]
        $lines.Add('# Engineering pipeline audit handoff')
        $lines.Add('')
        $lines.Add('## Gate facts')
        $lines.Add('')
        if ($coordinatorByWorkspace.Count -eq 0) {
            $lines.Add('_No coordinator gate facts recorded._')
        }
        else {
            $lines.Add('| Workspace | Plan approved | Implementation completed | Review completed | Validation completed | Handoff |')
            $lines.Add('| --- | --- | --- | --- | --- | --- |')
            foreach ($workspace in @($coordinatorByWorkspace.Keys | Sort-Object)) {
                $state = @{ Plan = $false; Implementation = $false; Review = $false; Validation = $false; Handoff = 'not recorded' }
                foreach ($event in @($coordinatorByWorkspace[$workspace] | Sort-Object -Property sequence)) {
                    switch ([string]$event.fact) {
                        'PlanApproved' { $state.Plan = $true }
                        'ImplementationCompleted' { if ($state.Plan) { $state.Implementation = $true } }
                        'ReviewCompleted' { if ($state.Implementation) { $state.Review = $true } }
                        'ValidationCompleted' { if ($state.Review) { $state.Validation = $true } }
                        'HandoffBlocked' { $state.Handoff = 'blocked' }
                        'HandoffReady' {
                            if ($state.Plan -and $state.Implementation -and $state.Review -and $state.Validation) { $state.Handoff = 'ready' }
                            else { $state.Handoff = 'blocked' }
                        }
                    }
                }
                $lines.Add("| $(Get-DisplayFingerprint $workspace) | $(if ($state.Plan) { 'yes' } else { 'no' }) | $(if ($state.Implementation) { 'yes' } else { 'no' }) | $(if ($state.Review) { 'yes' } else { 'no' }) | $(if ($state.Validation) { 'yes' } else { 'no' }) | $($state.Handoff) |")
            }
        }

        $lines.Add('')
        $lines.Add('## Hook observations')
        $lines.Add('')
        if ($hooksByWorkspace.Count -eq 0) {
            $lines.Add('_No hook observations recorded._')
        }
        else {
            $lines.Add('| Workspace | Observations | Event types |')
            $lines.Add('| --- | --- | --- |')
            foreach ($workspace in @($hooksByWorkspace.Keys | Sort-Object)) {
                $observations = @($hooksByWorkspace[$workspace])
                $types = @($observations | ForEach-Object { [string]$_.event_type } | Sort-Object -Unique) -join ', '
                $lines.Add("| $(Get-DisplayFingerprint $workspace) | $($observations.Count) | $types |")
            }
        }
        Write-AtomicText -Path (Join-Path (Join-Path $Root 'handoffs') 'latest.md') -Content (($lines -join [Environment]::NewLine) + [Environment]::NewLine)
        return $true
    }
    finally {
        if ($lockTaken) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}

function Get-HookMetadata {
    param([object]$InputObject, [string]$EventName, [byte[]]$Key)

    $metadata = [ordered]@{}
    $sessionId = Get-StringProperty $InputObject 'session_id'
    if ($sessionId) { $metadata.session_fingerprint = Get-Fingerprint 'session' $sessionId $Key }
    $cwd = Get-StringProperty $InputObject 'cwd' 2048
    if ($cwd) { $metadata.workspace_fingerprint = Get-Fingerprint 'workspace' $cwd $Key }

    $model = Get-AllowedToken (Get-StringProperty $InputObject 'model' 80)
    if ($model) { $metadata.model = $model }
    $permissionMode = Get-StringProperty $InputObject 'permission_mode' 32
    if ($permissionMode -in @('default', 'acceptEdits', 'bypassPermissions', 'plan', 'dontAsk')) { $metadata.permission_mode = $permissionMode }

    if ($EventName -eq 'SessionStart') {
        $source = Get-StringProperty $InputObject 'source' 32
        if ($source -in @('startup', 'resume', 'clear', 'compact')) { $metadata.source = $source }
    }
    if ($EventName -in @('PreCompact', 'PostCompact')) {
        $trigger = Get-StringProperty $InputObject 'trigger' 32
        if ($trigger -in @('manual', 'auto')) { $metadata.trigger = $trigger }
    }
    if ($EventName -in @('SubagentStart', 'SubagentStop')) {
        $agentType = Get-AllowedToken (Get-StringProperty $InputObject 'agent_type' 64) 64
        if ($agentType) { $metadata.agent_type = $agentType }
        $agentId = Get-StringProperty $InputObject 'agent_id'
        if ($agentId) { $metadata.agent_fingerprint = Get-Fingerprint 'agent' $agentId $Key }
    }
    if ($EventName -eq 'SessionEnd') {
        $reason = Get-AllowedToken (Get-StringProperty $InputObject 'reason' 64) 64
        if ($reason) { $metadata.reason = $reason }
    }
    return $metadata
}

if ($PSBoundParameters.ContainsKey('TestCanonicalAuditRoot')) {
    [Console]::Out.WriteLine((Get-CanonicalAuditRoot $TestCanonicalAuditRoot))
    exit 0
}

try {
    if ($CoordinatorFact) {
        $AuditRoot = Get-CanonicalAuditRoot $AuditRoot
        if (-not $WorkspaceFingerprint) { throw 'Coordinator facts require a workspace fingerprint.' }
        if (-not $RunFingerprint) { throw 'Coordinator facts require a run fingerprint.' }
        if (-not $CoordinatorEventFingerprint) { throw 'Coordinator facts require a coordinator event fingerprint.' }
        $metadata = [ordered]@{}
        $metadata.workspace_fingerprint = $WorkspaceFingerprint
        if ($SessionFingerprint) { $metadata.session_fingerprint = $SessionFingerprint }
        if ($AgentFingerprint) { $metadata.agent_fingerprint = $AgentFingerprint }
        $metadata.run_fingerprint = $RunFingerprint
        $metadata.coordinator_event_fingerprint = $CoordinatorEventFingerprint
        $record = [ordered]@{
            schema_version = 1
            sequence = 0
            recorded_at_utc = [DateTime]::UtcNow.ToString('o')
            source = 'coordinator'
            event_type = 'CoordinatorFact'
            fact = $CoordinatorFact
            metadata = $metadata
        }
        if (-not (Add-AuditRecord -Record $record -Root $AuditRoot -Fault $TestFault)) { throw 'Coordinator audit append failed.' }
        if (-not (Write-HardenedAuditSummary -Root $AuditRoot -Fault $TestFault)) { throw 'Coordinator audit summary failed.' }
    }
    elseif ($HookEvent) {
        $AuditRoot = Get-CanonicalAuditRoot $AuditRoot
        $rawInput = Read-BoundedHookInput -MaximumCharacters $MaximumHookInputCharacters
        if (-not [string]::IsNullOrWhiteSpace($rawInput)) {
            $inputObject = $rawInput | ConvertFrom-Json -ErrorAction Stop
            if (-not (Test-HookInputShape $inputObject)) { throw 'Hook input did not have the allowed shallow shape.' }
            [System.IO.Directory]::CreateDirectory($AuditRoot) | Out-Null
            $key = $null
            foreach ($retryDelayMilliseconds in @(0, 50, 100, 200)) {
                if ($retryDelayMilliseconds -gt 0) { Start-Sleep -Milliseconds $retryDelayMilliseconds }
                try {
                    $key = Get-AuditKey $AuditRoot
                    break
                }
                catch {
                    # A concurrently creating hook can transiently hold the key path.
                }
            }
            if ($null -eq $key) { throw 'Unable to obtain the audit key.' }
            $record = [ordered]@{
                schema_version = 1
                sequence = 0
                recorded_at_utc = [DateTime]::UtcNow.ToString('o')
                source = 'hook'
                event_type = $HookEvent
                metadata = (Get-HookMetadata -InputObject $inputObject -EventName $HookEvent -Key $key)
            }
            # Hook delivery is best effort, but a short bounded retry absorbs normal
            # startup contention without turning observational hooks into a blocker.
            foreach ($retryDelayMilliseconds in @(0, 50, 100, 200)) {
                if ($retryDelayMilliseconds -gt 0) { Start-Sleep -Milliseconds $retryDelayMilliseconds }
                try {
                    if (Add-AuditRecord -Record $record -Root $AuditRoot) { break }
                }
                catch {
                    # Hooks fail open; never expose input-derived error details.
                }
            }
        }
    }
}
catch {
    if ($CoordinatorFact) {
        [Console]::Error.WriteLine('Coordinator audit operation failed.')
        exit 2
    }
    # Hooks must fail open. Deliberately do not write input-derived error details.
}
finally {
    if ($HookEvent -in @('Stop', 'SubagentStop')) { [Console]::Out.Write('{}') }
}

exit 0
