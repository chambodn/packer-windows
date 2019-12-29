$ErrorActionPreference = "Stop"
#Requires -RunAsAdministrator

Set-ExecutionPolicy Bypass -Scope Process -Force

# install chocolatey if not installed
if (!(Test-Path -Path "$env:ProgramData\Chocolatey")) {
  Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$Packages = 'firefox', 'vcbuildtools', 'notepadplusplus', 'devcon.portable'

ForEach ($PackageName in $Packages){
    choco install $PackageName -y
}
