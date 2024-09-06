$url = "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe"
$outputFile = "ep_setup.exe"

Invoke-WebRequest -Uri $url -OutFile $outputFile

Start-Process -FilePath $outputFile -Wait