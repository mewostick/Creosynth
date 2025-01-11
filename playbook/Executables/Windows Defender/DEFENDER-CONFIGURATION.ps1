param (
    [string[]]$MyArgument
)

# Function to set registry values
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Type,
        [string]$Value
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -Force
}

# Function to remove registry values
function Remove-RegistryValue {
    param (
        [string]$Path,
        [string]$Name
    )
    if (Test-Path $Path) {
        Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue
    }
}

# Manage antivirus settings
function Set-AntivirusSettings {
    param (
        [switch]$EnableAV,
        [switch]$DisableAV 
    )

    if ($EnableAV) {
        Write-Host "Enabling antivirus settings..."
        # Import general .reg file to enable Windows Defender
        Write-Host "Enabling Windows Defender globally"
        reg import "$env:WinDir\RapidScripts\UtilityScripts\Windows Defender\Enable-Defender.reg"

        # Enable Early Launch Anti-Malware
        bcdedit /set disableelamdrivers No

        # Enable Windows Defender UI Elements
        Write-Host "Enabling 'Device security' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security' -Name 'UILockdown' -Type DWord -Value 0
        
        Write-Host "Enabling 'Clear TPM' button"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security' -Name 'DisableClearTpmButton' -Type DWord -Value 0
        
        Write-Host "Enabling 'Secure boot' button"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security' -Name 'HideSecureBoot' -Type DWord -Value 0
        
        Write-Host "Enabling 'Security processor (TPM) troubleshooter' page"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security' -Name 'HideTPMTroubleshooting' -Type DWord -Value 0
        
        Write-Host "Enabling 'TPM Firmware Update' recommendation"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security' -Name 'DisableTpmFirmwareUpdateWarning' -Type DWord -Value 0

        Write-Host "Enabling 'Virus and threat protection' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection' -Name 'UILockdown' -Type DWord -Value 0
        
        Write-Host "Enabling 'Ransomware data recovery' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection' -Name 'HideRansomwareRecovery' -Type DWord -Value 0
        
        Write-Host "Enabling 'Family options' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Family options' -Name 'UILockdown' -Type DWord -Value 0
        
        Write-Host "Enabling 'Device performance and health' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health' -Name 'UILockdown' -Type DWord -Value 0
        
        Write-Host "Enabling 'Account protection' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Account protection' -Name 'UILockdown' -Type DWord -Value 0
        
        Write-Host "Enabling 'App and browser control' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection' -Name 'UILockdown' -Type DWord -Value 0

        # Enable all Windows Defender notifications
        Write-Host "Enabling general Defender notifications"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableNotifications' -Type DWord -Value 0
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableNotifications' -Type DWord -Value 0
        Set-RegistryValue -Path 'HKCU:\Software\Policies\Microsoft\Windows Defender\UX Configuration' -Name 'Notification_Suppress' -Type DWord -Value 0
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows Defender\UX Configuration' -Name 'Notification_Suppress' -Type DWord -Value 0
        
        Write-Host "Enabling non-critical Defender notifications"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableEnhancedNotifications' -Type DWord -Value 0
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableEnhancedNotifications' -Type DWord -Value 0
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting' -Name 'DisableEnhancedNotifications' -Type DWord -Value 0
        
        Write-Host "Enabling notifications from Windows Action Center for security and maintenance"
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance' -Name 'Enabled' -Type DWord -Value 1
        
        Write-Host "Enabling Defender reboot notifications"
        Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows Defender\UX Configuration' -Name 'SuppressRebootNotification' -Type DWord -Value 0

        # Restore context menu and tray icon
        Write-Host "Restoring Windows Defender context menu"
        reg add "HKEY_CLASSES_ROOT\Drive\shellex\ContextMenuHandlers\EPP" /v "(default)" /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f >$null 2>&1

        Write-Host "Unhiding 'Windows Security' system tray icon"
        Remove-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray' -Name 'HideSystray'

        Write-Host "Restoring 'Windows Security' taskbar icon"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'SecurityHealth' -Type 'ExpandString' -Value '%WinDir%\System32\SecurityHealthSystray.exe'

        # Get and enable all scheduled tasks related to Windows Defender
        $defenderTasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*Defender*" -or $_.TaskPath -like "*Defender*" }
        if ($defenderTasks) {
            foreach ($task in $defenderTasks) {
                Enable-ScheduledTask -TaskPath $task.TaskPath -TaskName $task.TaskName
                Write-Host "Enabled task: $($task.TaskPath)$($task.TaskName)" -ForegroundColor Green
            }
        } else {
            Write-Host "No Windows Defender related tasks found to enable." -ForegroundColor Yellow
        }

        Write-Host "All specified settings were applied."
    }

    if ($DisableAV) {
        Write-Host "Disabling antivirus settings..."
        # Import general .reg file to disable Windows Defender
        Write-Host "Disabling Windows Defender globally"
        reg import "$env:WinDir\RapidScripts\UtilityScripts\Windows Defender\Disable-Defender.reg"
        
        # Disable Early Launch Anti-Malware
        bcdedit /set disableelamdrivers Yes

        # Disable Windows Defender UI Elements
        Write-Host "Disabling 'Security processor (TPM) troubleshooter' page"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security' -Name 'HideTPMTroubleshooting' -Type DWord -Value 1
            
        Write-Host "Disabling 'TPM Firmware Update' recommendation"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security' -Name 'DisableTpmFirmwareUpdateWarning' -Type DWord -Value 1
            
        Write-Host "Disabling 'Virus and threat protection' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection' -Name 'UILockdown' -Type DWord -Value 1
            
        Write-Host "Disabling 'Ransomware data recovery' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection' -Name 'HideRansomwareRecovery' -Type DWord -Value 1
            
        Write-Host "Disabling 'Family options' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Family options' -Name 'UILockdown' -Type DWord -Value 1
            
        Write-Host "Disabling 'Device performance and health' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health' -Name 'UILockdown' -Type DWord -Value 1
            
        Write-Host "Disabling 'Account protection' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Account protection' -Name 'UILockdown' -Type DWord -Value 1
            
        Write-Host "Disabling 'App and browser control' section"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection' -Name 'UILockdown' -Type DWord -Value 1

        # Disable all Windows Defender notifications
        Write-Host "Disabling general Defender notifications"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableNotifications' -Type DWord -Value 1
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableNotifications' -Type DWord -Value 1
        Set-RegistryValue -Path 'HKCU:\Software\Policies\Microsoft\Windows Defender\UX Configuration' -Name 'Notification_Suppress' -Type DWord -Value 1
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows Defender\UX Configuration' -Name 'Notification_Suppress' -Type DWord -Value 1

        Write-Host "Disabling non-critical Defender notifications"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableEnhancedNotifications' -Type DWord -Value 1
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableEnhancedNotifications' -Type DWord -Value 1
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting' -Name 'DisableEnhancedNotifications' -Type DWord -Value 1

        Write-Host "Disabling notifications from Windows Action Center for security and maintenance"
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance' -Name 'Enabled' -Type DWord -Value 0
            
        Write-Host "Disabling Defender reboot notifications"
        Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows Defender\UX Configuration' -Name 'SuppressRebootNotification' -Type DWord -Value 1

        # Remove context menu and hide tray icon
        Write-Host "Removing Windows Defender context menu"
        reg delete "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /f >$null 2>&1

        Write-Host "Hiding 'Windows Security' system tray icon"
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\ Microsoft\Windows Defender Security Center\Systray' -Name 'HideSystray' -Type DWord -Value 1

        Write-Host "Removing Windows Security icon from taskbar"
        Remove-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'SecurityHealth'

        # Get and disable all scheduled tasks related to Windows Defender
        $defenderTasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*Defender*" -or $_.TaskPath -like "*Defender*" }
        if ($defenderTasks) {
            foreach ($task in $defenderTasks) {
                Disable-ScheduledTask -TaskPath $task.TaskPath -TaskName $task.TaskName
                Write-Host "Disabled task: $($task.TaskPath)$($task.TaskName)" -ForegroundColor Red
            }
        } else {
            Write-Host "No Windows Defender related tasks found to disable." -ForegroundColor Yellow
        }

        Write-Host "All specified settings were applied."
    }
}

