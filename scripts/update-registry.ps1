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

$entries = @([EntryRegistry]::new("Hidden","dword","HKU:\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",1),
             [EntryRegistry]::new("HideFileExt","dword","HKU:\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",0),
             [EntryRegistry]::new("ConsentPromptBehaviorAdmin","dword","HKU:\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Policies\System",0)
             [EntryRegistry]::new("DoNotOpenServerManagerAtLogon","dword","HKU:\DEFAULT\Software\Microsoft\ServerManager",1))

Write-Host "Attempting to mount default registry hive"

New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
REG LOAD HKU\DEFAULT C:\Users\Default\NTUSER.DAT
             
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

[gc]::collect()
reg unload HKU\DEFAULT
Remove-PSDrive -Name HKU