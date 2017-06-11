
#region functions
function Get-ParamHelp {
    [CmdletBinding(HelpUri = 'http://blog.roostech.se/')]
    [OutputType([String],[PSObject])]
    param (    
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$Name,
        
        [Parameter(Mandatory=$false,
                   Position=5)]
        [switch]$Raw,
        [switch]$Online
    )
    <#
    DynamicParam {
        $attributes1 = New-Object System.Management.Automation.ParameterAttribute
        $attributes1.ValueFromPipelineByPropertyName = $true
        $attributes1.Position = 0
        $attributes1.HelpMessage = 'Enter the name of the parameter validation argument or attribute'

        $attributes2 = New-Object System.Management.Automation.ParameterAttribute
        $attributes2.Position = 1
        $attributes2.HelpMessage = 'Use this switch parameter to get the raw object instead of a help message.'

        $attributeCollection1 = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection1.Add($attributes1)

        $attributeCollection2 = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection2.Add($attributes2)
         
        $_Values1 = (GetJsonData).Name
        $ValidateSet1 = new-object System.Management.Automation.ValidateSetAttribute($_Values1)                 
        $attributeCollection1.Add($ValidateSet1)

        $dynParam1 = new-object -Type System.Management.Automation.RuntimeDefinedParameter("Name", [string], $attributeCollection1)
        $dynParam2 = new-object -Type System.Management.Automation.RuntimeDefinedParameter("Raw", [switch], $attributeCollection2)
        
        $paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("Name", $dynParam1)
        $paramDictionary.Add("Raw", $dynParam2)
        
        return $paramDictionary
    }
    #>



    Begin {
        $allobjects = GetJsonData
    }

    Process {
#        $Name = $PSBoundParameters['Name']
        $jsonobjects = @()
        foreach ($object in $allobjects) {
            if ( $object.Name -like $Name -or !$Name) {
                $jsonobjects += $object
            }
        }

        if (!$jsonobjects){
            Throw "Could not find help content searching for '$Name'"
            return
       # } elseif ($jsonobjects.count -gt 1 -or $PSBoundParameters['Raw']) {
        } elseif ($jsonobjects.count -gt 1 -or $Raw) {
            return $jsonobjects
        }

        if ($Online) {
            Start-Process -FilePath "http://blog.roostech.se/p/advancedfunctions.html#$($jsonobjects[0].Name)"
            return
        }
    
        $jsonobject = $jsonobjects[0]
        $completestring = ""
        $namestring = $jsonobject.Name + " (" + $jsonobject.Type + ")"
        $namestring = "NAME`n" + (GetPaddedString -Padding 4 -String $namestring)
        $descstring = "DESCRIPTION`n" + (GetPaddedString -Padding 4 -String ($jsonobject.Description))
    
        $examplestring = ""
        for ($i = 0; $i -lt $jsonobject.Examples.Count; $i++) {
            $examplestring += (GetPaddedString -Padding 4 -String ("-------------------------- EXAMPLE " + ($jsonobject.Examples[$i].Id) + " --------------------------")) + "`n`n"
            $examplestring += (GetPaddedString -Padding 4 -String ($jsonobject.Examples[$i].Description)) + "`n`n"
            $examplestring += (GetPaddedString -Padding 8 -String ($jsonobject.Examples[$i].Example)) + "`n`n`n"
        }

        $linkstring = "RELATED LINKS`n"
        for ($i = 0; $i -lt $jsonobject.Links.Count; $i++) {
            $linkstring += (GetPaddedString -Padding 4 -String ($jsonobject.Links[$i].Description + ":")) + "`n"
            $linkstring += "    " + ($jsonobject.Links[$i].Uri + "`n`n")
        }

        $completestring += "`n`n$namestring`n`n$descstring`n`n`n$examplestring$linkstring"
        return $completestring
    }
}
function Add-ParamHelp {
    [CmdletBinding(HelpUri = 'http://blog.roostech.se/')]    
    param (    
        # Enter the name of the parameter validation argument or attribute
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$Type,
        [string]$Parent,
        [string]$Description
    )

    Begin {
        $allobjects = GetJsonData
    }
        
    Process 
    {
        if ($allobjects.Name -contains $Name) {
            Write-Error "Name already exist"
            return
        }

        $examples = New-Object -TypeName System.Collections.ArrayList
        $links = New-Object -TypeName System.Collections.ArrayList

        $props = [ordered]@{
            Name = $Name
            Type = $Type
            Parent = $Parent
            Description = $Description
            Examples = $examples
            Links = $links
        }
        $obj = New-Object -TypeName psobject -Property $props
        $allobjects += $obj
        SaveJsonData -data $allobjects
    }
    
}
  #add ShouldProcess
