$url = "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe"
$outputFile = "VisualCppRedist_AIO_x86_x64.exe"

Invoke-WebRequest -Uri $url -OutFile $outputFile

Start-Process -FilePath $outputFile -ArgumentList "/ai" -Wait