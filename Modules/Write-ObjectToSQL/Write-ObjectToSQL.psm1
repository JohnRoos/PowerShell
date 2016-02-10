#REQUIRES -Version 4.0

<# 
.Synopsis
   Writes the properties of an object into a database table. The table will be created if it doesnt exist.
.DESCRIPTION
   Writes an object into a database table. If the table does not exist it will be created based on the 
   properties of the object. For every property of the object a column will be created. The data type for 
   each column will be converted from .Net data types into SQL Server data types.

   Not all data types are supported. Unsupported data types will be ignored (but can be listed).
   If several objects are sent through the pipeline only the first object will be used for creating the 
   template for the table.
   
   Make sure that all objects in the pipeline have the exact same properties (this is usually the case).
   While creating the table the script will also add two default columns. One called "id" which is a regular 
   auto counter (integer which increases with 1 for every row) and another column called "inserted_at" which 
   will have a default value of GetDate() which represents the timestamp for when the row was inserted.
   If a property is named the same as one of these default columns then a "x" will be added before the name 
   of those columns to avoid duplication. (if propertyname=id, then propertyname=xid, etc.)

   Hashtables are handled slightly different. When using hashtables the script will simply use the keys as columns.
      
   Keep in mind that properties on the objects are used. Some objects, like strings, might only have a length 
   property but what you really want to insert into the table is the value of the string.
   
   The following command would generate a table with one column called Length which would contain the length 
   of the strings (probably not what you want):

   'oink','meo' | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName myTable

   The following command is a better way to do it. Instead of piping the strings directly you should create 
   custom objects or, as in this example, hash tables. This will generate a table with a column called 'text'
   which will contain the values 'oink' and 'meo':

   @{'text'='oink'}, @{'text'='meo'} | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName myTable

   Another thing to note is that this script will only take Property and NoteProperty into consideration.
   So for example ScriptProperty and ParameterizedProperty will be ignored. 
   You can verify your objects with the Get-Member cmdlet and check the MemberType.

   Currently the script supports the following data types:

       Int32
       UInt32
       Int16
       UInt16
       Int64
       UInt64
       long
       int
       Decimal
       Single
       Double
       Byte
       SByte
       String
       DateTime
       TimeSpan
       datetime
       string
       bool
       Boolean
       Guid


   Version 1.9
   Created by John Roos 
   Email: john@roostech.se
   Web: http://blog.roostech.se
   
.EXAMPLE
   PS C:\> Get-Process | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName ProcessTable

   Creates a table called ProcessTable (if it doesnt exist) based on the result from Get-Process.
   After the table is created all the objects will be inserted into the table.
   Some properties will be ignored because the data types are not supported.
.EXAMPLE
   PS C:\> Get-Process | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName ProcessTable -ShowIgnoredPropertiesOnly

   DependentServices
   ServiceHandle
   Status
   ServicesDependedOn
   Container
   RequiredServices
   ServiceType
   Site

   This is useful for debugging. When using the parameter switch ShowIgnoredPropertiesOnly the cmdlet will not do anything in the database. 
   Instead it will show which properties that will be ignored (unsupported data types). A complete run is still simulated so this command 
   takes about the same time as if you would have inserted the objects into the table.

.EXAMPLE
   PS C:\> Get-Process | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName ProcessTable -ReportEveryXObject 20
   
   2014-12-20 11:56:12 - Rows inserted: 20 (100 rows per second)
   2014-12-20 11:56:12 - Rows inserted: 40 (250 rows per second)
   2014-12-20 11:56:12 - Rows inserted: 60 (250 rows per second)
   Inserted 68 rows into ProcessTable in 0.41 seconds (165.85 rows per second)

   This will insert objects into the database as usual with one difference: It will report back to the console every 20th object so that 
   some kind of progress is shown. The cmdlet does not know how many objects are coming down the pipeline so this only shows what has 
   happened, not how many objects that are left to process.
.EXAMPLE
   PS C:\> Get-Process | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName ProcessTable -TimeSpanType Milliseconds
   
   Inserted 68 rows into ProcessTable in 500.04 milliseconds (136 rows per second)

   The TimeSpanType parameter can be used if you want to get the time it takes to run the script in a different kind of timespan type.
   There are four alternatives: Hours, Hinutes, Seconds and Milliseconds.
