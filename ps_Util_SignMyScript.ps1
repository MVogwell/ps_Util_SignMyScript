Param(
	[Parameter(Mandatory=$False)][string]$ScriptPath,
	[Parameter(Mandatory=$False)][switch]$NoPauseAtEnd
)

write-host ""
write-host ""

write-host "SignMyScript.ps1 -- Signs a script using a local CodeSigning signature" -fore green
write-host "MVogwell - June 2016"
write-host ""

if($ScriptPath.length -lt 1) {
	$ScriptPath = read-host "Enter the full path to your script"
}

# Replace character " in the path
$ScriptPath = $ScriptPath.replace("""","")

$acert =(dir Cert:\CurrentUser\My -CodeSigningCert)[0]
Set-AuthenticodeSignature $ScriptPath -Certificate $acert


if ($NoPauseAtEnd -eq $False) {
	write-host ""
	write-host "Press any key to finish" -fore green

	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
write-host "`n`n"