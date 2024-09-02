REM Code taken from https://github.com/Jettcodey/Win11-Explorer-Fix
:: Search and delete the specified registry keys
for %%i in ({F874310E-B6B7-47DC-BC84-B9E6B38F5903} {E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}) do (
    for /f "tokens=*" %%a in ('reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop /s /f %%i 2^>nul') do (
        echo Found key: %%a
        reg delete "%%a" /f > nul 2> nul
        echo Registry key %%i deleted.
    )
)