$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$destinationDirectory = "$env:LOCALAPPDATA\ZwTimerResolution"
$sourceFile = Join-Path -Path $scriptDirectory -ChildPath "zwt.exe"
$licenseFile = Join-Path -Path $scriptDirectory -ChildPath "LICENSE"

if (-not (Test-Path $destinationDirectory)) {
    New-Item -ItemType Directory -Path $destinationDirectory
}

if (Test-Path $sourceFile) {
    Copy-Item -Path $sourceFile -Destination $destinationDirectory
    Write-Host "Successfully copied zwt.exe to $destinationDirectory"

    if (Test-Path $licenseFile) {
        Copy-Item -Path $licenseFile -Destination $destinationDirectory
        Write-Host "Successfully copied LICENSE to $destinationDirectory"
    } else {
        Write-Host "Warning: LICENSE file not found in $scriptDirectory"
    }

    $zwtPath = Join-Path -Path $destinationDirectory -ChildPath "zwt.exe"
    $taskName = "RunZwt"
    $action = New-ScheduledTaskAction -Execute $zwtPath -Argument "5000"
    $trigger = New-ScheduledTaskTrigger -AtLogOn

    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Runs zwt.exe with argument 5000 at logon" -User $env:USERNAME -RunLevel Highest

    Write-Host "Scheduled task '$taskName' created successfully."
} else {
    Write-Host "Error: zwt.exe not found in $scriptDirectory"
}