# Manage SmartScreen settings
function Enable-SmartScreen {
    Write-Host "Enabling SmartScreen globally"
    Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SmartScreenEnabled' -Type String -Value On
    Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableSmartScreen' -Type DWord -Value 1
    Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen' -Name 'ConfigureAppInstallControlEnable' -Type DWord -Value 1

    Write-Host "All specified settings were applied."
}

function Disable-SmartScreen {
    Write-Host "Disabling SmartScreen globally"
    Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SmartScreenEnabled' -Type String -Value Off
    Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableSmartScreen' -Type DWord -Value 0
    Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen' -Name 'ConfigureAppInstallControlEnable' -Type DWord -Value 0

    Write-Host "All specified settings were applied."
}

# Function to display usage information
function Show-Usage {
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "---------" -ForegroundColor Cyan
    Write-Host " .\Defender-Configuration.ps1 -MyArgument <option>" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "---------" -ForegroundColor Cyan
    Write-Host " - enable_av           : Enable Windows Defender" -ForegroundColor Gray
    Write-Host " - disable_av          : Disable Windows Defender" -ForegroundColor Gray
    Write-Host " - enable_smartscreen  : Enable SmartScreen" -ForegroundColor Gray
    Write-Host " - disable_smartscreen : Disable SmartScreen" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Example:" -ForegroundColor Cyan
    Write-Host "---------" -ForegroundColor Cyan
    Write-Host " .\Defender-Configuration.ps1 -MyArgument enable_av" -ForegroundColor White
    Write-Host " .\Defender-Configuration.ps1 -MyArgument disable_av, disable_smartscreen" -ForegroundColor White
    Write-Host ""
}

# Check if no arguments were provided
if (-not $MyArgument) {
    Write-Host "Error: No arguments provided." -ForegroundColor Red
    Write-Host ""
    Show-Usage
}

# Function call based on the argument
foreach ($arg in $MyArgument) {
    switch ($arg) {
        # Defender Switcher
        "enable_av" { Set-AntivirusSettings -EnableAV $true }
        "disable_av" { Set-AntivirusSettings -DisableAV $true }

        # SmartScreen Switcher
        "enable_smartscreen" { Enable-SmartScreen }
        "disable_smartscreen" { Disable-SmartScreen }

        default {
            Write-Host "Error: Invalid argument `"$arg`"" -ForegroundColor Red
            Write-Host ""
            Show-Usage
        }
    }
}