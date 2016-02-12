#REQUIRES -Version 4.0

<#
.Synopsis
    Sets a specific key to a value in a ini file   
.DESCRIPTION
    Sets a specific key to a value in a ini file
    Comments will be ignored.
    Warning: Even comments in the target ini file will be removed!

   Created by John Roos 
   Email: john@roostech.se
   Web: http://blog.roostech.se
.EXAMPLE
   Set-IniKey -Path "C:\config.ini" -Key LoggingLevel -Value Debug -Section Logging -Encoding UTF8

   Opens the file config.ini and changes the key "LoggingLevel" in the [Logging] section of the file. The file will be saved with UTF8 encoding.
.OUTPUTS
   Creates a ini file. Keeps the original content of the ini file and only replaces the value for the key matching the parameter Key
#>
function Set-IniKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [String]$Key,

        [Parameter(Mandatory=$true,
                   Position=2)]
        [String]$Value,

        [Parameter(Mandatory=$false,
                   Position=3)]
        [String]$Section,

        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$false,
                   Position=4)]
        [ValidateSet("Unicode", "UTF7", "UTF8", "UTF32", "ASCII", "BigEndianUnicode", "Default", "OEM")]
        [psobject]$Encoding = "UTF8",

        [Parameter(Mandatory=$False,
                   ValueFromPipeline=$False,
                   Position=5)]
        [switch]$Force
        )

    Process {
        if ($Section){
            $Section = $Section.Replace('[','').Replace(']','')
            $Section = "[$Section]"
        }

        Write-Verbose "Checking if path exists"
        if (Test-Path $Path){
            Write-Verbose "Path exists"
            Write-Verbose "Reading ini file with Get-Ini"
            $ini = Get-Ini -Path $Path
            Write-Verbose "Get-Ini completed"
        } else {
            Write-Error 'Path does not exist'
            break
        }

        if ($Section){
            [array]$availableSections = ($ini | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {$_.Contains(']')}).tolower()
            Write-Verbose "Checking if the section $Section already exist"
            if (!$availableSections.Contains($Section.tolower())) {
                Write-Verbose "Section does not exist"
                Write-Host 'Creating new section'
                $props = [hashtable]@{$Key = $Value}
                $newValue = New-Object PSObject -Property $props
                Add-Member -InputObject $ini -MemberType NoteProperty -Name $Section -Value $newValue
            } else {
                Write-Verbose "Section exist"
                [array]$availableProperties = ($ini.$Section | Get-Member -MemberType Properties | Where-Object { $_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty' } | Select-Object -ExpandProperty Name).ToLower()
                if (!$availableProperties.Contains($Key.ToLower())) {
                    Write-Verbose "Property $Property exist"
                    Write-Verbose "Setting property value to $Value"
                    $ini.$Section | Add-Member -MemberType NoteProperty -Name $Key -Value $Value
                } else {
                    Write-Verbose 'Adding property'
                    $ini.$Section.$Key = $Value
                }
            }
        } else {
            [array]$availableProps = ($ini | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {!$_.Contains(']')}).ToLower()
            if (!$availableProps.Contains($Key.ToLower())) {
                Write-Verbose "Property $Key does not exist"
                Write-Verbose "Creating new property $Key"
                Add-Member -InputObject $ini -MemberType NoteProperty -Name $Key -Value $Value
            } else {
                Write-Verbose "Property $Key exist"
                Write-Verbose "Setting property value to $Value"
                $ini.$Key = $Value
            }
        }

        Write-Verbose 'Creating ini file with New-Ini'
        New-Ini -Path $Path -Content $ini -Encoding $Encoding -Force:$Force
    }
}

<#
.Synopsis
    Removes a key (entire line) in ini file
.DESCRIPTION
    Removes a key (entire line) in ini file
    Comments will be ignored.
    Warning: Even comments in the target ini file will be removed!
.EXAMPLE
   Remove-IniKey -Path "c:\config.ini" -Key [system]Proxy -Encoding ASCII

   Opens the file config.ini and removes the key "Proxy" in the [system] section of the file. The file will be saved with ASCII encoding.
.OUTPUTS
   Overwrites the original ini file
#>
function Remove-IniKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$Key,

        [Parameter(Mandatory=$false,
                   Position=2)]
        [string]$Section,

        [Parameter(Mandatory=$false,
                   Position=3)]
        [ValidateSet("Unicode", "UTF7", "UTF8", "UTF32", "ASCII", "BigEndianUnicode", "Default", "OEM")]
        [string]$Encoding = "UTF8",

        [Parameter(Mandatory=$False,
                   Position=4)]
        [switch]$Force
    )

    Process {
        
        Write-Verbose "Checking path to ini file"
        if (Test-Path $Path) {
            Write-Verbose "Ini file found"
            Write-Verbose "Reading ini file with Get-Ini"
            $ini = Get-Ini -Path $Path -Verbose:$false
            Write-Verbose "Get-Ini completed"
        } else {
            Write-Error 'Cannot find ini file'
            break
        }

        if ($Section) {
            $Section = $Section.Replace('[','').Replace(']','')
            $inisection = "[$Section]"
            Write-Verbose "Key belongs to section $inisection"
        } else {
            $inisection = $null
            Write-Verbose 'Key does not belong to any section'
        }
        
        $iniproperty = $Key

        # check if the value contains a [section]
        <#
        if ($Value -like '*]*') {
            $tempvalue = $Key.Trim().Split(']')
            $inisection = "$($tempvalue[0].Trim())]"
            $iniproperty = "$($tempvalue[1].Trim())"
            Write-Verbose "Section: $inisection"
            Write-Verbose "Property: $iniproperty"
        } else {
            $inisection = ""
            $iniproperty = $Key
            Write-Verbose "No section selected"
            Write-Verbose "Property: $iniproperty"
        }
        #>
        Write-Verbose 'Key check completed'
        Write-Verbose 'Searching for matching keys in ini file'

        if ($inisection) {
            # if section was included in the Value parameter
            [array]$availableSections = ($ini | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {$_.Contains(']')}).tolower()
            if ($availableSections.Contains($inisection.ToLower())) {
                # Section exists in the ini file
                Write-Verbose "Section $inisection exists"
                [array]$availableProps = ($ini.$inisection | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name |  Where-Object {!$_.Contains(']')}).ToLower()
                if ($availableProps.Contains($iniproperty.ToLower())) {
                    # Property exists in the correct section in the ini file
                    Write-Verbose "Property $iniproperty exists"
                    $ini.$inisection.PSObject.Properties.Remove($iniproperty)
                    Write-Verbose 'Key removed from ini object'
                } else {
                    Write-Error "ini file contains the section but does not contain requested key: $iniproperty" 
                    break
                }
            } else {
                Write-Error "ini file does not contain requested section: $inisection"
                break
            }
            
        } else {
            # if no section was included in the Value parameter
            if ($ini.psobject.properties.name.Contains($Key)) {
                $ini.PSObject.Properties.Remove($Key)
                Write-Verbose 'Key removed from ini object'
            } else {
                Write-Error 'Key does not exist in ini file'
                break
            }
            
        }
        
        #$ini
        # Recreate the ini file
        Write-Verbose 'Saving file'
        New-Ini -Path $Path -Content $ini -Encoding $Encoding -Force:$Force -Verbose:$false
    }
}


