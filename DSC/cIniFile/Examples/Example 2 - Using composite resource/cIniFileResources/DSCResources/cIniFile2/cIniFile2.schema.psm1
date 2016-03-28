Configuration cIniFile2
{
    param
    (
        # Path to ini file
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        # Debug mode (true or false)
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("true", "false")]
        [String] $EnableDebug,

        # Logfile path
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $LogPath
    )

    Import-DscResource -ModuleName cIniFile
    cIniFile MyFile
    {
        Path   = $Path
        Config = @{
            '[Config]Debug'   = $EnableDebug
            '[Config]Logpath' = $LogPath
        }
    }
}