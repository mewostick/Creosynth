$directories = @(
    "C:\Users\$env:USERNAME\AppData\Local\Microsoft\EdgeCore",
    "C:\Users\$env:USERNAME\AppData\Local\Microsoft\EdgeUpdate",
    "C:\Users\$env:USERNAME\AppData\Local\Microsoft\EdgeWebView"
)

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        try {
            Remove-Item -Path $dir -Recurse -Force
            Write-Host "Successfully deleted: $dir"
        } catch {
            Write-Host "Failed to delete: $dir. Error: $_"
        }
    } else {
        Write-Host "Directory does not exist: $dir"
    }
}