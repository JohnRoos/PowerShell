# IniManager
[![IniManager](https://img.shields.io/powershellgallery/v/IniManager.svg?style=flat&label=IniManager)](https://www.powershellgallery.com/packages/IniManager/) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IniManager?style=flat)](https://www.powershellgallery.com/packages/IniManager/)

This module contains 7 cmdlets for managing ini files.
* Get-Ini
* New-Ini
* Remove-IniKey
* Rename-IniKey
* Set-IniFromHash
* Set-IniKey
* Test-Ini

A more detailed description can be found in this blog post: http://blog.roostech.se/2016/04/introducing-inimanager-module.html

## Get-Ini
#### Description
Reads an ini file and creates an object based on the content of the file. One property per key/value. Sections will be named with surrounding brackets and will contain a list of objects based on the keys within that section.
Comments will be ignored.
#### Example
    Get-Ini -Path "C:\config.ini"
Opens the file config.ini and creates an object based on that file.
#### Outputs
Outputs an custom object of the type File.Ini

## Set-IniKey
#### Description
Sets a specific key to a value in a ini file.
Comments will be ignored.
Warning: Even comments in the target ini file will be removed!
#### Example
    Set-IniKey -Path "C:\config.ini" -Key LoggingLevel -Value Debug -Section Logging -Encoding UTF8
Opens the file config.ini and changes the key "LoggingLevel" in the [Logging] section of the file. The file will be saved with UTF8 encoding.
#### Outputs
Creates a ini file. Keeps the original content of the ini file and only replaces the value for the key matching the parameter Key

## Remove-IniKey    
#### Description
Removes a key (entire line) in ini file
Comments will be ignored.
Warning: Even comments in the target ini file will be removed!
#### Example
    Remove-IniKey -Path "c:\config.ini" -Key [system]Proxy -Encoding ASCII
Opens the file config.ini and removes the key "Proxy" in the [system] section of the file. The file will be saved with ASCII encoding.
#### Outputs
    Overwrites the original ini file
    
## Rename-IniKey
#### Description
Renames a key in ini file
Comments will be ignored.
Warning: Even comments in the target ini file will be removed!
#### Example
    Rename-IniKey -Path c:\config.ini -Key Prixy -NewKey Proxy -Section system -Encoding UTF8
Opens the file config.ini and renames the key "Prixy" to "Proxy" in the [system] section of the file. The file will be saved with UTF8 encoding.
#### Outputs
Overwrites the original ini file
    
## Set-IniFromHash
#### Description
Sets a number of keys and values in ini file based on a hash table. Sections are separated by naming them within brackets, like this: [section]key
The keys will be added if they do not exist.
Comments will be ignored.
Warning: Even comments in the target ini file will be removed!
#### Example
    Set-IniFromHash -Path c:\config.ini -Values @{'DebugLog'='false';'[settings]Hostname'='localhost'} -Encoding UTF8
Opens the file config.ini and sets the key DebugLog to false and in the [settings] section sets the Hostname to localhost.
#### Outputs
Overwrites the original ini file
    
## New-Ini
#### Description
Creates an ini file based on a custom object of the type File.Ini
Comments will be ignored.
#### Example
    get-ini -Path "C:\config.ini" | new-ini -Path c:\config_new.ini -Encoding UTF8
Opens the file config.ini and which creates a File.Ini object. The object is then piped to New-Ini which will create a new file based on that object.
#### Outputs
Creates a new ini file
    
## Test-Ini
#### Description
Reads the configuration from an ini file and compares the content with the provided hashtable.
Comments will be ignored.
#### Example
    Test-Ini -Path "C:\config.ini" -Values @{'DebugLog'='false';'[settings]Hostname'='localhost'} 
Opens the file config.ini and checks the values for 'DebugLog' (not in any section) and 'Hostname' (in section 'settubgs'). If the values are the same as the provided values the function will return True, otherwise it will return False.
#### Outputs
Boolean