.EXAMPLE
   PS C:\> Get-WmiObject -ComputerName 'localhost' -Query "select * from win32_networkadapter where NetConnectionStatus = 2" | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName wminetworkadapter

   This is where the script becomes useful. This inserts information about the network adapters in localhost into a table called wminetworkadapter.
   Replace 'localhost' with a list of servers and you quickly have a simple inventory of network adapters on your servers.
.EXAMPLE
   PS C:\> Get-Process | Write-ObjectToSQL -ConnectionString "Provider=MySQL Provider; Data Source=Server01; User ID=MyUserName; Password=MyPassword; Initial Catalog=MyDatabaseName;" -TableName MyTableName

   Experimental:
   This will insert the objects into a MySQL database. Running this multiple times will generate an error when attempting to create the table since
   the script is not able to check if it already exist (inserts will still work). 
   When inserting objects into an existing table, use the parameter '-DoNotCreateTable' to avoid these errors if you are using a custom connection string.
   
   NOTE: As this is experimental it migth not work. I got it to work with MySQL as the example above shows, but I give no guarantees :)
   NOTE: It might work with other database engines as long as you have the proper connection string but I havent tested that.
   If you want to try it out, check www.connectionstrings.com to find the connection string you need. You might also need to install ODBC or OLEDB drivers.
.INPUTS
   The script accepts an object as input from the pipeline.
.OUTPUTS
   Outputs the result from the insert queries to the console together with some statistics on how long it took and the speed (rows per second).
.NOTES

    Fixed:
                    Several new data types added
                    Now both creates the table and inserts the values
                    Fix empty property bug on subsequent objects in pipeline
                    Rewrote the property parsing completely
                    Moved repeated code to BEGIN for performance reasons
                    Generate SQL code only as a string with tablename validation
                    New parameter - Do not create table (fail if not exist)
                    New parameter - Only output "properties ignored" (easier to use when adding new data types)
                    New parameter to report progress at every X processed object - ReportEveryXObject
                    Add measure time functionality. Show time taken in seconds when showing how many rows were inserted.
                    Tidied up the code, removed obsolete comments
                    Fix proper verbose and warnings
                    Verified 'System.UInt32' compared to SQL Server data types
                    Make sure that ' is handled properly when inserting values
                    Add N'' for strings in inserts for SQL Server instead of just ''
                    Remove ' when creating table (replace "'" with "")
                    Add custom DB connection to avoid dependencies to other cmdlets
                    Fail the whole script if the first SELECT statement fails
                    Added several new data types (avoided BigInteger on purpose since it does not have proper max/min values)
                    Updated examples in the header
                    Add parameter TimespanType for selecting what to use when using Timespan. Options: Hours, Minutes, Seconds, Milliseconds
                    Add parameter sets to validate properly when using SQL Server compared to custom connection string
                    If any parameter is missing, fail the whole script (parameter grouping is needed)
                    Merge $modconnection and $connection since they are basically the same
                    Add OLEDB connection string functionality
                    Verify with MySQL and OLEDB
                    Drivers and providers for other database types can be found on NuGet.org or PowerShellGallery.com
                    Fix so that properties can be handled even if NULL
                    Add switch TryAllPropertyTypes in case someone wants to insert more than just regular properties
                    Modified the loops generating database queries so that not that much code is repeating
                    Added support for hashtables. The scripts will now insert the hash values into columns named as the hash keys.
                    Rewrote the script to use a few functions instead.
                    Added better error handling if all properties are ignored.
                    Fixed a bug where insert statements based on a string property that had the same name as a reserved property was failing
                    Added support for Timespan data type. Timespan will be converted to Ticks when stored in the table.
                    Added SQL support for datetime data type
                    Added credential parameter
                    Added support for SQL Server accounts (using the credential parameter)
                    Improved error handling to avoid getting WriteErrorException
                    Added support for System.Guid

