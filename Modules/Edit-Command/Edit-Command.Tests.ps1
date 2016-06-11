
Describe "Testing Edit-Command" {

    Mock OpenTab  {
        param ( [System.Text.StringBuilder] $code )
        Return 'Mocked'
    }

    It "Opens the help command in a new tab" {
        Edit-Command -Name help | Should Be 'Mocked'
    }
    
    It "Throws error when trying to open the heeeelp command" {
        { Edit-Command -Name heeeelp } | Should Throw
    }
    
    It "Throws error when *help* is used" {
        { Edit-Command -Name *help* } | Should Throw
    } 


}