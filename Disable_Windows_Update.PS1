# Set teh Windows Update Service to "Disabled"
sc.exe config wuauserv start= disabled

# Display hte Status of the Service
sc.exe query wuauserv

# stop the service, in case it is running.
sc.exe stop wuauserv

# display the status of the service.
sc.exe query wuauserv

# double check it's really disabled - start value should be 0x4
reg.exe Query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start

#Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name AUOptions -Value 3