<#
.Synopsis
    Renames a key in ini file
.DESCRIPTION
    Renames a key in ini file
    Comments will be ignored.
    Warning: Even comments in the target ini file will be removed!
.EXAMPLE
   Rename-IniKey -Path c:\config.ini -Key Prixy -NewKey Proxy -Section system -Encoding UTF8

   Opens the file config.ini and renames the key "Prixy" to "Proxy" in the [system] section of the file. The file will be saved with UTF8 encoding.
.OUTPUTS
   Overwrites the original ini file
#>
function Rename-IniKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$Key,

        [Parameter(Mandatory=$true,
                   Position=2)]
        [string]$NewKey,

        [Parameter(Mandatory=$false,
                   Position=3)]
        [string]$Section,

        [Parameter(Mandatory=$false,
                   Position=4)]
        [ValidateSet("Unicode", "UTF7", "UTF8", "UTF32", "ASCII", "BigEndianUnicode", "Default", "OEM")]
        [string]$Encoding = "UTF8",

        [Parameter(Mandatory=$False,
                   Position=5)]
        [switch]$Force
    )

    Process {
        
        Write-Verbose "Checking if path exists"
        if (Test-Path $Path) {
            Write-Verbose "Path exists"
            Write-Verbose "Reading ini file with Get-Ini"
            $ini = Get-Ini -Path $Path -Verbose:$false
            Write-Verbose "Get-Ini completed"
        } else {
            Write-Error 'Path does not exist'
            break
        }

        Write-Verbose 'Checking value to remove'

        if ($Section) {
            $Section = $Section.Replace('[','').Replace(']','')
            $inisection = "[$Section]"
        } else {
            $inisection = $null
        }
        
        $iniproperty = $Key

        # check if the value contains a [section]
        <#
        if ($Value -like '*]*') {
            $tempvalue = $Key.Trim().Split(']')
            $inisection = "$($tempvalue[0].Trim())]"
            $iniproperty = "$($tempvalue[1].Trim())"
            Write-Verbose "Section: $inisection"
            Write-Verbose "Property: $iniproperty"
        } else {
            $inisection = ""
            $iniproperty = $Key
            Write-Verbose "No section selected"
            Write-Verbose "Property: $iniproperty"
        }
        #>
        Write-Verbose 'Value check completed'
        Write-Verbose 'Checking object for matching properties'

        if ($inisection) {
            # if section was included in the Value parameter
            [array]$availableSections = ($ini | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {$_.Contains(']')}).tolower()
            if ($availableSections.Contains($inisection.ToLower())) {
                # Section exists in the ini file
                Write-Verbose "Section $inisection exists"
                [array]$availableProps = ($ini.$inisection | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {!$_.Contains(']')}).ToLower()
                if ($availableProps.Contains($iniproperty.ToLower())) {
                    # Property exists in the correct section in the ini file
                    Write-Verbose "Property $iniproperty exists"
                    $tempvalue = $ini.$inisection.$iniproperty
                    Write-Verbose "Removing property"
                    $ini.$inisection.PSObject.Properties.Remove($iniproperty)
                    Write-Verbose "Recreating property with new name and same value"
                    $ini.$inisection | Add-Member -MemberType NoteProperty -Name $NewKey -Value $tempvalue
                } else {
                    Write-Error "ini file contains the section but does not contain requested configuration: $iniproperty"
                    break
                }
            } else {
                Write-Error "ini file does not contain requested section: $inisection"
                break
            }
            
        } else {
            # if no section was included in the Value parameter
            if ($ini.psobject.properties.name.Contains($Key)) {
                $tempvalue = $ini.$iniproperty
                Write-Verbose "Removing property"
                $ini.PSObject.Properties.Remove($iniproperty)
                Write-Verbose "Recreating property with new name and same value"
                $ini | Add-Member -MemberType NoteProperty -Name $NewKey -Value $tempvalue
                Write-Verbose 'Value removed from ini object'

            } else {
                Write-Error 'Key does not exist in ini file'
                break
            }
            
        }
        
        #$ini
        # Recreate the ini file
        Write-Verbose 'Saving file'
        New-Ini -Path $Path -Content $ini -Encoding $Encoding -Force:$Force -Verbose:$false
    }
}