.LINK
    SQL Server data types                http://msdn.microsoft.com/en-us/library/ms187752.aspx
    C# data types                        http://msdn.microsoft.com/en-us/library/ya5y69ds.aspx
    Built-In Types Table (C# Reference)  http://msdn.microsoft.com/en-us/library/ya5y69ds.aspx
    VB data types                        http://msdn.microsoft.com/en-us/library/47zceaw7.aspx
    VB.Net data types                    http://www.tutorialspoint.com/vb.net/vb.net_data_types.htm
#>
function Write-ObjectToSQL
{
    [CmdletBinding(DefaultParametersetName='mssql')]
    Param
    (
        # Object to base the table on and insert into the table. 
        # Piping several objects is supported, and even recommended to get the full potential of this script.
        [Parameter(Position=0,
                   Mandatory=$True,
                   ParameterSetName='othersql',
                   HelpMessage="Please specify an object to insert into the database table",
                   ValueFromPipeline=$True)]
        [Parameter(Position=0,
                   Mandatory=$True,
                   ParameterSetName='mssql',
                   HelpMessage="Please specify an object to insert into the database table",
                   ValueFromPipeline=$True)]
        [ValidateNotNullorEmpty()]
        [object]$InputObject,

        # The SQL Server instance (commonly called "server" nowadays among SQL Server geeks, or MS dudes).
        [Parameter(Mandatory=$True,
                   ParameterSetName='mssql',
                   HelpMessage="Please specify the SQL Server instance.",
                   ValueFromPipeline=$False)]
        [ValidateNotNullorEmpty()]
        [string]$Server,

        # The name of the database where the table exists (or will be created)
        [Parameter(Mandatory=$True,
                   ParameterSetName='mssql',
                   HelpMessage="Please specify a database name.",
                   ValueFromPipeline=$False)]
        [ValidateNotNullorEmpty()]
        [string]$Database = 'SlabLab',

        # Credential to use when opening the connection to the server.
        [Parameter(Mandatory=$False,
                   ParameterSetName='mssql',
                   HelpMessage="Please specify a credential.",
                   ValueFromPipeline=$False)]
        [System.Management.Automation.PSCredential]
        $Credential,

        # Connection string when not using SQL Server
        # This is experimental. See examples.
        [Parameter(Mandatory=$True,
                   ParameterSetName='othersql',
                   HelpMessage="Please specify a connection string if you do not want to use SQL Server.",
                   ValueFromPipeline=$False)]
        [ValidateNotNullorEmpty()]
        [string]$ConnectionString,

        # The name of the table where the object will be inserted into
        [Parameter(Mandatory=$True,
                   ParameterSetName='mssql',
                   HelpMessage="Please specify a table name where the object will be inserted.",
                   ValueFromPipeline=$False)]
        [Parameter(Mandatory=$True,
                   ParameterSetName='othersql',
                   HelpMessage="Please specify a table name where the object will be inserted.",
                   ValueFromPipeline=$False)]
        [ValidateNotNullorEmpty()]
        [string]$TableName,
        
        # Use this switch if you do not want the table to be created.
        # If the table does not exist an error (per object) will be thrown.
        # If large numbers of objects are piped to the script with this switch property set you will get lots of bleeding if the table does not exist.
        [Parameter(Mandatory=$False,
                   ParameterSetName='mssql',
                   ValueFromPipeline=$False)]
        [Parameter(Mandatory=$False,
                   ParameterSetName='othersql',
                   ValueFromPipeline=$False)]
        [switch]$DoNotCreateTable,

        # Use this switch to only show which properties that are ignored. When this switch is used no table will be created and no rows will be inserted.
        # However, all the logic will still be performed just like if you run the script normally so it will take the same amount of time to process.
        # This switch parameter is especially useful when troubleshooting or if you want to improve the script to handle more data types.
        [Parameter(Mandatory=$False,
                   ParameterSetName='mssql',
                   ValueFromPipeline=$False)]
        [Parameter(Mandatory=$False,
                   ParameterSetName='othersql',
                   ValueFromPipeline=$False)]
        [switch]$ShowIgnoredPropertiesOnly,
        
        # This switch forces the script to attempt to handle all property member types (AliasProperty, ScriptProperty etc.) instead of only the regular Property and NoteProperty member types.
        # Results can vary a bit when using this. The recommendation is not to use this unless you know what it does. It probably wont break anything but the results might get inconsistent.
        [Parameter(Mandatory=$False,
                   ParameterSetName='mssql',
                   ValueFromPipeline=$False)]
        [Parameter(Mandatory=$False,
                   ParameterSetName='othersql',
                   ValueFromPipeline=$False)]
        [switch]$TryAllPropertyTypes,

        # This parameter is used if you want to get informed about the progress. After every X amount of objects the script will output how many objects it has inserted into the table. 
        # Useful when inserting large amounts of objects so that you can see that there is some king of progress happening.
        [Parameter(Mandatory=$False,
                   ParameterSetName='mssql',
                   ValueFromPipeline=$False)]
        [Parameter(Mandatory=$False,
                   ParameterSetName='othersql',
                   ValueFromPipeline=$False)]
        [ValidateNotNullorEmpty()]
        [Int64]$ReportEveryXObject,

        # Type of time to report when statistics are shown in the end of the script.
        # Options are Hours, Minutes, Seconds and Milliseconds.
        [Parameter(Mandatory=$False,
                   ParameterSetName='mssql',
                   ValueFromPipeline=$False)]
        [Parameter(Mandatory=$False,
                   ParameterSetName='othersql',
                   ValueFromPipeline=$False)]
        [ValidateNotNullorEmpty()]
        [ValidateSet('Hours',
                    'Minutes',
                    'Seconds',
                    'Milliseconds')] 
        [string]$TimeSpanType
    )

    Begin
    {

        function CheckIfTableExistsSQL ()
        {
            $command = $modconnection.CreateCommand()
            $dataset = New-Object -TypeName System.Data.DataSet
            $rowCount = 0
            Write-Verbose 'Checking if the table exist.'
            
            $ErrorActionPreference = "Stop"
            
            $command.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME LIKE '$tablename'"
            $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
            $rowCount = $adapter.Fill($dataset)

            $ErrorActionPreference = $originalErrorActionPreference
                    
            if ( $rowCount -gt 0){ 
                return $True 
            }else{ 
                return $False 
            }
        }


        #### BEGIN ####

        $starttime = Get-Date
        $reportstarttime = $starttime

        if ($DoNotCreateTable){
            $tablecreated = $true
        }else{
            $tablecreated = $false
        }
        
        $rowsinserted = 0
        $rowsfailed = 0
        $datasample = [ordered]@{}
        $removeFromSample = [ordered]@{}
        $generatefirst = $true

        $numbertypes = @{
        #    PS datatype        = SQL data type
            'System.Int32'      = 'int';
            'System.UInt32'     = 'bigint';
            'UInt32'            = 'bigint';
            'System.Int16'      = 'smallint';
            'System.UInt16'     = 'int';
            'System.Int64'      = 'bigint';
            'System.UInt64'     = 'decimal(20,0)';
            'long'              = 'bigint';
            'int'               = 'int';
            'System.Decimal'    = 'decimal(20,5)';
            'System.Single'     = 'bigint';
            'System.Double'     = 'float';
            'System.Byte'       = 'tinyint';
            'System.SByte'      = 'smallint';
            'System.TimeSpan'   = 'bigint';
            'timespan'          = 'bigint';
        }
            
        $stringtypes = @{
        #   PS datatype       = SQL data type
            'System.String'   = 'nvarchar(1000)';
            'System.DateTime' = 'datetime';
            'datetime'        = 'datetime';
            'string'          = 'nvarchar(1000)';
            'bool'            = 'bit';
            'System.Boolean'  = 'bit';
            'Guid'            = 'nvarchar(40)'
            'System.Guid'     = 'nvarchar(40)'
        }

        $reservedcolumns = @{
        #   Column name   = What to add before the string (example: id becomes xid)
            'id'          = 'x';
            'inserted_at' = 'x'
        }

        if ($ReportEveryXObject){
            $whentoreport = $ReportEveryXObject
        }else{
            $whentoreport = 0
        }
        
        $reportcompare = 1
        $createtable = $true
        $doinserts = $true
        
        if ($ShowIgnoredPropertiesOnly){
            $createtable = $false
            $doinserts = $false
        }

        if ($DoNotCreateTable){
            $createtable = $false
        }

        $ignoredSamplesRemoved = $false

        ## Custom connection instead of using Invoke-Sqlcmd
        if ($ConnectionString) {
            Write-Verbose 'Not using SQL Server.'
            $constr = $ConnectionString
            
            $script:modconnection = New-Object -TypeName System.Data.OleDb.OleDbConnection
        } else {
            Write-Verbose 'Using SQL Server.'
            if ($Credential){
                $constr = "Server=$Server;Database=$Database;Trusted_Connection=False;User ID=`"$($Credential.UserName)`";Password=`"$($Credential.GetNetworkCredential().Password)`""
            }else{
                $constr = "Server=$Server;Database=$Database;Trusted_Connection=True;"
            }
            $script:modconnection = New-Object -TypeName System.Data.SqlClient.SqlConnection
        }
        
        $modconnection.ConnectionString = $constr
        
        # if we can't connect to the database its better to just break the whole script
        $script:originalErrorActionPreference = $ErrorActionPreference

        $ErrorActionPreference = "Stop"
        Write-Verbose 'Attempting to connect to the database.'
        try {
            $modconnection.Open()
            Write-Verbose 'Connection to database opened successfully.'
        }
        catch {
            Write-Warning "Could not open the connection. See error message below3."
            Write-Error $_.Exception.Message
            throw
            
        }
        $ErrorActionPreference = $originalErrorActionPreference

        # SQL Server likes [ and ] but other database engines prefer single quotes
        if ($ConnectionString){
            $quoteFirst = "'"
            $quoteLast = "'"
        }else{
            $quoteFirst = '['
            $quoteLast = ']'
        }

        $reportrowsinsertedstart = 0

        $ObjectIsHash = $false

        # are we using SQL Server (empty connection string)?
        # does a table exist with this name?
        # as long as 'DoNotCreateTable' is not used ($tablecreated is true if DoNotCreateTable is used).
        if (!$tablecreated -and !$ConnectionString) {
            if ( CheckIfTableExistsSQL ){
                if ($ShowIgnoredPropertiesOnly){
                    $tablecreated = $False
                    Write-Verbose 'Table exists in the database (simulating create table based on parameter selection)'
                }else{
                    $tablecreated = $True
                    Write-Verbose 'Table exists in the database (no creation needed)'
                }
            }else{
                $tablecreated = $False
                Write-Verbose 'Table does not exist in database (creation needed)'
            }
        }

    }
    Process
    {
             
        function GetPropertyTypes ($InputObject, $ObjectIsHash,$TryAllPropertyTypes)
        {
            $typeresult = @{}
            if ($ObjectIsHash){
                    $typetest = $InputObject.keys
                    foreach ($t in $typetest){
                        $typeresult.Add($t,$t.GetType().name)
                    }
            }else{
                if ($TryAllPropertyTypes){
                    $typetest = ($inputobject | Get-Member -MemberType Properties )
                }
                else{
                    $typetest = ($inputobject | Get-Member -MemberType Properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty'} )
                }

                foreach ($t in $typetest){
                    $typeresult.Add($t.Name,$t.Definition.Remove($t.Definition.IndexOf(' ')))
                }
            }
            return $typeresult
        }

        #### PROCESS ####

        # if this is the first object in the pipeline, start processing the starting stuff (only needed on the first object)
        if ($generatefirst){    
            Write-Verbose 'Processing first object (there is a little bit more to do on the first one to improve the speed on the rest)'

            # if the object is a hashtable it should be processed differently than a regular object.
            # check if the object is a hashtable
            if ($InputObject.GetType().Name -eq 'Hashtable'){
                $ObjectIsHash = $true
                Write-Verbose 'Input object is a hash table.'
            }

            # if the inputobject is a hashtable just take the keys instead of going through all properties like with regular objects
            if ($ObjectIsHash){
                $names = $InputObject.keys
            }else{
                # if TryAllPropertyTypes parameter is used then all types of properties will be checked
                # otherwise only Property and NoteProperty will be checked (default)
                if ($TryAllPropertyTypes){
                    $names = $InputObject | Get-Member -MemberType properties | Select-Object -ExpandProperty name 
                }else{
                    $names = $InputObject | Get-Member -MemberType properties | Where-Object {$_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty' } | Select-Object -ExpandProperty name 
                }
            }
            
            # add the object properties to the hash table
            Write-Verbose 'Starting to process properties.'
            $names | ForEach-Object {
                Write-Verbose "Adding property $_"
                $datasample.Add($_,$inputobject.$_)
            } # foreach
              
            # get all property types by parsing the output from Get-Member
            # this is one of the two ways the script will check fo the property types
            # if the property is empty this is the only way to figure out what the type is (limitation in Powershell?)
            $typeresult = @{}
            $typeresult = GetPropertyTypes($InputObject, $ObjectIsHash,$TryAllPropertyTypes)

            $generatefirst = $false

        } # if generatefirst

        Write-Verbose "Object properties inserted into the hash"
        $querystring = ''

        if (!$tablecreated){
            # table does not exist
            Write-Verbose 'Starting to generate create table query.'
            $ignoredcolumns  = 0
            $acceptedcolumns = 0
                
            # Go through all the keys in the data sample and generate the create table query
            foreach($key in $datasample.Keys){
                $prekey = ''

                foreach ($rescol in $reservedcolumns.Keys){
                    if ($key -eq $rescol){
                        $prekey = $reservedcolumns.$rescol
                    }
                }
                    
                # Two ways of getting the data type. Either via GetType or with Get-Member, parcing the output (function GetPropertyTypes performs this part)
                # First try GetType. If that doesnt work then use the output from GetPropertyTypes function. If none of them work, set the data type to empty so that it will be ignored later.
                try {
                    $datatype = $datasample.$key.GetType().ToString()
                }
                catch {
                    try {
                        $datatype = $typeresult.$key
                    }
                    catch {
                        $datatype = ''    
                    }
                }

                # go through all property types to see if they exist in the hash tables with supported data types ($numbertypes and $stringtypes)
                # if a data type doesnt exist in the hash tables then add it to ignore list ($removeFromSample)
                try {
                    if ( $numbertypes.ContainsKey( $datatype ) ){
                        $querystring += ", $quoteFirst$prekey$($key.Replace(' ','_'))$quoteLast $($numbertypes.($datatype)) NULL"
                        $acceptedcolumns++
                    }elseif ( $stringtypes.ContainsKey( $datatype ) ){
                        $columnname = $key -replace "'", ""
                        $columnname = $key -replace '"', ''
                        $querystring += ", $quoteFirst$prekey$($columnname.Replace(' ','_'))$quoteLast $($stringtypes.($datatype)) NULL"
                        $acceptedcolumns++
                    }else{
                        Write-Verbose "$key contains an unsupported data type. ($datatype)"
                        $ignoredcolumns++
                        $removeFromSample.Add($ignoredcolumns,$key)
                    }
                }
                catch {
                    Write-Verbose "$key contains an unknown data type ($datatype)"
                    $ignoredcolumns++
                    $removeFromSample.Add($ignoredcolumns,$key)
                } 
            } # foreach key in data sample

            # remove unsupported data types from sample so that they get ignored
            foreach ($remsamp in $removeFromSample.Values){
                $datasample.Remove($remsamp)
            }
            $ignoredSamplesRemoved = $true

            # did the object have any properties that we can use? Otherwise break.
            # if no supported properties were found then the query string should be empty
            if (!$querystring){
                Throw 'The input object did not contain any supported properties.'
            }

            # complete the query string depending on what kind of database engine we are working with
            # if $ConnectionString is not empty then we are probably not using SQL Server
            if ($ConnectionString){
                # remove the first comma in $querystring
                $querystring = $querystring.Substring(1)
                $createquery = "CREATE TABLE $tablename ($querystring)"
                        
            }else{
                # if we are using SQL Server then we want to have an 'id' column and a 'inserted_at' column and because of that we dont have to remove the first comma
                $createquery = "CREATE TABLE $tablename ([id] [int] IDENTITY(1,1) NOT NULL, [inserted_at] [datetime] NULL default(getdate()) $querystring)"
            }
                
            Write-Verbose "Create query: $createquery"
                
            # lets create the table in the database if $createtable is true
            # if $createtable is false its because the DoNotCreateTable or ShowIgnoredProperties parameter is used
            if ($createtable){
                $command = $modconnection.CreateCommand()
                $command.CommandText = $createquery
                $result = $command.ExecuteNonQuery()
                Write-Verbose "Table created with $acceptedcolumns columns ($ignoredcolumns ignored)"
            }else{
                Write-Verbose "Skipping table creation based on parameter selection"
                Write-Verbose "Ignored properties:"
                foreach ($remsamp in $removeFromSample.Values){
                    Write-Verbose $remsamp
                }
            }

            $tablecreated = $true
        } # if !tablecreated

        #######################################################################
        #####       TABLE SHOULD NOW EXIST - START INSERTING VALUES       #####
        #######################################################################
        
        # reset values and columns when starting to process each object in the pipeline
        $insertcolumns = ''
        $insertvalues = ''
        $strtmp = ''

        if (!$ignoredSamplesRemoved) {
            $removeFromSample = @{}
        }

        # StringBuilder is faster than strings when appending text (especially when appending a lot)
        $strBuilderColumns = New-Object System.Text.StringBuilder
        $strBuilderValues = New-Object System.Text.StringBuilder
        
        # Start to generate insert query based on every key in the data sample
        write-verbose "Starting to generate insert query"    
        foreach($key in $datasample.Keys){
            $prekey = ''

            # if the property has the same name as one of the reserved columns then rename it
            foreach ($rescol in $reservedcolumns.Keys){
                if ($key -eq $rescol){
                    $prekey = $reservedcolumns.$rescol
                }
            }
            
            # get the data type for the key    
            try {
                    $datatype = $datasample.$key.GetType().ToString()
                }
            catch {
                try {
                    $datatype = $typeresult.$key
                }
                catch {
                    Write-Warning "Could not figure out data type for $key"
                    $datatype = ''    
                }
            }

            # go through the number types and the string types array to see if the property type is supported
            # if its supported, generate the strings for the database query
            # if its not supported, add it to the $removeFromSample variable so that we can skip to check that one on the next object (for performance)
            try {
                if ( $numbertypes.ContainsKey( $datatype ) ){
                    $null = $strBuilderColumns.Append(", $prekey$($key.Replace(' ','_'))")

                    if ($($InputObject.$key)){
                        if ($datatype -eq 'timespan' -or $datatype -eq 'System.TimeSpan') {
                            Write-Verbose "Timespan found ($key). Converting to ticks."
                            $null = $strBuilderValues.Append(", $(($InputObject.$key).Ticks)")
                        }else{
                            $null = $strBuilderValues.Append(", $($InputObject.$key)")
                        }
                        
                    }else{
                        $null = $strBuilderValues.Append(", NULL")
                    }
                }elseif ( $stringtypes.ContainsKey( $datatype ) ){
                    $null = $strBuilderColumns.Append(", $quoteFirst$prekey$($key.Replace(' ','_'))$quoteLast")
                    $strtmp = $InputObject.$key -replace "'", "''"
                    if ($ConnectionString){ 
                        $null = $strBuilderValues.Append(", '$strtmp'")
                    }else{
                        $null = $strBuilderValues.Append(", N'$strtmp'")
                    }
                }else{
                    if (!$ignoredSamplesRemoved) {
                        write-verbose "Ignoring (No data type match): $key ($datatype)"
                        $ignoredcolumns++
                        $removeFromSample.Add($ignoredcolumns,$key)
                    }else{
                        Write-Warning 'Ignored columns does not match'
                    }
                }
            }
            catch {
                    write-verbose "Ignoring (No data type match): $key ($datatype)"
            }
        } # foreach key

        # did the input object contain any supported properties? If not, break the script
        # if no supported properties were found then either $strBuilderColumns or $strBuilderValues (or probably both) will be empty
        if ( !$strBuilderColumns.ToString() ){
            Throw 'The input object did not contain any supported properties. Unable to generate columns for insert.'
        }
        if ( !$strBuilderValues.ToString() ){
            Throw 'The input object did not contain any supported properties. Unable to generate values for insert.'
        }
            
        # remove the first two characters which should be a space and a comma in both strings
        # (the comma was added when going through the supported number types and string types)
        $insertcolumns = $strBuilderColumns.ToString().Remove(0,2)
        $insertvalues = $strBuilderValues.ToString().Remove(0,2)
            

        # complete the insert statement
        if ($ConnectionString){
            $insertstring = "INSERT INTO $tablename ( $insertcolumns ) VALUES ( $insertvalues )"
        }else{
            $insertstring = "INSERT INTO $tablename ( $insertcolumns ) VALUES ( $insertvalues )"
        }

        Write-Verbose "Insert query generated: $insertstring"

        # now lets try to do the insert in the database
        if ($doinserts) {
            try {
                $command = $modconnection.CreateCommand()
                $command.CommandText = $insertstring
                $insertResult = $command.ExecuteNonQuery()
                Write-Verbose "Row inserted"
                $rowsinserted++
            } catch {
                Write-Error $_.Exception.Message
                Write-Warning "Could not insert row into database. See SQL query error message above."
                $rowsfailed++
            }
        }else{
            Write-Verbose "Skipping insert based on parameter selection"
        }

        <# If its the first object in the pipeline we are working with then its the first row we are inserting.
        If its the first row, make sure that we are removing all ignored object properties from datasample.
        This makes the scrips a bit faster for all the objects coming in later since we only have to go through the properties that we expect is supported. #>
        if (!$ignoredSamplesRemoved){
            if ($rowsinserted -eq 0){
                foreach ($remsamp in $removeFromSample.Values){
                    $datasample.Remove($remsamp)
                }
            }
        }
        
        # if the ReportEveryXObject parameter is used and $reportcompare has the same value, then we want to output some fancy text to show the progress.
        # if not, just increase $reportcompare with one
        if ($whentoreport -eq $reportcompare) {
            $reportendtime = Get-Date
            $reporttimespent = [math]::round((NEW-TIMESPAN –Start $reportstarttime –End $reportendtime).TotalSeconds,2)
                
            Write-Host "$((get-date -Format s).Replace('T',' ')) - Rows inserted: $rowsinserted ($([math]::round( ($rowsinserted-$reportrowsinsertedstart)/$reporttimespent ,2)) rows per second)"

            $reportrowsinsertedstart = $rowsinserted

            # reset $reportcompare and $reportstarttime so that we can use them again for the next time we want to report progress.
            $reportcompare = 1
            $reportstarttime = Get-Date
        }else{
            $reportcompare++
        }
    }
    End
    {
        # now we are done. Close the connection to the database.
        $modconnection.close()

        # prepare the output
        $timetypestring = 'seconds'
        $endtime = Get-Date
        $timespentseconds = [math]::round((NEW-TIMESPAN –Start $starttime –End $endtime).TotalSeconds,2)
        
        # if timespantype is used, we use that time type. Otherwise we use seconds.
        if ($TimeSpanType){
            $TimeSpanTypeTotal = "Total$TimeSpanType"
            $timespent = [math]::round((NEW-TIMESPAN –Start $starttime –End $endtime).$TimeSpanTypeTotal,2)
        }else{
            $timespent =  $timespentseconds
            $TimeSpanType = 'seconds'
        }
        
        # calculate how many rows were inserted per second
        $rowspersecond = [math]::round(($rowsinserted/$timespentseconds),2)

        # if the parameter ShowIgnoredPropertiesOnly was used we want to show the ignored properties
        # otherwise we just write the regular output to the console
        if ($ShowIgnoredPropertiesOnly){
            $ignoredobjects = @()

            foreach ($remsamp in $removeFromSample.Values)
            {
                $ignoredBastard = New-Object -TypeName PSObject
                $ignoredBastard | Add-Member -Type NoteProperty -Name 'IgnoredProperty' -Value $remsamp
                $ignoredBastard | Add-Member -Type NoteProperty -Name 'TypeName' -Value $typeresult.$remsamp
                $ignoredobjects += $ignoredBastard
            }

            Write-Verbose 'Returning ignored properties:'
            $ignoredobjects
        }else{
            
            # write how many rows we inserted to the console
            if ($rowsinserted -ne 1) {
                Write-Host "Inserted $rowsinserted rows into $tablename in $timespent $($TimeSpanType.ToLower()) ($rowspersecond rows per second)"
                
            }else{
                Write-Host "Inserted $rowsinserted row into $tablename in $timespent $($TimeSpanType.ToLower()) ($rowspersecond rows per second)"
            }
            
            # write how many rows that failed to the console
            if ($rowsfailed -gt 0){
                if ($rowsfailed -gt 1){
                    Write-Warning "$rowsfailed rows failed"
                }else{
                    Write-Warning "$rowsfailed row failed"
                }
            }
        } # if ShowIgnoredPropertiesOnly
    }
}
