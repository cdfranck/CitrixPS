<#
.SYNOPSIS
        Script will pull information about your Hypervisor Connection so you can update the SSL Thumprint after vCenter certificates are changed causing your Hosting Connection to fail with certificate errors.
.DESCRIPTION
        This script was written for XenApp 1912 to update the SSL Thumbprint after a vCenter certificate change that causes the hosting connection in Studio to fail with certificate errors 
        and removes the ability to power manage your VDAs. It will pull information from your Delivery Controller (Site Database) for the Hosting Connection and from Certificate Manager to accomplish the modifications. 
        You must install the new vCenter certificates to all Delivery Controllers prior to running the script. 
        You will need to know the password for your hosting connection user to make these modifications.
.EXAMPLE
        ./Update-Host-Connection-vSphere-Cert-Thumbprint.ps1
.NOTES 
        Written by Candi Franck 
        Updated on June 1st, 2023
.COMPONENT
        Script requires that the Citrix PowerShell Snap-ins are loaded on the device running the action.
        You should run this script from one of your Delivery Controllers.
.LINK 
        https://support.citrix.com/article/CTX224551/delivery-controller-cannot-contact-vcenter-server-after-certificate-update-on-vcenter
#>

# ----------------------- Pre-script steps -----------------------
Write-Host "You must install the new vCenter certificates first."
Write-Host "1) Open IE as an admin and go to the vCenter URL."
Write-Host "2) Click 'Download trusted root CA certificates' on the lower right'."
Write-Host "3) Save the windows cert files where you can get to them."
Write-Host "4) Install the certs to the local machine in 'Trusted Root Certification Authorities' AND 'Trusted People'."
Write-Host "5) Open IE as an admin and go to the vCenter URL, click the lock icon in the address bar (cert should be trusted now)."
Write-Host "6) View the details and install the certificate in 'Trusted Root Certification Authorities' AND 'Trusted People' AND 'Personal'."
Write-Host "Please make sure any OLD certificates are removed and the one with the desired thumbprint is the only one with that CN in 'Personal'."
Write-Host "If all certificates are installed as outlined above; Please " -NoNewLine
Pause

# Load Citrix PowerShell Cmdlets (Run from one of your Delivery Controllers)
Add-PSSnapin Citrix*

# Change to the Hypervisor Connections repository
Set-Location XDHyp:\Connections

# List your Hypervisor Connections
Get-ChildItem | select FullPath
$numConn = (Get-ChildItem | select FullPath).Count

# Set the variable for the connection you need to edit
if ($numConn -eq 1) {$xdHyPath = Get-ChildItem | Select-Object -ExpandProperty FullPath} 
    else {Write-Host "You have more than one connection defined. " -NoNewLine
    $xdHyPath = Read-Host "What Hypervisor connection path would you like to edit? (Format is XDHyp:\Connections\YOURCONNECTION)"}

# Create the Hypervisor Address variable
$xdHyUrl = Get-Item -LiteralPath $xdHyPath | Select-Object -ExpandProperty HypervisorAddress 
# Strip the beginning of the url to create a search variable for the cert
$xdHySub = $xdHyUrl.TrimStart("https://")

# Get the Hypervisor Username specified in your connection
$xdHyUsr = Get-Item -LiteralPath $xdHyPath | Select-Object -ExpandProperty Username

# Capture credentials
$creds = Get-Credential -UserName $xdHyUsr -Message "Enter the password for your Hypervisor Connection user:"

# Create the NEW SSL thumbprint variable -- this will pull from the Personal Certificate Store that you installed the new cert into earlier (step 6)
$Thumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "$xdHySub"}).Thumbprint
$newCert = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "$xdHySub"} | Select-Object PSParentPath,Subject)


# Fix the ssl thumbprint on the hosting connection
Write-Host "The XD Hypervisor connection that will be updated is: $xdHyPath"
Write-Host "Your Hypervisor URL Address is: $xdHyUrl"
Write-Host "The new certificate is: $newCert"
Write-Host "The new certificate thumbprint is: $Thumbprint"
Write-host "If you want to continue with modifying your Hypervisor Connection with the listed variables; Please " -NoNewLine
Pause
Set-Item -LiteralPath $xdHyPath -Username $creds.Username -SecurePassword $creds.Password -SslThumbprint $Thumbprint -HypervisorAddress $xdHyUrl -Verbose

# Validation
Write-Host "Check the STATE value -- it should be ON"
Get-BrokerHypervisorConnection

Exit