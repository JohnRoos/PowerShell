$sources = 'server1', 'server2', 'server3'
$targets = 'server4', 'server5'
$logpath = 'C:\Ping_logs\'
 
$pingscript = { 
    while ($true) {
        $pingdate = Get-Date -Format u
        $logpath = "$($args[2])$($args[0])_$($args[1])_$(Get-Date -f yyyy-MM-dd).log"
        Try {
            Test-Connection -Count 1 -ErrorAction Stop -Source $($args[0]) -ComputerName $($args[1]) `
                | Select-Object {$pingdate}, __SERVER, Address, ResponseTime `
                | ConvertTo-Csv `
                | Select-Object -Skip 2 `
                | Out-File -FilePath $logpath -Append
        } catch {
            $responseprops = [ordered]@{
                'datetime' = $pingdate
                '__SERVER' = $args[0]
                'Address' = $args[1]
                'ResponseTime' = '9999'
            }
            $response  = New-Object psobject -Property $responseprops
            ConvertTo-Csv -InputObject $response `
                | Select-Object -Skip 2 `
                | Out-File -FilePath $logpath -Append
        }
        Start-Sleep -Seconds 1
    } 
}
 
foreach ($source in $sources){
    foreach ($target in $targets){
        Start-Job -Name "$source ping $target" -ScriptBlock $pingscript -ArgumentList $source, $target, $logpath
    }
}