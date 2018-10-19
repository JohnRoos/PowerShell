<#
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'GetJsonData' }
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'SaveJsonData' }
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = '*JsonData' }
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'Get-ParamHelp' }
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'Set-ParamHelp' }
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1' }

    Invoke-Pester .\Get-ParamHelp.tests.ps1 -Tag New
#>



# data.json path
$basepath = Split-Path $MyInvocation.MyCommand.Path -Parent
$jsonfilepath = "$basepath\data.json"
Set-Location $basepath

#Import-Module $basepath -Force -ErrorAction Stop

#$ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText("$basepath\Get-ParamHelp.ps1"))), $null, $null)
#. $basepath\Get-ParamHelp.ps1
Import-Module $basepath -Force
#region Sample Data

$SampleParamJson = @"
{
    "Name":"ParameterSetName",
    "Type":"Argument",
    "Parent":"Parameter",
    "Description":"Defines which parameter set a parameter belongs to. Multiple sets can be used. Parameters belonging to other sets will be filtered out if a set parameter is selected.",
    "Examples":[
        {
            "Id":1,
            "Example":"[parameter(ParameterSetName=\"MySetName\")]",
            "Description":"Sets the parameter set name to \"MySetName\"."
        }
    ],
    "Links":[
        {
            "Uri":"https://msdn.microsoft.com/en-us/library/ms714348(v=vs.85).aspx",
            "Description":"Parameter Attribute Declaration (MSDN)"
        }
    ]
}
"@
$SampleParamJsonWithoutExamples = @"
{
  "Meta":  {
                 "SchemaVersion":  "2.0",
                 "RequiresModuleVersion":  "1.1.0",
                 "Revision":  42,
                 "Source":  "https://raw.githubusercontent.com/JohnRoos/PowerShell/master/Modules/Get-ParamHelp/data.json",
                 "FileHistory":  "https://github.com/JohnRoos/PowerShell/commits/master/Modules/Get-ParamHelp/data.json",
                 "OnlineVersion":  "http://blog.roostech.se/p/advancedfunctions.html",
                 "Local":  {
                               "DownloadDate":  "2018-10-18T19:57:56.6903477+02:00",
                               "Revision":  0,
                               "Modified":  false
                           }
             },
    "ParamHelp":  [
          {
              "Name":"ParameterSetName",
              "Type":"Argument",
              "Parent":"Parameter",
              "Description":"Defines which parameter set a parameter belongs to. Multiple sets can be used. Parameters belonging to other sets will be filtered out if a set parameter is selected.",
              "Links":[
                  {
                      "Uri":"https://msdn.microsoft.com/en-us/library/ms714348(v=vs.85).aspx",
                      "Description":"Parameter Attribute Declaration (MSDN)"
                  }
              ]
          }
      ]
}
"@
$SampleParamJsonWithoutName = @"
{
  "Meta":  {
                 "SchemaVersion":  "2.0",
                 "RequiresModuleVersion":  "1.1.0",
                 "Revision":  42,
                 "Source":  "https://raw.githubusercontent.com/JohnRoos/PowerShell/master/Modules/Get-ParamHelp/data.json",
                 "FileHistory":  "https://github.com/JohnRoos/PowerShell/commits/master/Modules/Get-ParamHelp/data.json",
                 "OnlineVersion":  "http://blog.roostech.se/p/advancedfunctions.html",
                 "Local":  {
                               "DownloadDate":  "2018-10-18T19:57:56.6903477+02:00",
                               "Revision":  0,
                               "Modified":  false
                           }
             },
    "ParamHelp":  [
          {
              "Type":"Argument",
              "Parent":"Parameter",
              "Description":"Defines which parameter set a parameter belongs to. Multiple sets can be used. Parameters belonging to other sets will be filtered out if a set parameter is selected.",
              "Links":[
                  {
                      "Uri":"https://msdn.microsoft.com/en-us/library/ms714348(v=vs.85).aspx",
                      "Description":"Parameter Attribute Declaration (MSDN)"
                  }
              ]
          }
      ]
}
"@
$SampleParamJsonWithoutDescription = @"
{
  "Meta":  {
                 "SchemaVersion":  "2.0",
                 "RequiresModuleVersion":  "1.1.0",
                 "Revision":  42,
                 "Source":  "https://raw.githubusercontent.com/JohnRoos/PowerShell/master/Modules/Get-ParamHelp/data.json",
                 "FileHistory":  "https://github.com/JohnRoos/PowerShell/commits/master/Modules/Get-ParamHelp/data.json",
                 "OnlineVersion":  "http://blog.roostech.se/p/advancedfunctions.html",
                 "Local":  {
                               "DownloadDate":  "2018-10-18T19:57:56.6903477+02:00",
                               "Revision":  0,
                               "Modified":  false
                           }
             },
    "ParamHelp":  [
          {
              "Name":"ParameterSetName",
              "Type":"Argument",
              "Parent":"Parameter",
              "Links":[
                  {
                      "Uri":"https://msdn.microsoft.com/en-us/library/ms714348(v=vs.85).aspx",
                      "Description":"Parameter Attribute Declaration (MSDN)"
                  }
              ]
          }
      ]
}
"@
$SampleParamJsonWithoutNameAndDescription = @"
{
  "Meta":  {
                 "SchemaVersion":  "2.0",
                 "RequiresModuleVersion":  "1.1.0",
                 "Revision":  42,
                 "Source":  "https://raw.githubusercontent.com/JohnRoos/PowerShell/master/Modules/Get-ParamHelp/data.json",
                 "FileHistory":  "https://github.com/JohnRoos/PowerShell/commits/master/Modules/Get-ParamHelp/data.json",
                 "OnlineVersion":  "http://blog.roostech.se/p/advancedfunctions.html",
                 "Local":  {
                               "DownloadDate":  "2018-10-18T19:57:56.6903477+02:00",
                               "Revision":  0,
                               "Modified":  false
                           }
             },
    "ParamHelp":  [
          {
              "Type":"Argument",
              "Parent":"Parameter",
              "Links":[
                  {
                      "Uri":"https://msdn.microsoft.com/en-us/library/ms714348(v=vs.85).aspx",
                      "Description":"Parameter Attribute Declaration (MSDN)"
                  }
              ]
          }
      ]
}
"@

