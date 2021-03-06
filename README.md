A collection of useful PowerShell modules and scripts.
# Modules
The following modules are available in this repository.
### Write-ObjectToSQL 
[![Write-ObjectToSQL](https://img.shields.io/powershellgallery/v/Write-ObjectToSQL.svg?style=flat&label=Write-ObjectToSQL)](https://www.powershellgallery.com/packages/Write-ObjectToSQL/) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Write-ObjectToSQL?style=flat)](https://www.powershellgallery.com/packages/Write-ObjectToSQL/)

This cmdlet accepts any type of object and will insert it into a database table, one row per object coming down the pipeline. If the table does not exist it will be created based on the properties of the first object in the pipeline. You can send pretty much anything to this cmdlet which makes it very useful when you want to quickly save the output from a script to a database.
### IniManager
[![IniManager](https://img.shields.io/powershellgallery/v/IniManager.svg?style=flat&label=IniManager)](https://www.powershellgallery.com/packages/IniManager/) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IniManager?style=flat)](https://www.powershellgallery.com/packages/IniManager/)

This module contains 7 cmdlets for managing ini files.
### WeatherForecast
Contains a PowerShell class which is used for getting weather forecasts from SMHI (www.smhi.se).
### Edit-Command
This module contains a cmdlet which can be used to edit other cmdlets in PowerShell ISE.
### Get-IMDBmovie
This module contains a cmdlet for getting information about movies from IMDB.
### Get-ParamHelp
This module contains a few cmdlets to make it easier to get help about parameter validation when writing advanced functions in PowerShell.
# DSC Resources
The following DSC resource is available in this repository.
### cIniFile
This resource can be used for managing ini files with DSC. It uses the IniManager module and includes examples for both regular DSC configurations and composite resources.