function Set-ParamHelp {
    [CmdletBinding(HelpUri = 'http://blog.roostech.se/')]    
    param (    
        # Enter the name of the parameter validation argument or attribute
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$NewName,
        [string]$Type,
        [string]$Parent,
        [string]$Description
    )

    Begin {
        $allobjects = GetJsonData
    }
    Process {
        
        if (-not (ValidateOneMatch -Name $Name -allobjects $allobjects)) {
            return
        }
        # Only one match, continue

        for ($i = 0; $i -lt $allobjects.Count; $i++) {
            if ($allobjects[$i].Name -eq $Name) {
                # Found object. Time to update.
                if ($NewName){
                    $allobjects[$i].Name = $NewName
                }
                if ($Type){
                    $allobjects[$i].Type = $Type
                }
                if ($Parent){
                    $allobjects[$i].Parent = $Parent
                }
                if ($Description){
                    $allobjects[$i].Description = $Description
                }
            }
        }

        SaveJsonData -data $allobjects
        
    }
}
function Add-ParamHelpExample {
    [CmdletBinding(HelpUri = 'http://blog.roostech.se/')]    
    param (    
        # Enter the name of the parameter validation argument or attribute
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Enter the example code
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Example,

        # Enter the description of the example
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$ExampleDescription
    )

    Begin {
        $allobjects = GetJsonData
    }
    Process {
        ValidateOneMatch -Name $Name -allobjects $allobjects | Out-Null
        <#
        if (-not (ValidateOneMatch -Name $Name -allobjects $allobjects)) {
            Throw "Name must be unique"
        }
        #>
        # Only one match, continue

        for ($i = 0; $i -lt $allobjects.Count; $i++) {
            if ($allobjects[$i].Name -eq $Name) {
                # Found object. Time to update.
                $x = $allobjects[$i].Examples.Count
                $allobjects[$i].Examples += [ordered]@{
                        Id = $x+1
                        Example = $Example 
                        Description = $ExampleDescription
                    }
                
            }
        }
        SaveJsonData -data $allobjects 
    }
}
  #add ShouldProcess