# Sample object which includes everything (normal object)
$SampleParamObject = $SampleParamJson | ConvertFrom-Json
$SampleParamObject.PSObject.TypeNames.Insert(0,'ParameterHelp')

# Sample object which does not have the correct TypeName
$SampleNonParamObject = $SampleParamJson | ConvertFrom-Json

# Sample object with correct TypeName but without Examples
$SampleParamObjectWithoutExamples = $SampleParamJsonWithoutExamples | ConvertFrom-Json
$SampleParamObjectWithoutExamples.PSObject.TypeNames.Insert(0,'ParameterHelp')

#endregion

#region Unit tests - Helper Functions

Describe "GetJsonData" {
    
    Context "Normal json file" {
        
        It "Runs normally when no parameter is provided" {
            GetJsonData | Should Not BeNullOrEmpty
        }

        It "Runs normally when a correct Path parameter is provided" {
            GetJsonData -Path $jsonfilepath | Should Not BeNullOrEmpty
        }
    
        It "Throws expected error when wrong Path is provided" {
            try {
                GetJsonData -Path 'TestDrive:\wrong-path\data.json'
                Throw "No exception thrown"
            } catch {
                $_.FullyQualifiedErrorId | Should Be "Path not found: TestDrive:\wrong-path\data.json"
            }
        }

        It "Throws expected error when file is not a json file" {
            try {
                GetJsonData -Path $PSCommandPath
                Throw "No exception thrown"
            } catch {
                $_.FullyQualifiedErrorId | Should Be "System.ArgumentException,Microsoft.PowerShell.Commands.ConvertFromJsonCommand"
            }
        }

        It "Throws expected error when Name parameter is " {
            try {
                GetJsonData -Path $PSCommandPath
                Throw "No exception thrown"
            } catch {
                $_.FullyQualifiedErrorId | Should Be "System.ArgumentException,Microsoft.PowerShell.Commands.ConvertFromJsonCommand"
            }
        }
    }

    Context "Abnormal json file"  {
        
        function Get-Content { 'should_not_be_used' }
            
        
        
        It "Runs normally when examples are missing in json" {
            Mock Get-Content {$SampleParamJsonWithoutExamples}
            GetJsonData | Should Not BeNullOrEmpty
        }
        
        It "When examples are missing, ExamplesCount is zero" {
            Mock Get-Content { $SampleParamJsonWithoutExamples }
            (GetJsonData).ExamplesCount | Should -Be 0
            
        }
        
        It "When examples are missing, Name should still be there" {
            Mock Get-Content {$SampleParamJsonWithoutExamples}
            (GetJsonData).Name | Should Be 'ParameterSetName'
        }

        It "Throws expected error if Name is missing" {
            Mock Get-Content {$SampleParamJsonWithoutName}
            try {
                GetJsonData
                Throw "No exception thrown"
            } catch {
                $_.FullyQualifiedErrorId | Should Be "Json file is not valid"
            }
        }

        It "Throws expected error if Description is missing" {
            Mock Get-Content {$SampleParamJsonWithoutDescription}
            try {
                GetJsonData
                Throw "No exception thrown"
            } catch {
                $_.FullyQualifiedErrorId | Should Be "Json file is not valid"
            }
        }

        It "Throws expected error if both Name and Description is missing" {
            Mock Get-Content {$SampleParamJsonWithoutNameAndDescription}
            try {
                GetJsonData
                Throw "No exception thrown"
            } catch {
                $_.FullyQualifiedErrorId | Should Be "Json file is not valid"
            }
        }
        
    }
}

