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

function UpdateRegistry ([EntryRegistry] $RegistryItem) {  
    If(!(Test-Path $RegistryItem.path)){
        New-Item -Path $RegistryItem.path -Force
        New-ItemProperty -Path $RegistryItem.path -Name $RegistryItem.name -Value $RegistryItem.data -PropertyType $RegistryItem.type -Force
    }
    Else {
        New-ItemProperty -Path $RegistryItem.path -Name $RegistryItem.name -Value $RegistryItem.data -PropertyType $RegistryItem.type -Force
    }
}

$localMachineEntries = @([EntryRegistry]::new("ConsentPromptBehaviorAdmin","dword","HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System",0))
$localMachineEntries | ForEach{
    UpdateRegistry -RegistryItem $_
}

# Regex pattern for SIDs
$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
 
# Get Username, SID, and location of ntuser.dat for all users
$ProfileList = gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID} | 
    Select  @{name="SID";expression={$_.PSChildName}}, 
            @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, 
            @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}
 
# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
$LoadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}
 
# Get all users that are not currently logged
$UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select @{name="SID";expression={$_.InputObject}}, UserHive, Username

if (Get-PSDrive HKU -ErrorAction SilentlyContinue) {
	Write-Host 'The HKU: drive is already in use.'
} else {
	New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
}

# Loop through each profile on the machine
Foreach ($item in $ProfileList) {
    # Load User ntuser.dat if it's not already loaded
    IF ($item.SID -in $UnloadedHives.SID) {
        reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
    }
    
    $userEntries = @([EntryRegistry]::new("Hidden","dword","HKU:\$($Item.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",1),
             [EntryRegistry]::new("HideFileExt","dword","HKU:\$($Item.SID)\Microsoft\Windows\CurrentVersion\Explorer\Advanced",0),
             [EntryRegistry]::new("DoNotOpenServerManagerAtLogon","dword","HKU:\$($Item.SID)\Microsoft\ServerManager",1))
    
    $userEntries | ForEach{
        UpdateRegistry -RegistryItem $_
    }
             
    # Unload ntuser.dat        
    IF ($item.SID -in $UnloadedHives.SID) {
        ### Garbage collection and closing of ntuser.dat ###
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
    }
} 
 
