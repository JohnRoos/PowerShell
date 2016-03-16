configuration MyIniConfig
{
    Import-DscResource -ModuleName cIniFile
    cIniFile MyFile
    {
        Ensure = 'Present'
        Path   = 'c:\temp\file.ini'
        Config = @{
            '[Config]Debug'   = 'true'
            '[Config]Logpath' = 'c:\temp\log.txt'
        }
    }       
}

# MyIniConfig -OutputPath c:\temp\MyIniConfig\
# Start-DscConfiguration -Path C:\temp\MyIniConfig -Wait -Verbose -Force