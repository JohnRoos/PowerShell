# import all parameter validation functions
foreach ($function in (Get-ChildItem "$PSScriptRoot\Get-ParamHelp.ps1"))
{
	$ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($function))), $null, $null)
}