<#
.Synopsis
    Sets a number of keys and values in ini file based on a hash table
.DESCRIPTION
    Sets a number of keys and values in ini file based on a hash table. Sections are separated by naming them within brackets, like this: [section]key
    The keys will be added if they do not exist.
    Comments will be ignored.
    Warning: Even comments in the target ini file will be removed!
.EXAMPLE
   Set-IniFromHash -Path c:\config.ini -Values @{'DebugLog'='false';'[settings]Hostname'='localhost'} -Encoding UTF8

   Opens the file config.ini and sets the key DebugLog to false and in the [settings] section sets the Hostname to localhost.
.OUTPUTS
   Overwrites the original ini file
#>
function Set-IniFromHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [hashtable]$Values,

        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$false,
                   Position=2)]
        [ValidateSet("Unicode", "UTF7", "UTF8", "UTF32", "ASCII", "BigEndianUnicode", "Default", "OEM")]
        [psobject]$Encoding = "UTF8",

        [Parameter(Mandatory=$False,
                   ValueFromPipeline=$False,
                   Position=3)]
        [switch]$Force
        )

    Process {
        [string]$section = ''

        Write-Verbose "Checking if path exists"
        if (Test-Path $Path) {
            Write-Verbose "Path exists"
            Write-Verbose "Reading ini file with Get-Ini"
            $ini = Get-Ini -Path $Path -Verbose:$false
            Write-Verbose "Get-Ini completed"
        } else {
            Write-Error 'Path does not exist'
            break
        }

        foreach ($key in $Values.keys) {
            Write-Verbose "Processing $key"
            if ($key -like '*]*') {
                Write-Verbose "Section selected"
                $keysplit = $key.Split(']')
                $section = $keysplit[0] + ']'
                $property = $keysplit[1]
                [array]$availableSections = ($ini | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {$_.Contains(']')}).tolower()
                if ($availableSections.Contains($section.ToLower())) {
                    Write-Verbose "Section $section exists"

                    [array]$availableProps = ($ini.$section | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {!$_.Contains(']')}).ToLower()
                    if (!$availableProps.Contains($property.ToLower())) {
                        Write-Verbose "Property $property does not exist"
                        Write-Verbose "Creating new property $property"
                        Add-Member -InputObject $ini.$section -MemberType NoteProperty -Name $property -Value $Value
                    } else {
                        Write-Verbose "Property $property exist"
                        Write-Verbose "Setting property value to $Value"
                        $ini.$section.$Property = $Value
                    }
                } else {
                    Write-Verbose "Section $section does not exist"
                    $props = [hashtable]@{$property = $Values.$key}
                    $newValue = New-Object PSObject -Property $props
                    Add-Member -InputObject $ini -MemberType NoteProperty -Name $Section -Value $newValue
                }
                $ini.$section.$property = $Values.$key
            } else {
                Write-Verbose "No section selected"
                $property = $key
                [array]$availableProps = ($ini | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {!$_.Contains(']')}).ToLower()
                if (!$availableProps.Contains($property.ToLower())) {
                    Write-Verbose "Property $property does not exist"
                    Write-Verbose "Creating new property $property"
                    Add-Member -InputObject $ini -MemberType NoteProperty -Name $property -Value $Values.$key
                } else {
                    Write-Verbose "Property $property exist"
                    Write-Verbose "Setting property value to $($Values.$key)"
                    $ini.$Property = $Values.$key
                } 
            }
        }
        # uncomment below for debug
        # $ini 
        Write-Verbose 'Saving file'
        New-Ini -Path $Path -Content $ini -Encoding $Encoding -Force:$Force -Verbose:$false
    }
}



