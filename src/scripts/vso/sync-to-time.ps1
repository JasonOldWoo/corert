#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

param (
    [string] $Time = "18:00:00"
)

$PstZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Pacific Standard Time")
$PstTime = [System.TimeZoneInfo]::ConvertTimeFromUtc(Get-Date($Time).ToUniversalTime(), $PstZone)

$Format = $PstTime.ToString("ddd MMM dd HH:mm:ss yyyy") + $PstTime.ToString("zzz").Replace(":", "")
$CommitHash = Invoke-Expression "git rev-list -n 1 --before=`"$Format`" master"
Write-Host "git checkout $CommitHash"