Describe "SaveJsonData"  {
    
    Copy-Item -Path $jsonfilepath -Destination 'TestDrive:\data.json'

    It "Runs normally when saving a ParameterHelp object to json" {
        SaveJsonData -data $SampleParamObject -Path 'TestDrive:\data.json' | Should BeNullOrEmpty
    }

    It "Throws expected error when not using a ParameterHelp object" {
        Try {
            SaveJsonData -data $SampleNonParamObject -Path 'TestDrive:\data.json'
            Throw "No exception thrown"
        } catch {
            $_.FullyQualifiedErrorId | Should Be 'Data parameter only accepts one or more ParameterHelp objects'
        }
    }

    it "Throws expected error when Path contains a non-existing directory" {
        try {
            SaveJsonData -data $SampleParamObject -Path 'TestDrive:\non-existing-folder\data.json'
            Throw "No exception thrown"
        } catch {
            $_.FullyQualifiedErrorId | Should Be 'Directory not found'            
        }
    }


}

Describe "GetPaddedString" {
 
    It "Returns a string" {
        GetPaddedString -Padding 4 -String 'This is a string' | Should BeOfType [string]
    }

    It ("Returns a string with one space if no parameters are used") {
        GetPaddedString | Should Be " "
    }

    It "Pads the string properly when the Padding parameter is used" {
        GetPaddedString -Padding 4 -String 'This is a string' | Should Be "    This is a string"
    }

    It "Pads very long strings into muliple lines" {
        # Force the termial width to 50, in case the test is run in a very wide window.
        Mock Get-Host {
            $props = @{ UI = @{ RawUI = @{ BufferSize = @{ Width = 50} } } }
            $result = New-Object -TypeName psobject -Property $props
            return $result 
        }
        $longstring = 'Defines which parameter set a parameter belongs to. Multiple sets can be used. Parameters belonging to other sets will be filtered out if a set parameter is selected.'
        GetPaddedString -Padding 6 -String $longstring | Should BeLike "*`n      *"
    }
        
}

