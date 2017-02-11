A collection of useful PowerShell modules and scripts.
# Modules
The following modules are available in this repository.
### Write-ObjectToSQL
This Powershell cmdlet inserts properties of an object into a table. The table will be created if it doesnt exist. The cmdlet accepts object from the pipeline which makes this very useful when you want to easily save the output from a script in a database.
### IniManager
This module contains 7 cmdlets for managing ini files.
### WeatherForecast
Contains a PowerShell class which is used for getting weather forecasts from SMHI (www.smhi.se).
### Edit-Command
This module contains a cmdlet which can be used to edit other cmdlets in PowerShell ISE.
### Get-IMDBmovie
This module contains a cmdlet for getting information about movies from IMDB.
# DSC Resources
The following DSC resource is available in this repository.
### cIniFile
This resource can be used for managing ini files with DSC. It uses the IniManager module and includes examples for both regular DSC configurations and composite resources.