function Set-ParamHelpExample {
    [CmdletBinding(HelpUri = 'http://blog.roostech.se/')]    
    param (    
        # Enter the name of the parameter validation argument or attribute
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Enter the id of the example
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [int]$ExampleId,

        # Enter the example code
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$ExampleCode,

        # Enter the description of the example
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$ExampleDescription
    )

    Begin {
        $allobjects = GetJsonData
    }
    Process {
        ValidateOneMatch -Name $Name -allobjects $allobjects | Out-Null
        for ($i = 0; $i -lt $allobjects.Count; $i++) {
            if ($allobjects[$i].Name -eq $Name) {
                # Found object. Time to update.
                # Add error handling if the example does not exist
                for ($e = 0; $e -lt $allobjects[$i].Examples.Count; $e++) {
                    if (($allobjects[$i].Examples[$e].id) -eq $ExampleId){
                        if ($ExampleCode){
                            $allobjects[$i].Examples[$e].Example = $ExampleCode
                        }
                        if ($ExampleDescription){
                            $allobjects[$i].Examples[$e].Description = $ExampleDescription
                        }
                    }
                }
            }
        }
        SaveJsonData -data $allobjects
    }
}
function Remove-ParamHelpExample {
    [CmdletBinding(HelpUri = 'http://blog.roostech.se/',
                   SupportsShouldProcess=$true,
                   ConfirmImpact="Low")]    
    param (    
        # Enter the name of the parameter validation argument or attribute
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Enter the id of the example
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [int[]]$ExampleId
    )

    Begin {
        $allobjects = GetJsonData
    }

    Process {
        Write-Verbose "Validating one match"
        ValidateOneMatch -Name $Name -allobjects $allobjects | Out-Null
        Write-Verbose "Searching for help content"
        for ($i = 0; $i -lt $allobjects.Count; $i++) {
            if ($allobjects[$i].Name -eq $Name) {
                Write-Verbose "Found base object. Looking for example id."
                $NewExampleArray = @()
                foreach ($example in $allobjects[$i].Examples){
                    if ($ExampleId -notcontains $example.id){
                        Write-Verbose "Not this one"
                        $NewExampleArray += $example
                    } else {
                        Write-Verbose "Found it"
                        $ExampleId = $ExampleId.Where({$_ -ne $example.id}) 
                    } 
                }
                Write-Verbose "Rebuilding object without the removed example"
                $allobjects[$i].Examples = $NewExampleArray
            }
        }
        if ($ExampleId.count -eq 0) {
            Write-Verbose "Saving to disk"
            SaveJsonData -data $allobjects
        } else {
            Throw "Could not find example $($ExampleId -join ', ')."
        }
    }
}
#endregion

#region Todo
function Add-Link {}
  #add ShouldProcess
function Set-Link {}
  #add ShouldProcess
function Remove-Link {}
  #add ShouldProcess
function Remove-Example {}
  #add ShouldProcess
Function Update-ParamHelp {

    
    # check local meta by calling GetJsonData -meta
    $LocalMeta = GetJsonData -Meta

    # warn user if local changes has  been done
    if ($LocalMeta.Local.Modified) {
        Write-Warning "ParamHelp data has been locally modified. Use the Force parameter to overwrite all locally saved ParamHelp data."
        return
    }

    # call DownloadUpdate with Url from Source in Data.json
    $DownloadedUpdate = DownloadUpdate -Uri $LocalMeta.Source -ErrorAction Stop

    # compare revision with current, if online version is newer: continue
    if ($LocalMeta.Revision -lt $DownloadedUpdate.Meta.Revision) {
        Write-Error "Local revision is newer than the downloaded version. Aborting update."
        return
    }
    
    # verify required module version, if version required is higher, prompt the user to update the module first
        # whats the easiest way to check the local module version from within the module?

    # backup existing data.json using SaveJsonData with custom name
    # update object meta with download date and modified = false
    # call SaveJsonData to save the file
    # inform the user that the revision history is available at GitHub (using FileHistory from data.json)
}
    

#endregion

#region helper-functions

function DownloadUpdate {
    [CmdletBinding(HelpUri = 'http://blog.roostech.se/')]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [Uri]$Uri
    )

    Process 
    { 
        $webrequest = Invoke-WebRequest -Uri $Uri -UseBasicParsing -ErrorAction Stop
        $converted = ConvertFrom-Json -InputObject $webrequest -ErrorAction Stop
    
        # basic verification
        if ([string]::IsNullOrEmpty($converted.Meta.RequiresModuleVersion))
        {
            Write-Error "Cannot use downloaded data. Missing RequiresModuleVersion in Meta"
        }
        if (-not [int]::Parse($converted.Meta.Revision))
        {
            Write-Error "Cannot use downloaded data. Missing Revision in Meta"
        }
        if ([string]::IsNullOrEmpty($converted.ParamHelp[0].Name)) 
        {
            Write-Error "Cannot use downloaded data. ParamHelp data is in wrong format. (missing name)"
        }
        if ([string]::IsNullOrEmpty($converted.ParamHelp[0].description)) 
        {
            Write-Error "Cannot use downloaded data. ParamHelp data is in wrong format. (missing description)"
        }

        # return entire object, including meta
        $converted
    }
}

