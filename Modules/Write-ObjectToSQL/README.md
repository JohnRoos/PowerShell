# Write-ObjectToSQL
This Powershell cmdlet inserts properties of an object into a table. The table will be created if it doesnt exist. The cmdlet accepts object from the pipeline which makes this very useful when you want to easily save the output from a script in a database.<br>
More information can be found in this blog post: http://blog.roostech.se/2015/02/powershell-write-object-to-sql.html

## Description
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

```powershell
'oink','meo' | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName myTable
```

The following command is a better way to do it. Instead of piping the strings directly you should create 
custom objects or, as in this example, hash tables. This will generate a table with a column called 'text'
which will contain the values 'oink' and 'meo':

```powershell
@{'text'='oink'}, @{'text'='meo'} | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName myTable
```

Another thing to note is that this script will only take Property and NoteProperty into consideration.
So for example ScriptProperty and ParameterizedProperty will be ignored. 
You can verify your objects with the Get-Member cmdlet and check the MemberType.

Currently the script supports the following data types:

* Int32
* UInt32
* Int16
* UInt16
* Int64
* UInt64
* long
* int
* Decimal
* Single
* Double
* Byte
* SByte
* String
* DateTime
* TimeSpan
* datetime
* string
* bool
* Boolean


## Example 1
```powershell
PS C:\> Get-Process | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName ProcessTable
```

Creates a table called ProcessTable (if it doesnt exist) based on the result from Get-Process.
After the table is created all the objects will be inserted into the table.
Some properties will be ignored because the data types are not supported.

## Example 2
```powershell
PS C:\> Get-Process | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName ProcessTable -ShowIgnoredPropertiesOnly
```
```text
DependentServices
ServiceHandle
Status
ServicesDependedOn
Container
RequiredServices
ServiceType
Site
```

This is useful for debugging. When using the parameter switch ShowIgnoredPropertiesOnly the cmdlet will not do anything in the database.
Instead it will show which properties that will be ignored (unsupported data types). A complete run is still simulated so this command 
takes about the same time as if you would have inserted the objects into the table.

## Example 3
```powershell
PS C:\> Get-Process | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName ProcessTable -ReportEveryXObject 20
```
```text
2014-12-20 11:56:12 - Rows inserted: 20 (100 rows per second)
2014-12-20 11:56:12 - Rows inserted: 40 (250 rows per second)
2014-12-20 11:56:12 - Rows inserted: 60 (250 rows per second)
Inserted 68 rows into ProcessTable in 0.41 seconds (165.85 rows per second)
```
This will insert objects into the database as usual with one difference: It will report back to the console every 20th object so that some kind of progress is shown. The cmdlet does not know how many objects are coming down the pipeline so this only shows what has happened, not how many objects that are left to process.
## Example 4
```powershell
PS C:\> Get-Process | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName ProcessTable -TimeSpanType Milliseconds
```
```text
Inserted 68 rows into ProcessTable in 500.04 milliseconds (136 rows per second)
```
The TimeSpanType parameter can be used if you want to get the time it takes to run the script in a different kind of timespan type.
There are four alternatives: Hours, Hinutes, Seconds and Milliseconds.
## Example 5
```powershell
PS C:\> Get-WmiObject -ComputerName 'localhost' -Query "select * from win32_networkadapter where NetConnectionStatus = 2" | Write-ObjectToSQL -Server localhost\sqlexpress -Database MyDB -TableName wminetworkadapter
```
This is where the script becomes useful. This inserts information about the network adapters in localhost into a table called wminetworkadapter. 
Replace 'localhost' with a list of servers and you quickly have a simple inventory of network adapters on your servers.
## Example 6
```powershell
PS C:\> Get-Process | Write-ObjectToSQL -ConnectionString "Provider=MySQL Provider; Data Source=Server01; User ID=MyUserName; Password=MyPassword; Initial Catalog=MyDatabaseName;" -TableName MyTableName
```
Experimental:
This will insert the objects into a MySQL database. Running this multiple times will generate an error when attempting to create the table since the script is not able to check if it already exist (inserts will still work). 
When inserting objects into an existing table, use the parameter '-DoNotCreateTable' to avoid these errors if you are using a custom connection string.
   
NOTE: As this is experimental it migth not work. I got it to work with MySQL as the example above shows, but I give no guarantees :)

NOTE: It might work with other database engines as long as you have the proper connection string but I havent tested that.
If you want to try it out, check www.connectionstrings.com to find the connection string you need. You might also need to install ODBC or OLEDB drivers.

## Inputs
The script accepts an object as input from the pipeline.
## Outputs
Outputs the result from the insert queries to the console together with some statistics on how long it took and the speed (rows per second).

## Future improvements

* Add support for Timespan data type
* Add SQL support for datetime data type
* Add credential parameter
* Add support for SQL Server accounts
                    
## Fixed
* Several new data types added
* Now both creates the table and inserts the values
* Fix empty property bug on subsequent objects in pipeline
* Rewrote the property parsing completely
* Moved repeated code to BEGIN for performance reasons
* Generate SQL code only as a string with tablename validation
* New parameter - Do not create table (fail if not exist)
* New parameter - Only output "properties ignored" (easier to use when adding new data types)
* New parameter to report progress at every X processed object - ReportEveryXObject
* Add measure time functionality. Show time taken in seconds when showing how many rows were inserted.
* Tidied up the code, removed obsolete comments
* Fix proper verbose and warnings
* Verified 'System.UInt32' compared to SQL Server data types
* Make sure that ' is handled properly when inserting values
* Add N'' for strings in inserts for SQL Server instead of just ''
* Remove ' when creating table (replace "'" with "")
* Add custom DB connection to avoid dependencies to other cmdlets
* Fail the whole script if the first SELECT statement fails
* Added several new data types (avoided BigInteger on purpose since it does not have proper max/min values)
* Updated examples in the header
* Add parameter TimespanType for selecting what to use when using Timespan. Options: Hours, Minutes, Seconds, Milliseconds
* Add parameter sets to validate properly when using SQL Server compared to custom connection string
* If any parameter is missing, fail the whole script (parameter grouping is needed)
* Merge $modconnection and $connection since they are basically the same
* Add OLEDB connection string functionality
* Verify with MySQL and OLEDB
* Fix so that properties can be handled even if NULL
* Add switch TryAllPropertyTypes in case someone wants to insert more than just regular properties
* Modified the loops generating database queries so that not that much code is repeating
* Added support for hashtables. The scripts will now insert the hash values into columns named as the hash keys.
* Rewrote the script to use a few functions instead.
* Added better error handling if all properties are ignored.
* Fixed a bug where insert statements based on a string property that had the same name as a reserved property was failing.

# Links

SQL Server data types: http://msdn.microsoft.com/en-us/library/ms187752.aspx

C# data types: http://msdn.microsoft.com/en-us/library/ya5y69ds.aspx

Built-In Types Table (C# Reference): http://msdn.microsoft.com/en-us/library/ya5y69ds.aspx

VB data types: http://msdn.microsoft.com/en-us/library/47zceaw7.aspx

VB.Net data types: http://www.tutorialspoint.com/vb.net/vb.net_data_types.htm