<#
.Synopsis
    Reads an ini file and creates an object based on the content of the file
.DESCRIPTION
    Reads an ini file and creates an object based on the content of the file. One property per key/value. Sections will be named with surrounding brackets and will contain a list of objects based on the keys within that section.
    Comments will be ignored.
.EXAMPLE
   get-ini -Path "C:\config.ini"

   Opens the file config.ini and creates an object based on that file.
.OUTPUTS
   Outputs an custom object of the type File.Ini
#>
function Get-Ini {
    [CmdletBinding()]
    param(
        # Enter the path for the ini file
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Path
    )

    Process{
        if (!(Test-Path $Path)) {
            Write-Error 'Invalid path'
            break
        }

        $iniFile = Get-Content $Path -Verbose:$false
        $currentSection = ''
        $currentKey = ''
        $currentValue = ''
    
        [hashtable]$iniSectionHash = [ordered]@{}
        [hashtable]$iniConfigArray = [ordered]@{}

        foreach ($line in $iniFile) {
            # below need to be changed to check for existance of [ and ] instead of end and start
            if ( $line.StartsWith('[') -and $line.EndsWith(']') ) {
                Write-Verbose "Found new section."
                if ($currentSection -ne ''){
                    Write-Verbose "Creating section property based on array:"
                    $keyobj = New-Object PSObject -Property $iniConfigArray
                    $keyobj.PSObject.TypeNames.Insert(0,'File.Ini.Config')
                    $iniSectionHash.Add($currentSection,$keyobj)
                    [hashtable]$iniConfigArray = @{}
                    Write-Verbose "Created section property: $currentSection"
                }
                if ($iniConfigArray.count -gt 0) {
                    $rootSection = $iniConfigArray
                    [hashtable]$iniConfigArray = [ordered]@{}
                }
                $currentSection = $line
                Write-Verbose "Current section: $currentSection"
                continue
            }
            Write-Verbose "Parsing line: $line"
            if ( $line.Contains('=') ){
                $keyvalue = $line.Split('=')
                [string]$currentKey   = $keyvalue[0]
                [string]$currentValue = $keyvalue[1]
                $valuehash = @{
                    $currentKey = $currentValue
                }
                $iniConfigArray.Add($currentKey, $currentValue)
                Write-Verbose "Added keyvalue: $($keyvalue[0]) = $($keyvalue[1])"
            } 
            <# below was for handling comments, but I wont do it...
              elseif ($line.Contains('#') -or $line.Contains(';')) {
                [string]$currentKey   = $line
                [string]$currentValue = ""
                $valuehash = @{
                    $currentKey = $currentValue
                }
                $iniConfigArray.Add($currentKey, $currentValue)
                Write-Verbose "Added comment: $currentKey"
            }#>
        }
        $keyobj = New-Object PSObject -Property $iniConfigArray
        $keyobj.PSObject.TypeNames.Insert(0,'File.ini.Section')
        $iniSectionHash.Add($currentSection,$keyobj)
        Write-Verbose "Created last section property: $currentSection"
        $result = New-Object PSObject -Property $iniSectionHash
        if ($rootSection) {
            foreach ($key in $rootSection.keys){
                Add-Member -InputObject $result -MemberType NoteProperty -Name $key -Value $rootSection.$key
            }
        }
        $result.PSObject.TypeNames.Insert(0,'File.ini')
        Return $result
    }
}


