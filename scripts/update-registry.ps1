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

$entries = @([EntryRegistry]::new("Hidden","dword","HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",1),
             [EntryRegistry]::new("HideFileExt","dword","HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",0),
             [EntryRegistry]::new("ConsentPromptBehaviorAdmin","dword","HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System",0)
             [EntryRegistry]::new("DoNotOpenServerManagerAtLogon","dword","HKCU:\Software\Microsoft\ServerManager",1))

$entries | ForEach{
    If(!(Test-Path $_.path)){
        New-Item -Path $_.path -Force | Out-Null
        New-ItemProperty -Path $_.path -Name $_.name -Value $_.data -PropertyType $_.type -Force | Out-Null
    }
    Else {
        New-ItemProperty -Path $_.path -Name $_.name -Value $_.data -PropertyType $_.type -Force | Out-Null
    }
}


