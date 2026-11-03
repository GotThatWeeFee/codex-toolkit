#Requires -Version 5.1
<#
.SYNOPSIS
Installs, updates, or removes only the toolkit's thirteen custom-agent TOMLs.
.DESCRIPTION
CodexHome resolves from the explicit parameter, CODEX_HOME, then $HOME/.codex.
Install/Update back up existing roles before replacement and adopt identical roles.
Remove refuses modified owned files. WhatIf performs preflight only.
Caught failures attempt guarded rollback. Process interruption is not transactional:
inspect reported paths and hashes before manual recovery; never delete unrelated files.
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)][ValidateSet('Install', 'Update', 'Remove')][string]$Action,
    [string]$CodexHome
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Keep this bootstrap compatible with Windows PowerShell 5.1. All role work runs
# under 7.2+; forward operation parameters without rebuilding command text.
if ($PSVersionTable.PSVersion -lt [version]'7.2') {
    function Find-CompatiblePowerShell {
        $candidates = @((Get-Command pwsh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source))
        if ($env:ProgramFiles) { $candidates += Join-Path $env:ProgramFiles 'PowerShell/7/pwsh.exe' }
        foreach ($candidate in ($candidates | Select-Object -Unique)) {
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                $versionText = & $candidate -NoLogo -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()'
                $parsedVersion = $null
                if ($LASTEXITCODE -eq 0 -and [version]::TryParse([string]$versionText, [ref]$parsedVersion) -and $parsedVersion -ge [version]'7.2') { return $candidate }
            }
        }
    }
    $runtime = Find-CompatiblePowerShell
    if (-not $runtime) {
        if ($WhatIfPreference) { Write-Output 'PowerShell 7.2+ is required. A real run will request permission to install Microsoft.PowerShell through winget before continuing.'; return }
        if ($env:OS -ne 'Windows_NT') { throw 'Install PowerShell 7.2+ using your platform package manager, then rerun this script.' }
        $winget = Get-Command winget -CommandType Application -ErrorAction SilentlyContinue
        if (-not $winget) { throw 'winget is unavailable. Install Microsoft App Installer or PowerShell 7.2+, then rerun this script.' }
        $answer = Read-Host 'PowerShell 7.2+ is required. Install/update Microsoft.PowerShell using winget and continue? [y/N]'
        if ($answer -notmatch '^(?i:y|yes)$') { throw 'PowerShell installation declined; agent installation stopped.' }
        & $winget.Source install --id Microsoft.PowerShell --exact --source winget
        if ($LASTEXITCODE -ne 0) { throw "PowerShell installation failed (exit code $LASTEXITCODE); agent installation stopped." }
        $runtime = Find-CompatiblePowerShell
        if (-not $runtime) { throw 'PowerShell 7.2+ was not found after installation; agent installation stopped.' }
    }
    $forwardArguments = @('-NoLogo','-NoProfile')
    if ($env:OS -eq 'Windows_NT') { $forwardArguments += @('-ExecutionPolicy','Bypass') }
    $forwardArguments += @('-File',$PSCommandPath,'-Action',$Action)
    if ($CodexHome) { $forwardArguments += @('-CodexHome',$CodexHome) }
    if ($WhatIfPreference) { $forwardArguments += '-WhatIf' }
    if ($PSBoundParameters.ContainsKey('Confirm')) { $forwardArguments += ('-Confirm:$' + $PSBoundParameters['Confirm'].ToString().ToLowerInvariant()) }
    & $runtime @forwardArguments
    if ($LASTEXITCODE -ne 0) { throw "Agent installer failed (exit code $LASTEXITCODE)." }
    return
}

function Assert-PlainPath([string]$Path) {
    $cursor = [IO.Path]::GetFullPath($Path)
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Link/reparse point refused: $cursor" }
        }
        $parent = [IO.Path]::GetDirectoryName($cursor)
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
}
function Get-Hash([byte[]]$Bytes) { [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($Bytes)).ToLowerInvariant() }
function Read-Bytes([string]$Path) {
    Assert-PlainPath $Path
    if (Test-Path -LiteralPath $Path) {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Expected file: $Path" }
        return ,([IO.File]::ReadAllBytes($Path))
    }
    return $null
}
function Assert-Same([string]$Path, $Expected) {
    $actual = Read-Bytes $Path
    if (($null -eq $actual) -ne ($null -eq $Expected)) { throw "Path changed during operation: $Path" }
    if ($null -ne $actual -and (Get-Hash $actual) -ne (Get-Hash $Expected)) { throw "Content changed during operation: $Path" }
}

