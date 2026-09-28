# Licensed under the Apache License, Version 2.0.
# Copyright 2026 mp3monster.org

<#
.SYNOPSIS
Copies this OpAMP demo overlay into an installed opamp-core deployment.

.PARAMETER CoreRoot
The installed opamp-core deployment root that should receive the overlay.

.PARAMETER SourceRoot
The opamp-demos repository root. Defaults to the parent of this script folder.

.PARAMETER WhatIf
Shows the copy operations without writing files.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$CoreRoot,

    [string]$SourceRoot = ""
)

$ErrorActionPreference = "Stop"

function Resolve-OverlaySourceRoot {
    <#
    .SYNOPSIS
    Resolves the overlay repository root.

    .PARAMETER RawSourceRoot
    Optional source root supplied by the caller. When blank, the function uses
    the parent folder of the script directory.
    #>
    param(
        [string]$RawSourceRoot
    )

    if ([string]::IsNullOrWhiteSpace($RawSourceRoot)) {
        return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
    }

    return (Resolve-Path -LiteralPath $RawSourceRoot).Path
}

function Assert-OverlaySource {
    <#
    .SYNOPSIS
    Verifies that the overlay source root contains the expected folders.

    .PARAMETER ResolvedSourceRoot
    Absolute path to the opamp-demos source root.
    #>
    param(
        [string]$ResolvedSourceRoot
    )

    $requiredPaths = @(
        "cli\config\demo_consumer_profiles.full_multi_agent.json",
        "demos\full_multi_agent\readme.md"
    )

    foreach ($relativePath in $requiredPaths) {
        $candidatePath = Join-Path $ResolvedSourceRoot $relativePath
        if (-not (Test-Path -LiteralPath $candidatePath)) {
            throw "Overlay source is missing required path: $candidatePath"
        }
    }
}

function Copy-OverlayFolder {
    <#
    .SYNOPSIS
    Merges one overlay folder into the installed core deployment.

    .PARAMETER ResolvedSourceRoot
    Absolute path to the opamp-demos source root.

    .PARAMETER ResolvedCoreRoot
    Absolute path to the installed opamp-core root.

    .PARAMETER FolderName
    Top-level folder to merge, such as cli or demos.
    #>
    param(
        [string]$ResolvedSourceRoot,
        [string]$ResolvedCoreRoot,
        [string]$FolderName
    )

    $sourcePath = Join-Path $ResolvedSourceRoot $FolderName
    $targetPath = Join-Path $ResolvedCoreRoot $FolderName
    New-Item -ItemType Directory -Force -Path $targetPath | Out-Null

    if ($PSCmdlet.ShouldProcess($targetPath, "Copy overlay folder $sourcePath")) {
        Copy-Item -Path (Join-Path $sourcePath "*") -Destination $targetPath -Recurse -Force
    }
}

$resolvedSourceRoot = Resolve-OverlaySourceRoot -RawSourceRoot $SourceRoot
$resolvedCoreRoot = (Resolve-Path -LiteralPath $CoreRoot).Path

Assert-OverlaySource -ResolvedSourceRoot $resolvedSourceRoot

Copy-OverlayFolder -ResolvedSourceRoot $resolvedSourceRoot -ResolvedCoreRoot $resolvedCoreRoot -FolderName "cli"
Copy-OverlayFolder -ResolvedSourceRoot $resolvedSourceRoot -ResolvedCoreRoot $resolvedCoreRoot -FolderName "demos"

Write-Host "OpAMP demo overlay copied to: $resolvedCoreRoot"
Write-Host "Select the profile with:"
Write-Host "  opamp-cli cli-config change-config"
Write-Host "Profile path:"
Write-Host "  cli/config/demo_consumer_profiles.full_multi_agent.json"