function GetPaddedString {
    param ([int]$Padding, [string]$String)
    $ConsoleWidth = (Get-Host).UI.RawUI.BufferSize.Width
    if ($Padding -le 0){
        $Padding = 1
    }

    $outputString = ""
    $stringlines = $String.ToString() -split "`r`n|`r|`n"
    foreach ($line in $stringlines){
        if ($outputString.Length -gt 1) {
            $outputString += "`n"
        }
        $stringArray = $line.Split(' ')
        $lineString = " " * ($Padding-1)
        for ($i = 0; $i -lt $stringArray.count; $i++) {
            if (($lineString + " " + $stringArray[$i]).Length -le $ConsoleWidth-1) {
                $lineString += " " + $stringArray[$i]
            } else {
                $outputString += $linestring
                $outputString += "`n"
                $linestring = (" " * $Padding) + $stringArray[$i]
            }

            if ($i -eq ($stringArray.count - 1)) {
                $outputString += $linestring
            }
        }
    }
    return $outputString
}
function ValidateOneMatch {
    param (
        $Name,
        $allobjects
    )
    $jsonobjects = @()
    foreach ($object in $allobjects.Name) {
        if ( $object -eq $Name) {
            $jsonobjects += $object
        }
    }

    if (!$jsonobjects){
        Throw "Could not find help content with that name."
    } elseif ($jsonobjects.count -gt 1) {
        Throw "Found multiple matches. Thats wierd..."
    } else {
        return $true
    }
}
function GetJsonData {
    param (
        [string]$Path,
        [switch]$Meta
    )

    if ([string]::IsNullOrEmpty($Path)) {
        $Path = Split-Path -Path $PSCommandPath -Parent
        $Path += '\data.json'
    }
    
    if (-not (Test-Path -Path $Path)) {
        Throw "Path not found: $Path"
    }

    $allobjects = Get-Content -Path $Path -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    if ($Meta) {
        if (($allobjects | Get-Member -MemberType NoteProperty).Name -notcontains 'Meta') {
            Write-Error "Json file is not valid. Metadata is missing."
        } else {
            return $allobjects.Meta
        }
    } else {
        $jsonobjects = @()
        foreach ($object in $allobjects.ParamHelp) {
        
            $props = $object | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            if (-not ($props -contains 'Name' -and $props -contains 'Description')) {
                Write-Error "Json file is not valid"
            }
            $object.PSObject.TypeNames.Insert(0,'ParameterHelp')
            Add-Member -InputObject $object -MemberType ScriptProperty -Name ExamplesCount -Value {$this.Examples.Count}
            $jsonobjects += $object
        }
        Update-TypeData -TypeName ParameterHelp -DefaultDisplayPropertySet Name, Type, ExamplesCount -Force -WhatIf:$false
    
        return $jsonobjects
    }
}
# add default path, same as GetJsonData
function SaveJsonData {
    param (
        [pscustomobject[]]$data,
        [string]$Path
    )
    
    # move to parameter script validation?
    foreach ($object in $data) {
        if ($object.psobject.TypeNames -notcontains 'ParameterHelp'){
            Throw "Data parameter only accepts one or more ParameterHelp objects"
        }
    }

    if ([string]::IsNullOrEmpty($Path)) {
        $Path = Split-Path -Path $PSCommandPath -Parent
        $Path += '\data.json'
    }

    # move to parameter script validation?
    if (-not (Test-Path -Path (Split-Path -Path $Path -Parent))) {
        Throw "Directory not found"
    }

    try {
        $data | Sort-Object -Property Name | Select-Object -Property * -ExcludeProperty ExamplesCount | ConvertTo-Json -Depth 3 -ErrorAction Stop | Out-File -FilePath $Path -ErrorAction Stop
    } catch {
        Throw "Unable to save json file"
    }
}
#endregion