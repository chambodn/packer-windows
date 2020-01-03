$ErrorActionPreference = "Stop"
#Requires -RunAsAdministrator

class EntryRegistry {
    [string]$name
    [string]$type
    [string]$path
    [int]$data;

    EntryRegistry(
        [string]$name,
        [string]$type,
        [string]$path,
        [int]$data
    ){
        $this.name = $name
        $this.type = $type
        $this.path = $path
        $this.data = $data
    }
}

$entries = @([EntryRegistry]::new("Hidden","dword","HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",1),
             [EntryRegistry]::new("HideFileExt","dword","HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",0),
             [EntryRegistry]::new("ConsentPromptBehaviorAdmin","dword","HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System",0)
             [EntryRegistry]::new("DoNotOpenServerManagerAtLogon","dword","HKLM:\Software\Microsoft\ServerManager",1))

Write-Host "Attempting to mount default registry hive"

& REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT
Push-Location 'HKLM:\DEFAULT\Software\Microsoft\Internet Explorer'
             
try{
    $entries | ForEach{
        If(!(Test-Path $_.path)){
            New-Item -Path $_.path -Force
            New-ItemProperty -Path $_.path -Name $_.name -Value $_.data -PropertyType $_.type -Force
        }
        Else {
            New-ItemProperty -Path $_.path -Name $_.name -Value $_.data -PropertyType $_.type -Force
        }
    }
    Write-Host "Registry successfully updated"
}
catch {
    Write-Host "An error occurred:"
    Write-Host $_    
}