Describe "ValidateOneMatch"  {
    
    BeforeAll {
        $allobjects = GetJsonData
    }

    It "Returns true if only one match is found" {
        ValidateOneMatch -Name "Parameter" -allobjects $allobjects | Should Be $true
    }

    It "Throws expected error if no match is found" {
        try {
            ValidateOneMatch -Name "qwerty" -allobjects $allobjects
            Throw "No exception thrown"
        } catch {
            $_.FullyQualifiedErrorId | Should Be "Could not find parameter help content with that name."
        }
    }

    It "Throws expected error if more than one match is found" {
        # set duplicate names (should not exist in the json file)
        $allobjects[0].Name = 'Test'
        $allobjects[1].Name = 'Test'
        try {
            ValidateOneMatch -Name "Test" -allobjects $allobjects
            Throw "No exception thrown"
        } catch {
            $_.FullyQualifiedErrorId | Should Be "Found multiple matches. Thats wierd..."
        }
    }

    It "Throws expected error if the Name parameter is omitted" {
        try {
            ValidateOneMatch -allobjects $allobjects
            Throw "No exception thrown"
        } catch {
            $_.FullyQualifiedErrorId | Should Be "Could not find parameter help content with that name."
        }
    }

    It "Throws expected rror if the allobjects parameter is omitted" {
        try {
            ValidateOneMatch -Name "Parameter"
            Throw "No exception thrown"
        } catch {
            $_.FullyQualifiedErrorId | Should Be "Could not find parameter help content with that name."
        }
    }

}

#endregion

#region unit tests - Advanced functions

$baseprops = @{
    'Name' = [string]
    'Type' = [string]
    'Parent' = [string]
    'Description' = [string]
    'Examples' = [psobject]
    'Links' = [psobject]
    'ExamplesCount' = [system.object]
}

$arrayprops = 'Examples', 'Links'

$exampleprops = @{
    Id = [int]
    Example = [string]
    Description = [string]
}
$linkprops = @{
    Uri = [string]
    Description = [string]
}

Describe "Get-ParamHelp" -tag 'new' {
    
    Context "Input" {

        It "Executes with no error when parameters are omitted" {
            { Get-ParamHelp } | Should Not Throw
        }

        It "Returns a string when parameter Name is used" {
            $Name = Get-ParamHelp | Select-Object -ExpandProperty Name -First 1
            Get-ParamHelp -Name $Name | Should BeOfType [system.string]
        }

        It "Throws expected error when wrong name is used" {
            try {
                Get-ParamHelp -Name "This should not match anything"
                Throw "No exception thrown"
            } catch {
                $_.FullyQualifiedErrorId | Should BeLike 'Could not find help content searching for*'  
            }
        }

        It "Returns ParameterHelp objects when the Raw parameter is used" {
            $Name = Get-ParamHelp | Select-Object -ExpandProperty Name -First 1
            (Get-ParamHelp -Name $Name -Raw).psobject.TypeNames[0] | Should Be 'ParameterHelp'
        }

        It "Returns one object when a full name is used" {
            $Name = Get-ParamHelp | Select-Object -ExpandProperty Name -First 1
            (Get-ParamHelp -Name $Name).count | Should Be 1
        }

        It "Returns the correct amount of objects when no parameters are used" {
            $count = (Get-Content -Path data.json | ConvertFrom-Json).ParamHelp.Count
            (Get-ParamHelp).count | Should Be $count
        }

        It "Opens a Url if the Online parameter is used" {
            Mock Start-Process {return $FilePath}
            Get-ParamHelp -Name Mandatory -Online | Should Be 'http://blog.roostech.se/p/advancedfunctions.html#Mandatory'
        }

    }

    Context "Output objects" {
        $Name = Get-ParamHelp | Select-Object -ExpandProperty Name -First 1
        $object = Get-ParamHelp -Name $Name -Raw
        foreach ($key in $baseprops.Keys) {
            It "Output object has a property called $key" {
                $object.psobject.Properties.Name -contains $key | Should Be $true 
            }

            if (![string]::IsNullOrEmpty($object.$key)) {
                It "Property $key is of type $($baseprops.$key)" {
                  $object.$key | Should BeOfType $baseprops.$key
                }
            }
        }

        if ($object.Examples.count -gt 0) {
            $exID = 0
            foreach ($example in $object.Examples) {
            $exID++    
                foreach ($exampleprop in $exampleprops.Keys) {
                   
                    It "Example $exID contains the property $exampleprop" {
                        $example.psobject.Properties.Name -contains $exampleprop | Should be $true
                    }

                    It "Example $exID property $exampleprop is of type $($exampleprops[$exampleprop])" {
                        $example.$exampleprop | Should BeOfType $exampleprops[$exampleprop]
                    }

                }
            }
        }
    }
}

