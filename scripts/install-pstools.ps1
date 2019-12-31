$ErrorActionPreference = "Stop"
Set-ExecutionPolicy Bypass -Scope Process -Force

Write-Output \"Download and install pstools...\"
Invoke-WebRequest -Uri https://download.sysinternals.com/files/PSTools.zip -OutFile $env:TEMP\\pstools.zip
Microsoft.PowerShell.Archive\\Expand-Archive -Path $Env:TEMP\\pstools.zip -DestinationPath $env:TEMP\\pstools
Move-Item -Path $env:TEMP\\pstools\\psexec.exe C:\\WINDOWS\\system32\\psexec.exe
Remove-Item -Path $env:TEMP\\pstools -Recurse