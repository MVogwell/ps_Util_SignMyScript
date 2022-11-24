# ps_Util_SignMyScript

I use this script to digitally sign powershell script (.ps1 etc) files for networks that have enabled the execution policy "AllSigned" on machines.

This script takes the first available "publishing" certificate in the personal certificate vault and attempts to sign the script.

## Creating a CodeSigning certificate in Active Directory Certificate Services for use by ps_Util_SignMyScript

* From your user account loggon onto the domain go to https://<address of the AD Cert Services Server fqdn>/certsrv/
* Menu: Request a certificate > Advanced Certificate Request > Create and submit a request to this CA then Yes to the popup message
* Certificate template: Code Signing
* Key Size: 2048
* Friendly name: Add your name and the date
* Submit and wait, response Yes to the popup
* Select "install certificate"
* Open MMC.exe > File > Add/Remove Snapin > Select the certificate snapin (for the user)
* Navigate to Personal > Certificates
* Export the newly created certificate (look for the friendly name) to pst with a temporary password
*  Logon to a DC with Admin rights and open Group Policy Management
* Edit a policy that will cover all the machines that scripts could be run on and navigate to: Computer Configuration > Windows Settings > Security Settings > Public Key Policies > Trusted Publishers 
* Import pfx certificate


## Examples

* .\ps_Util_SignMyScript.ps1
	* This will ask for the path to the script file

* .\ps_Util_SignMyScript.ps1 -ScriptPath <path to the script to be signed>
	* This will go through and sign the script specified under the ScriptPath argument and then pause at the end

* .\ps_Util_SignMyScript.ps1 -ScriptPath <path to the script to be signed> -NoPauseAtEnd
	* With the NoPauseAtEnd switch specified the script will NOT pause at the end

## Setup

To enable this script to sign other scripts it itself has to first be signed. To do this;

1) Create a CodeSigning certificate as per the details above
2) Open powershell (not elevated but as your normal user account as it is this account that has certificate
3) Run the command: $ScriptPath = "here enter the path you have saved ps_Util_SignMyScript.ps1 to"
4) Run the command: $acert =(dir Cert:\CurrentUser\My -CodeSigningCert)[0]
5) Run the command: Set-AuthenticodeSignature $ScriptPath -Certificate $acert