<#
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'Set-ParamHelp' }
#>

Describe "Set-ParamHelp" {
    
    # verify that mocking works 
    # (might not work under certain conditions, like duplicate functions loaded etc.)
    Mock SaveJsonData { return 'SaveJsonData is mocked' }
    
    It 'Function SaveJsonData is mocked' {
        SaveJsonData | Should Be 'SaveJsonData is mocked' 
    }

    if (SaveJsonData -eq 'SaveJsonData is mocked') {

        # Mock SaveJsonData properly before doing proper tests
        Mock SaveJsonData { return ([PSCustomObject]@{ obj=$data}) }
 
        It 'Changes name on parameter help object' {
            $test = Set-ParamHelp -Name 'Parameter' -NewName 'ParameterTEST'
            $test.obj | Where-Object name -eq 'ParameterTEST' | Select-Object -ExpandProperty Name | Should Be 'ParameterTEST'
        }

        It 'Changes description on parameter help object' {
            $test = Set-ParamHelp -Name 'Parameter' -Type 'TestType'
            $test.obj | Where-Object Name -eq 'Parameter' | Select-Object -ExpandProperty Type | Should Be 'TestType'
        }

        It 'Changes description on parameter help object' {
            $test = Set-ParamHelp -Name 'Parameter' -Description 'TestDescription'
            $test.obj | Where-Object Name -eq 'Parameter' | Select-Object -ExpandProperty Description | Should Be 'TestDescription'
        }

        It 'Changes parent on parameter help object' {
            $test = Set-ParamHelp -Name 'Parameter' -Parent "TestParent"
            $test.obj | Where-Object name -eq 'Parameter' | Select-Object -ExpandProperty Parent | Should Be 'TestParent'
        }

    }
}

<#
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'Add-ParamHelp' }
#>

Describe "Add-ParamHelp" {

    # verify that mocking works 
    # (might not work under certain conditions, like duplicate functions loaded etc.)
    Mock SaveJsonData { return 'SaveJsonData is mocked' }
    
    It 'Function SaveJsonData is mocked' {
        SaveJsonData | Should Be 'SaveJsonData is mocked' 
    }

    if (SaveJsonData -eq 'SaveJsonData is mocked') {
    
        # Mock SaveJsonData properly before doing proper tests
        Mock SaveJsonData { return ([PSCustomObject]@{ obj=$data}) }
 
        $result = Add-ParamHelp -Name '_TestName_' -Type '_TestType_' -Parent '_TestParent_' -Description '_TestDescription_'
        $test = $result.obj | Where-Object -Property Name -eq '_TestName_'

        It "Saves the Name of the new help object" {
            $test.name | Should Be '_TestName_'
        }

        It "Saves the Type of the new help object" {
            $test.Type | Should Be '_TestType_'
        }

        It "Saves the Parent of the new help object" {
            $test.Parent | Should Be '_TestParent_'
        }

        It "Saves the Description of the new help object" {
            $test.Description | Should Be '_TestDescription_'
        }

        It "Throws expected error if the Name already exist" {
            Try {
                $name = Get-ParamHelp | Select-Object -First 1 -ExpandProperty Name
                Add-ParamHelp -Name $name -Type 'x' -Parent 'x' -Description 'x' -ErrorAction Stop
                Throw "No error thrown."
            } catch {
                $_.Exception.Message | Should Be 'Name already exist'
            }
        }

    }
}


<#
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'Add-ParamHelpExample' }
#>

