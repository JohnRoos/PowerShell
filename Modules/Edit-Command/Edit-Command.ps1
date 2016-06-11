function Edit-Command {
 
    [CmdletBinding()]
    [OutputType([void])]
   
    param (
        [validatenotnullorempty()]
        [string]$Name
    )

    Process
    {
        try {
            $command = Get-Command -Name $Name -ErrorAction Stop
        } catch {
            Throw $Error[0].Exception
        }

        if ( $command -is [array]) {
            throw 'Multiple commands found. You need to be more specific.'
        }

        if (-not ($scriptblock = $command.ScriptBlock) ) {
            $exception = "The command does not have a scriptblock available."
            Throw $exception
        }

        $code = New-Object -TypeName System.Text.StringBuilder

        $code.Append("# Command: $($command.Name)`n") | Out-Null
        $code.Append("# Type: $($command.CommandType)`n") | Out-Null
        $code.Append("# Version: $($command.Version)`n") | Out-Null
        $code.Append("# Source: $($command.Source)`n") | Out-Null
        $code.Append($scriptblock) | Out-Null

        OpenTab -code $code
        
    }
}

function OpenTab {
    param ( [System.Text.StringBuilder]$code )

    $displayname = $psISE.CurrentPowerShellTab.Files.Add().DisplayName
    $openfile = $psISE.PowerShellTabs.files | Where-Object DisplayName -eq $displayname | Select-Object -First 1 
        
    $openfile.Editor.Text += $code 
    $openfile.Editor.SetCaretPosition(1,1)

}