if (-not $CodexHome) { $CodexHome = $env:CODEX_HOME }
if (-not $CodexHome) { $CodexHome = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex' }
if (-not [IO.Path]::IsPathFullyQualified($CodexHome)) { throw 'CodexHome must be an absolute path.' }
$root = [IO.Path]::GetFullPath($CodexHome).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
if (-not $root -or $root -eq [IO.Path]::GetPathRoot($root).TrimEnd('\','/')) { throw 'A filesystem root cannot be CodexHome.' }
Assert-PlainPath $root
if ((Test-Path -LiteralPath $root) -and -not (Test-Path -LiteralPath $root -PathType Container)) { throw 'CodexHome must be a directory.' }
$agents = Join-Path $root 'agents'
Assert-PlainPath $agents
if ((Test-Path -LiteralPath $agents) -and -not (Test-Path -LiteralPath $agents -PathType Container)) { throw 'agents must be a directory.' }
$ledgerPath = Join-Path $root '.codex-toolkit-agents.json'
$temporary = "$ledgerPath.tmp"
Assert-PlainPath $temporary
if (Test-Path -LiteralPath $temporary) { throw "Recovery required: inspect existing ledger temporary file $temporary" }
$source = Join-Path $PSScriptRoot 'plugins/codex-toolkit/skills/engineering-subagent-pipeline/custom-agents'
Assert-PlainPath $source
$names = @('accessibility-reviewer','contract-reviewer','documentation-specialist','dotnet-practices-reviewer','final-reviewer','junior-developer','performance-operability-reviewer','planner','qa-engineer','reliability-reviewer','security-reviewer','senior-engineer','test-strategy-reviewer')
$owned = @{}
$ledgerBefore = Read-Bytes $ledgerPath
if ($null -ne $ledgerBefore) {
    $ledger = [Text.Encoding]::UTF8.GetString($ledgerBefore) | ConvertFrom-Json
    if ($ledger.version -ne 1 -or $null -eq $ledger.files -or @($ledger.PSObject.Properties.Name | Where-Object { $_ -notin @('version','files') }).Count) { throw 'Unsupported ownership ledger.' }
    foreach ($entry in $ledger.files) {
        if ($entry.path -cnotmatch '^agents/[a-z][a-z-]*\.toml$' -or $entry.path -cnotin @($names | ForEach-Object { "agents/$_.toml" }) -or $entry.sha256 -cnotmatch '^[0-9a-f]{64}$' -or $owned.ContainsKey($entry.path) -or @($entry.PSObject.Properties.Name | Where-Object { $_ -notin @('path','sha256') }).Count) { throw 'Invalid ownership ledger entry.' }
        $owned[$entry.path] = $entry.sha256
    }
} elseif ($Action -ne 'Install') { throw 'No ownership ledger exists; Update/Remove cannot claim files.' }

# Preflight the complete operation before any filesystem mutation.
$desired = @{}
if ($Action -ne 'Remove') {
    foreach ($name in $names) {
        $bytes = Read-Bytes (Join-Path $source "$name.toml")
        if ($null -eq $bytes) { throw "Missing canonical role: $name" }
        $desired["agents/$name.toml"] = $bytes
    }
}
$changes = [Collections.Generic.List[object]]::new()
$adopted = $false
$allPaths = @(@($owned.Keys) + @($desired.Keys) | Sort-Object -Unique)
foreach ($relative in $allPaths) {
    $destination = [IO.Path]::GetFullPath((Join-Path $root $relative))
    if (-not $destination.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Destination escaped CodexHome.' }
    $before = Read-Bytes $destination
    if ($Action -eq 'Remove' -and $owned.ContainsKey($relative)) {
        if ($null -eq $before -or (Get-Hash $before) -ne $owned[$relative]) { throw "Owned file missing or modified; preserve and reconcile manually: $destination" }
    }
    if (-not $owned.ContainsKey($relative)) { $adopted = $true }
    $after = if ($desired.ContainsKey($relative)) { $desired[$relative] } else { $null }
    if ($null -eq $before -or $null -eq $after -or (Get-Hash $before) -ne (Get-Hash $after)) {
        $changes.Add([pscustomobject]@{ Path=$destination; Before=$before; After=$after })
    }
}
$nextFiles = @($desired.Keys | Sort-Object | ForEach-Object { @{path=$_; sha256=(Get-Hash $desired[$_])} })
$nextLedger = if ($Action -ne 'Remove') { [Text.Encoding]::UTF8.GetBytes((@{version=1;files=$nextFiles} | ConvertTo-Json -Depth 5) + "`n") } else { $null }
if ($changes.Count -eq 0 -and -not $adopted -and $Action -ne 'Remove' -and $null -ne $ledgerBefore) { Write-Output 'Owned role files already match; no changes.'; return }
$backupItems = @($changes | Where-Object { $null -ne $_.Before })
$backupPath = Join-Path $root ('agent-role-backups/' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff') + '-' + [guid]::NewGuid().ToString('N'))
if ($backupItems.Count -or $null -ne $ledgerBefore) {
    Assert-PlainPath $backupPath
    Write-Output "Backup planned: $backupPath ($($backupItems.Count) role file(s); previous ledger included when present)."
}
if (-not $PSCmdlet.ShouldProcess($root, "$Action $($changes.Count) role file(s) and ownership ledger")) { return }

$applied = [Collections.Generic.List[object]]::new()
$createdDirectories = [Collections.Generic.List[string]]::new()
$ledgerChanged = $false
try {
    Assert-Same $ledgerPath $ledgerBefore
    foreach ($directory in @($root,$agents)) {
        Assert-PlainPath $directory
        if (-not (Test-Path -LiteralPath $directory)) {
            # Require an existing parent rather than silently creating an unbounded tree.
            if (-not (Test-Path -LiteralPath ([IO.Path]::GetDirectoryName($directory)) -PathType Container)) { throw "Create the parent directory explicitly first: $directory" }
            [void][IO.Directory]::CreateDirectory($directory)
            $createdDirectories.Add($directory)
        }
    }
    # Complete and verify the durable backup before touching any destination.
    if ($backupItems.Count -or $null -ne $ledgerBefore) {
        Assert-PlainPath $backupPath
        [void][IO.Directory]::CreateDirectory($backupPath)
        foreach ($change in $backupItems) {
            Assert-Same $change.Path $change.Before
            $backupFile = Join-Path $backupPath ([IO.Path]::GetFileName($change.Path))
            $stream = [IO.File]::Open($backupFile,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
            try { $stream.Write($change.Before,0,$change.Before.Length); $stream.Flush($true) } finally { $stream.Dispose() }
            Assert-Same $backupFile $change.Before
        }
        if ($null -ne $ledgerBefore) {
            Assert-Same $ledgerPath $ledgerBefore
            $backupLedger = Join-Path $backupPath '.codex-toolkit-agents.json'
            [IO.File]::WriteAllBytes($backupLedger,$ledgerBefore)
            Assert-Same $backupLedger $ledgerBefore
        }
        Write-Output "Backup saved: $backupPath"
    }
    foreach ($change in $changes) {
        Assert-Same $change.Path $change.Before
        $applied.Add($change)
        if ($null -eq $change.After) { [IO.File]::Delete($change.Path) }
        else {
            # FileMode prevents an unexpected new file from being silently overwritten.
            $mode = if ($null -eq $change.Before) { [IO.FileMode]::CreateNew } else { [IO.FileMode]::Open }
            $stream = [IO.File]::Open($change.Path,$mode,[IO.FileAccess]::Write,[IO.FileShare]::None)
            try { $stream.SetLength(0); $stream.Write([byte[]]$change.After,0,$change.After.Length); $stream.Flush($true) } finally { $stream.Dispose() }
        }
    }
    Assert-Same $ledgerPath $ledgerBefore
    if ($null -eq $nextLedger) { [IO.File]::Delete($ledgerPath) }
    else {
        Assert-PlainPath $temporary
        $stream = [IO.File]::Open($temporary,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
        try { $stream.Write([byte[]]$nextLedger,0,$nextLedger.Length); $stream.Flush($true) } finally { $stream.Dispose() }
        [IO.File]::Move($temporary,$ledgerPath,$null -ne $ledgerBefore)
    }
    $ledgerChanged = $true
    Write-Output "$Action complete: $($changes.Count) role file(s) changed. No configuration, skills, plugins, or hooks changed."
} catch {
    $failure = $_
    $recovery = [Collections.Generic.List[string]]::new()
    if (-not $ledgerChanged) {
        for ($index=$applied.Count-1; $index -ge 0; $index--) {
            $change = $applied[$index]
            try {
                Assert-Same $change.Path $change.After
                if ($null -eq $change.Before) { [IO.File]::Delete($change.Path) } else { [IO.File]::WriteAllBytes($change.Path,$change.Before) }
            } catch { $recovery.Add($change.Path) }
        }
    }
    # Never recursively delete directories or remove an unrecognized temporary file.
    if (Test-Path -LiteralPath $temporary) { $recovery.Add($temporary) }
    foreach ($directory in @($createdDirectories | Sort-Object Length -Descending)) {
        try { Assert-PlainPath $directory; [IO.Directory]::Delete($directory,$false) } catch { }
    }
    if ($recovery.Count) { Write-Warning ('Manual recovery required; preserve content and compare the ledger/source hashes at: ' + ($recovery -join ', ')) }
    throw "Operation failed: $($failure.Exception.Message). Guarded rollback was attempted; interruption or failed rollback may require manual hash reconciliation. Multi-file changes are not atomic."
}