Describe "Add-ParamHelpExample" {
 
    # verify that mocking works 
    # (might not work under certain conditions, like duplicate functions loaded etc.)
    Mock SaveJsonData { return 'SaveJsonData is mocked' }
    
    It 'Function SaveJsonData is mocked' {
        SaveJsonData | Should Be 'SaveJsonData is mocked' 
    }

    if (SaveJsonData -eq 'SaveJsonData is mocked') {
    
        # Mock SaveJsonData properly before doing proper tests
        Mock SaveJsonData { return ([PSCustomObject]@{ obj=$data}) }

        $name = Get-ParamHelp | Select-Object -First 1 -ExpandProperty Name
        $result = Add-ParamHelpExample -Name $name -Example '_TestExample_' -ExampleDescription '_TestExampleDescription_'
        $examples = $result.obj | Where-Object -Property Name -eq $name | Select-Object -ExpandProperty Examples
        $test = $examples[$examples.count-1]

        It 'Adds example code' {
            $test.Example | Should Be '_TestExample_'
        }

        It 'Adds example description' {
            $test.Description | Should Be '_TestExampleDescription_'
        }

        It 'Throws expected error if wrong name is used' {
            Try {
                Add-ParamHelpExample -Name 'some wrong name' -Example 'x' -ExampleDescription 'x'
                Throw "No error thrown"
            } catch {
                $_.FullyQualifiedErrorId | Should Be 'Could not find parameter help content with that name.'
            }
        }
    }
}

<#
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'Set-ParamHelpExample' }
#>

Describe "Set-ParamHelpExample" {

    # verify that mocking works 
    # (might not work under certain conditions, like duplicate functions loaded etc.)
    Mock SaveJsonData { return 'SaveJsonData is mocked' }
    
    It 'Function SaveJsonData is mocked' {
        SaveJsonData | Should Be 'SaveJsonData is mocked' 
    }

    if ((SaveJsonData -Path 'TESTDRIVE:\data.json') -eq 'SaveJsonData is mocked') {
        
        # Mock SaveJsonData properly before doing proper tests
        Mock SaveJsonData { return ([PSCustomObject]@{ obj=$data}) }

        $name = Get-ParamHelp | Where-Object -Property ExamplesCount -gt 0 | Select-Object -First 1 -ExpandProperty Name
        $result = Set-ParamHelpExample -Name $Name -ExampleId 1 -ExampleCode '_ExampleCode_' -ExampleDescription '_ExampleDescription_'
        $test = $result.obj | Where-Object -Property Name -eq $name | Select-Object -ExpandProperty Examples | Where-Object -Property Id -eq 1


        It 'Changes code in example' {
            $test.Example | Should Be '_ExampleCode_'
        }

        It 'Changes description in example' {
            $test.Description | Should Be '_ExampleDescription_'
        }

    }
}

<#
    Invoke-Pester .\Get-ParamHelp.tests.ps1 -CodeCoverage @{Path = '.\Get-ParamHelp.ps1'; Function = 'Remove-ParamHelpExample' }
#>

Describe "Remove-ParamHelpExample" {
    
    # verify that mocking works 
    # (might not work under certain conditions, like duplicate functions loaded etc.)
    function SaveJsonData {}
    
    Mock SaveJsonData { 'SaveJsonData is mocked' }
    
    It 'Function SaveJsonData is mocked' {
        SaveJsonData | Should Be 'SaveJsonData is mocked' 
    }

    if ((SaveJsonData -Path 'TESTDRIVE:\data.json') -eq 'SaveJsonData is mocked') {
        
        # Mock SaveJsonData before doing tests
        Mock SaveJsonData {param($data) $data }

        $sample = Get-ParamHelp | Where-Object -Property ExamplesCount -gt 0 | Select-Object -First 1
        $result = Remove-ParamHelpExample -Name $sample.Name -ExampleId 1 -Confirm:$false
        $test = $result | Where-Object -Property Name -eq $sample.Name


        <#
        Need to add support for ShouldProcess
        #>

        It 'Removes example' {
            $sample.Examples.Count - $test.Examples.Count | Should Be 1
        }

        It 'Throws expected exception if example id cannot be found' {
            try {
                Remove-ParamHelpExample -Name $sample.Name -ExampleId 998, 999 -Confirm:$false
                Throw 'No exception thrown'
            } catch {
                $_.FullyQualifiedErrorId | Should Be 'Could not find example 998, 999.'
            }
        }

    }

}
#endregion
