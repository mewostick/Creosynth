# Changes
A shortened version of what does the playbook do:
- Installs all VCRuntimes
- Has an ability to remove Microsoft Edge & OneDrive
- Can disable Defender & SmartScreen
- Debloats the OS (optionally with APPX apps)
- Sets some services to "Manual" for decreased background load (list taken from Chris Titus' Windows Util)
- Configures Windows Update to never auto-update & not install drivers from the internet
- Privacy tweaks (taken entirely from AtlasOS)
- QoL changes such as hidden files & file extensions
- Optimises Windows & the power plan for latency + on Windows 11 it also installs [ZwTimerResolution](https://github.com/LuSlower/ZwTimerResolution) for faster Sleep(1)
- Optionally installs Chocolatey

To view every change that is being made by the playbook, take a look at the [Configuration directory](https://github.com/mewostick/Creosynth/tree/main/playbook/Configuration).
