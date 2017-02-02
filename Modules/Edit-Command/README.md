# Edit-Command
This module contains a cmdlet which can be used to edit other cmdlets in PowerShell ISE.

Did you know that you can see the actual source of hundreds of built in cmdlets?
## Example
On my system I currently have 1855 cmdlets:
```
PS C:\> (get-command).count
1855
```
948 of those are written in PowerShell and can be edited.
```
PS C:\> (get-command | Where-Object ScriptBlock).count
948
```
Lets try one.
```
PS C:\> Edit-Command -Name Get-Verb
```
Okay, so its a bit hard to show that this actually opens a new tab in the ISE with the code of Get-Verb, but here is the code it shows:
```
# Command: Get-Verb
# Type: Function
# Version: 
# Source: 

param(
    [Parameter(ValueFromPipeline=$true)]
    [string[]]
    $verb = '*'
)
begin {
    $allVerbs = [System.Reflection.IntrospectionExtensions]::GetTypeInfo([PSObject]).Assembly.ExportedTypes |
        Microsoft.PowerShell.Core\Where-Object {$_.Name -match '^Verbs.'} |
        Microsoft.PowerShell.Utility\Get-Member -type Properties -static |
        Microsoft.PowerShell.Utility\Select-Object @{
            Name='Verb'
            Expression = {$_.Name}
        }, @{
            Name='Group'
            Expression = {
                $str = "$($_.TypeName)"
                $str.Substring($str.LastIndexOf('Verbs') + 5)
            }
        }
}
process {
    foreach ($v in $verb) {
        $allVerbs | Microsoft.PowerShell.Core\Where-Object { $_.Verb -like $v }
    }
}
# .Link
# http://go.microsoft.com/fwlink/?LinkID=160712
# .ExternalHelp System.Management.Automation.dll-help.xml
```
Pretty cool.
