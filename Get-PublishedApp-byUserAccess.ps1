# add Snapin for Citrix.
﻿Add-PSSnapin Citrix*

# Search for published apps by user or global group with access
Get-BrokerApplication -MaxRecordCount 1000 | where {$_.AssociatedUserNames -eq 'DOMAIN\Global_Group_Name'} | Select BrowserName,AdminFolderName,DesktopGroupName
