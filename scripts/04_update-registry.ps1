$registryPath = "HKCU:\Software\ScriptingGuys\Scripts"
$Name = "Version"
$value = "1"

If(!(Test-Path $registryPath)){
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}
Else {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}

