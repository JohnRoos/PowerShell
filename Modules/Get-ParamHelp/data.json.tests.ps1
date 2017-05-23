# data.json path
$jsonfilepath = Split-Path $MyInvocation.MyCommand.Path -Parent
$jsonfilepath += '\data.json'

# Unit tests for verifying data.json
Describe "JSON data" {

    # Just a couple of quick tests before starting the proper tests.
    It "Json file can be read from disk" {
        if (Get-Content -Path $jsonfilepath) {
            $test = $true
        } else {
            $test = $false
        }
        $test | Should Be $true
    }

    It "Json file can be converted to PSobjects" {
        Get-Content -Path $jsonfilepath | ConvertFrom-Json | Should Not BeNullOrEmpty
    }

    # The actual tests of the content of the file

    $data = Get-Content -Path $jsonfilepath | ConvertFrom-Json
    $propsToHave = @{
        'Name'        = [string]
        'Type'        = [string]
        'Parent'      = [string]
        'Description' = [string]
        'Examples'    = [system.array]
        'Links'       = [system.array]
        }
    $propsNotToHave = @('ExamplesCount')
    $exampleprops = @{
        Id = [int]
        Example = [string]
        Description = [string]
    }
    $linkprops = @{
        Uri = [string]
        Description = [string]
    }
    foreach ($obj in $data) {
        Context "$($obj.Name)" {
            
            # validate base properties
            foreach ($key in $propsToHave.Keys) {
                
                It "Has property $key" {
                    $obj.psobject.Properties.Name -contains $key | Should Be $true
                }
                
                It "Property $key is $($propsToHave[$key])" {
                    $obj.$key -is $propsToHave[$key] | Should Be $true
                }

            }

            # validate base properties that the object should not have (has slipped in before...)
            foreach ($prop in $propsNotToHave){
                
                It "Does not have property $prop" {
                    $obj.psobject.Properties.Name -notcontains $prop | Should Be $true
                }
            }

            # Validate Examples (if any)
            if ($obj.Examples.Length -gt 0){
                $exID = 0
                foreach ($example in $obj.Examples) {
                    $exID++
                    foreach ($prop in $exampleprops.Keys){
                        
                        It "Example $exID has $prop property" {
                            $example.psobject.Properties.Name -contains $prop | Should Be $true
                        }
                        
                        It "Property $prop is $($exampleprops[$prop])" {
                            $example.$prop | Should BeOfType $exampleprops[$prop]
                        }

                    }

                    # Validate that no extra properties exist
                    It "No additional Example properties" {
                        $example.psobject.Properties.Name.Count | Should Be $exampleprops.Count
                    }
                }   
            }
            
            # Validate Links (if any)
            if ($obj.Links.Length -gt 0){
                $linkID = 0
                foreach ($link in $obj.Links) {
                    $linkID++
                    foreach ($prop in $linkprops.Keys){
                        
                        It "Link $linkID has $prop property" {
                            $link.psobject.Properties.Name -contains $prop | Should Be $true
                        }
                        
                        It "Property $prop is $($linkprops[$prop])" {
                            $link.$prop | Should BeOfType $linkprops[$prop]
                        }

                    }

                    # Validate that no extra properties exist
                    It "Has no additional Link properties" {
                        $link.psobject.Properties.Name.Count | Should Be $linkprops.Count
                    }
                }

            }

            # Validate that no extra properties exist
            It "Has no additional base properties" {
                $obj.psobject.Properties.Name.Count | Should Be $propsToHave.Count
            }
        }
    }
}
