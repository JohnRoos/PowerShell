Configuration MyIniFile
{
    Import-DscResource -ModuleName cIniFileResources
 
    cIniFile2 MyFile
    {
        Path        = 'c:\temp\inifile.ini'
        EnableDebug = 'true'
        LogPath     = 'C:\logfile.log'
    }
}

# MyIniFile -OutputPath c:\temp\MyIniFile\
# Start-DscConfiguration -Path C:\temp\MyIniFile\ -Wait -Verbose -Force