<#
.Synopsis
   Checks for one or more patches on one or more servers.
.DESCRIPTION
   Checks for one or more patches on one or more servers. The results show if each patch is installed or not on each server.
   The script uses the cmdlet Get-Hotfix so make sure you can run that towards the servers. 
   Get-Hotfix does not return anything if no patch is found. This script works around that to show where the patches are not installed as well as where they are installed.
   
   Created by John Roos 
   Email: john@roostech.se
   Web: http://blog.roostech.se
.EXAMPLE
   .\Find-Hotfix.ps1 -Hotfix_FilePath 'c:\hotfixes.txt' -ComputerName_FilePath 'c:\servers.txt'
.EXAMPLE
   .\Find-Hotfix.ps1 -Hotfix 'KB2991963', 'KB2923423' -ComputerName 'server01', 'server02'
.EXAMPLE
   .\Find-Hotfix.ps1 -Hotfix 'KB2991963', 'KB2923423' -ComputerName_FilePath 'c:\servers.txt'
.EXAMPLE
   .\Find-Hotfix.ps1 -Hotfix_FilePath 'c:\hotfixes.txt' -ComputerName 'server01', 'server02'
#>
Param
(
    # Specify a path to the text file containing the list of hotfixes to search for. Must be one patch per row.
    [string]
    $Hotfix_FilePath,
    [string[]]
    # Specify the id of the patch to check (Example: KB2991963)
    $Hotfix,
    # Specify a path to the text file containing the list of servers to check. Must be one server per row.
    [string]
    $ComputerName_FilePath,
    # Specify the name of the server to check
    [string[]]
    $ComputerName
)

if ($HotfixList_Path) {
    $find_hotfix = Get-Content -Path $Hotfix_FilePath
}else{
    $find_hotfix = $Hotfix
    
}

if ($ComputerList_Path){
    $servers = Get-Content -Path $ComputerName_FilePath
}else{
    $servers = $ComputerName
}

# Could get error on this line in case some servers does not respond or bad permissions.
$installedhf = Get-HotFix -Id $find_hotfix -ComputerName $servers

foreach ($server in $servers){
    $temphf = $installedhf | where PSComputerName -eq $server
    
    foreach ($hf in $find_hotfix){
        $verified_hotfix  = New-Object psobject
        Add-Member -InputObject $verified_hotfix -MemberType 'NoteProperty' -Name "ComputerName" -Value $server
        Add-Member -InputObject $verified_hotfix -MemberType 'NoteProperty' -Name "Hotfix" -Value $hf
        
        if ($temphf.HotFixID.Contains($hf)){
            Add-Member -InputObject $verified_hotfix -MemberType 'NoteProperty' -Name "Status" -Value 'Installed'
        }else{
            Add-Member -InputObject $verified_hotfix -MemberType 'NoteProperty' -Name "Status" -Value 'Not installed'
        }

        # send object to pipeline
        $verified_hotfix
    }
}