#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

param (
    [string] $NuPkgDir = "",
    [string] $NuGetExe = "",
    [string] $NuGetSrc = "",
    [string] $NuGetAuth = "",
    [string] $Configuration = "",
    [string] $Version = ""
)

$Microsoft_DotNet_ILCompiler = "Microsoft.DotNet.ILCompiler"
$Microsoft_DotNet_ILCompiler_SDK = $Microsoft_DotNet_ILCompiler + ".SDK"

$ListGrepStr = $Microsoft_DotNet_ILCompiler
$RootPackages = @(
    $Microsoft_DotNet_ILCompiler,
    $Microsoft_DotNet_ILCompiler_SDK
)

$Rids = @(
    "win7-x64",
    "ubuntu.14.04-x64",
    "osx.10.10-x64"
)

# Get the package name strings
$PackageGrepStr = @()
for ($i = 0; $i -lt $Rids.length; $i++) {
    for ($j=0; $j -lt $RootPackages.length; $j++) {
    	$PackageGrepStr += "toolchain." + $Rids[$i] + "." + $RootPackages[$j] + " " + $Version
    }
}

$MaxRetries = 5
$PushedPackages = $False
$TotalMatches = 0
$ExpectedMatches = $PackageGrepStr.length
for ($Retries = 0; $Retries -le $MaxRetries; $Retries++) {
    $NuGetOutput = Invoke-Expression "$NuGetExe list -Source $NuGetSrc $ListGrepStr -PreRelease"
    if ($LastExitCode -ne 0) {
        Write-Host "Error: nuget list $ListGrepStr"
        Throw
    }

    # Compare the name strings with nuget list output
    for ($i = 0; $i -lt $PackageGrepStr.length; $i++) {
        $count = ([regex]::Matches($NuGetOutput, $PackageGrepStr[$i])).count
        if ($count -eq 0) {
            Write-Host "Package not found in feed: " $PackageGrepStr[$i] -ForeGroundColor Red
        }
        $TotalMatches += $count;
    }

    If ($TotalMatches -eq $ExpectedMatches) {
        Push-Packages -PushPackages $RootPackages -NuPkgDir $NuPkgDir -Version $Version
        $PushedPackages = $True
        Write-Host "Packages $RootPackages.length pushed successfully!"
        Break
    } Else {
        # Wait 10 minutes
        Start-Sleep -s 600
    }    
}

If ($PushedPackages != $True) {
    Write-Host "Error: Not all platform packages were found in the feed (actual: $TotalMatches, expected: $ExpectedMatches). Will not push root packages." -BackgroundColor Red
    Throw
}


#------------------------------------------------------------------------
function Push-Packages {
    param(
        [string[]] $PushPackages = @()
        [string] $NuPkgDir = ""
        [string] $Version = ""
    )
    for ($j=0; $j -lt $PushPackages.length; $j++) {
        $command = "$NuGetExe push `"$NuPkgDir" + $PushPackages[$j] + ".$Version.nupkg`" $NuGetAuth -Source $NuGetSrc"
        Write-Host $command
        Invoke-Expression $command
        if ($LastExitCode -ne 0) {
            Write-Host "Error: nuget push" -ForeGroundColor Red
            Throw
        }
    }
}