<#
.Synopsis
    Creates an ini file based on a custom object of the type File.Ini
.DESCRIPTION
    Creates an ini file based on a custom object of the type File.Ini
    Comments will be ignored.
.EXAMPLE
   get-ini -Path "C:\config.ini" | new-ini -Path c:\config_new.ini -Encoding UTF8

   Opens the file config.ini and which creates a File.Ini object. The object is then piped to New-Ini which will create a new file based on that object.
.OUTPUTS
   Creates a new ini file
#>
function New-Ini {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [psobject]$Content,

        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$false,
                   Position=2)]
        [ValidateSet("Unicode", "UTF7", "UTF8", "UTF32", "ASCII", "BigEndianUnicode", "Default", "OEM")]
        [string]$Encoding = "UTF8",

        [Parameter(Mandatory=$False,
                   ValueFromPipeline=$False,
                   Position=3)]
        [switch]$Force
    )

    Process {
        [array]$result = @()
        $sections = $Content | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name
        foreach ($section in $sections){
            if ($section -notlike '*]*') {
                $result += "$section=$($Content.$section)"
            }
        }
        if ($result.count -gt 0) {
            $result += " "
        }
        foreach ($section in $sections){
            if ($section -like '*]*') {
                $result += "$section"
                $keys = $Content.$section | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name
                foreach ($key in $keys){
                    $result += "$key=$($Content.$section.$key)"
                }
                $result += " "
            }
        }
        $result | Out-File -FilePath $Path -Encoding $Encoding -Force:$Force
    }
} 


function Test-Ini {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [hashtable]$Values
    )

    Process {
        Write-Verbose "Checking if path exists"
        if (Test-Path $Path) {
            Write-Verbose "Path exists"
            Write-Verbose "Reading ini file with Get-Ini"
            $ini = Get-Ini -Path $Path -Verbose:$false
            Write-Verbose "Get-Ini completed"
        } else {
            Write-Error 'Path does not exist'
            return $false
        }

        foreach ($key in $Values.keys) {
            Write-Verbose "Processing $key"
            if ($key -like '*]*') {
                Write-Verbose "Section selected"
                $keysplit = $key.Split(']')
                $section = $keysplit[0] + ']'
                $property = $keysplit[1]
                [array]$availableSections = ($ini | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {$_.Contains(']')}).tolower()
                if ($availableSections.Contains($section.ToLower())) {
                    Write-Verbose "Section $section exists"

                    [array]$availableProps = ($ini.$section | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {!$_.Contains(']')}).ToLower()
                    if (!$availableProps.Contains($property.ToLower())) {
                        Write-Verbose "Property $property does not exist"
                        Write-Verbose "1. Property $property NOT OK"
                        return $false
                    } else {
                        Write-Verbose "Property $property exist"
                        if ($ini.$section.$Property -ne $Values.$key){
                            Write-Verbose "2. Property $property NOT OK"
                            return $false
                        } else {
                            Write-Verbose "1. Property $property OK"   
                        }

                    }
                } else {
                    Write-Verbose "Section $section does not exist"
                    return $false
                }
                $ini.$section.$property = $Values.$key
            } else {
                Write-Verbose "No section selected"
                $property = $key
                [array]$availableProps = ($ini | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} | Select-Object -ExpandProperty Name | Where-Object {!$_.Contains(']')}).ToLower()
                if (!$availableProps.Contains($property.ToLower())) {
                    Write-Verbose "Property $property does not exist"
                    Write-Verbose "3. Property $property NOT OK"
                    return $false
                } else {
                    Write-Verbose "Property $property exist"
                    if ($ini.$Property -ne $Values.$key) {
                        Write-Verbose "4. Property $property NOT OK"
                        return $false
                    } else {
                        Write-Verbose "2. Property $property OK"
                    }
                    
                } 
            }
        }

        return $true
    }
}