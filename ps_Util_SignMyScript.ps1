#Requires -Version 5.1
<#
    .SYNOPSIS
    This PowerShell v5.1 (and above) script can be used to sign other PowerShell scripts with a code signing / publishing certificate.

    .DESCRIPTION
    For environments where the PowerShell environment uses the execution policy "AllSigned", or you want to share signed scripts with other environments, this script will sign a script with the first available CodeSigning/Publishing certificate.

    .OUTPUTS
    Once run, the targetted script will be signed with your CodeSigning/Publishing certificate.

    .PARAMETER ScriptPath
    Enter the full path of the script you want to sign in this parameter.

    .PARAMETER NoPauseAtEnd
    Optional. If you don't want this script to pause once it's completed then add this parameter.


    .EXAMPLE
    .\ps_Util_SignMyScript.ps1 -ScriptPath "C:\Temp\MyScriptToSign.ps1"

    This would sign the script "C:\Temp\MyScriptToSign.ps1" with the first available CodeSigning/Publishing certificate.

    .NOTES
    Version history:
        1.0 - Initial tested release
        1.1 - Updated to remove evil Write-Host and added error handling

#>

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$False)][string]$ScriptPath,
	[Parameter(Mandatory=$False)][switch]$NoPauseAtEnd
)

$ErrorActionPreference = "Stop"

Write-Output "`n`nSignMyScript.ps1 -- Signs a script using a local CodeSigning signature" -fore green
Write-Output "MVogwell - November - v1.1 `n"

# Get the script path if it hasn't been provided by the startup params
if($ScriptPath.length -lt 1) {
	$ScriptPath = Read-Host "`tEnter the full path to your script"
}

# Replace character " in the path
$ScriptPath = $ScriptPath.replace("""","")

# Get the code signing certificate from the currentuser store
try {
	Write-Output "*** Searching for certificate"

	$acert =(Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert)[0]

	if ($null -eq $acert) {
		throw "Awkward! The script cannot find a code signing certificate in the CURRENTUSER certificate store"
	}

	Write-Output "`n+++ Certificate found `n"
}
catch {
	$sErrMsg = ("`t--- Error: " + $Error[0].Exception.Message + "`n")
	throw $sErrMsg
}

# Sign the script with the code signing certificate
try {
	Write-Output "*** Signing the script"

	Set-AuthenticodeSignature $ScriptPath -Certificate $acert

	Write-Output "`t+++ Success `n"
}
catch {
	$sErrMsg = ("`t--- Error: " + $Error[0].Exception.Message + "`n")
	throw $sErrMsg
}


if ($NoPauseAtEnd -eq $False) {
	Write-Output "`n*** Press any key to finish" -fore green

	$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Output "`n*** Finished ***`n`n"