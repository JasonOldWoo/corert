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
$Microsoft_DotNet_ILCompiler_SDK_Debug = $Microsoft_DotNet_ILCompiler_SDK + ".Debug"

$ListGrepStr = 
$RootPackages = @(
    $Microsoft_DotNet_ILCompiler,
    $Microsoft_DotNet_ILCompiler_SDK,
    $Microsoft_DotNet_ILCompiler_SDK_Debug
)

$NuGetOutput = Invoke-Expression "$NuGetExe list -Source $NuGetSrc $ListGrepStr -PreRelease"
if ($LastExitCode -ne 0) {
    Write-Host "Error: nuget list $ListGrepStr"
    Throw
}

$Rids = @(
    "win7-x64",
    "ubuntu.14.04-x64",
    "osx.10.10-x64"
)

$PackageGrepStr = @()
for ($i = 0; $i -lt $Rids.length; $i++) {
    for ($j=0; $j -lt $RootPackages.length; $j++) {
    	$PackageGrepStr += "toolchain." + $Rids[$i] + "." + $RootPackages[$j] + " " + $Version
    }
}

$TotalMatches = 0
for ($i = 0; $i -lt $PackageGrepStr.length; $i++) {
    $count = ([regex]::Matches($NuGetOutput, $PackageGrepStr[$i])).count
    if ($count -eq 0) {
        Write-Host "Package not found in feed: " $PackageGrepStr[$i] -ForeGroundColor Red
    }
    $TotalMatches += $count;
}

$ExpectedMatches = $PackageGrepStr.length

If ($TotalMatches -eq $ExpectedMatches) {
    $PushPackages = @($Microsoft_DotNet_ILCompiler)
    If ($Configuration -eq "Debug") {
        $PushPackages += $Microsoft_DotNet_ILCompiler_SDK_Debug
    } Else {
        $PushPackages += $Microsoft_DotNet_ILCompiler_SDK
    }

    for ($j=0; $j -lt $PushPackages.length; $j++) {
        $command = "$NuGetExe push `"$NuPkgDir" + $PushPackages[$j] + ".$Version.nupkg`" $NuGetAuth -Source $NuGetSrc"
        Write-Host $command
        Invoke-Expression $command
        if ($LastExitCode -ne 0) {
            Write-Host "Error: nuget push" -ForeGroundColor Red
            Throw
        }
    }
} Else {
    Write-Host "Error: Not all platform packages were found in the feed (actual: $TotalMatches, expected: $ExpectedMatches). Will not push root packages." -BackgroundColor Red
    Throw
}
