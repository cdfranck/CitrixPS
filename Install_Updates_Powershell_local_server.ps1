# Set teh Windows Update Service to "Disabled"
sc.exe config wuauserv start= auto

# Display hte Status of the Service
sc.exe query wuauserv

# stop the service, in case it is running.
net start wuauserv

# display the status of the service.
sc.exe query wuauserv

# double check it's really disabled - start value should be 0x4
reg.exe Query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start

#Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name AUOptions -Value 3

#Import-Module PSWindowsUpdate
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
Get-WUList -MicrosoftUpdate
Get-WUInstall
Install-WindowsUpdate -MicrosoftUpdate -IgnoreUserInput -AcceptAll -IgnoreReboot -Verbose