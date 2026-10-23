[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,
    [switch]$IncludePlaywright
)

$ErrorActionPreference = 'Stop'
$project = Get-Item -LiteralPath $ProjectPath
if (-not $project.PSIsContainer) { throw 'ProjectPath must be an existing directory.' }
$projectRoot = $project.FullName
$bundleRoot = $PSScriptRoot
if ($projectRoot -eq $bundleRoot -or $projectRoot.StartsWith($bundleRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Choose a target project outside the toolkit bundle.'
}

$maps = @(
    @{ Source = '.agents/skills/engineering-pipeline'; Target = '.agents/skills/engineering-pipeline' },
    @{ Source = '.agents/skills/request-model-gate'; Target = '.agents/skills/request-model-gate' },
    @{ Source = '.codex/agents'; Target = '.codex/agents' }
)
if ($IncludePlaywright) {
    $maps += @{ Source = 'optional/skills/playwright'; Target = '.agents/skills/playwright' }
}

# Complete preflight before copying. Refuse links/junctions to avoid writing outside
# the selected project through an existing redirected ancestor.
$check = $project
while ($null -ne $check) {
    if ($check.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Target path contains a link or junction; choose a direct path.' }
    $check = $check.Parent
}
$plan = @()
foreach ($map in $maps) {
    $sourceRoot = Join-Path $bundleRoot $map.Source
    $sourceItem = Get-Item -LiteralPath $sourceRoot
    if ($sourceItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Bundle source cannot be a link or junction.' }
    foreach ($item in Get-ChildItem -LiteralPath $sourceRoot -Recurse -Force) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Bundle contains a link or junction.' }
        if ($item.PSIsContainer) { continue }
        $relative = $item.FullName.Substring($sourceRoot.Length).TrimStart('\', '/')
        $target = [IO.Path]::GetFullPath((Join-Path (Join-Path $projectRoot $map.Target) $relative))
        if (-not $target.StartsWith($projectRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Destination escaped the intended project.'
        }
        if (Test-Path -LiteralPath $target) { throw "Destination already exists; no files copied: $target" }
        $parentPath = [IO.Path]::GetDirectoryName($target)
        while ($parentPath -and $parentPath.Length -ge $projectRoot.Length) {
            if (Test-Path -LiteralPath $parentPath) {
                $parent = Get-Item -LiteralPath $parentPath
                if (-not $parent.PSIsContainer) { throw "Destination ancestor is a file: $parentPath" }
                if ($parent.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Destination ancestor is a link or junction: $parentPath" }
            }
            if ($parentPath -eq $projectRoot) { break }
            $parentPath = [IO.Path]::GetDirectoryName($parentPath)
        }
        $plan += @{ Source = $item.FullName; Target = $target }
    }
}

if ($PSCmdlet.ShouldProcess($projectRoot, "Copy $($plan.Count) toolkit files without overwriting")) {
    foreach ($entry in $plan) {
        $null = [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($entry.Target))
        [IO.File]::Copy($entry.Source, $entry.Target, $false)
    }
    Write-Output "Copied $($plan.Count) files. Config and AGENTS.md require manual review/merge."
} else {
    Write-Output "Preview only: $($plan.Count) files selected. No files copied."
}
