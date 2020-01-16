# Read in a list of server or device names
$Serverfile = get-content 'C:\Temp\Servers.txt'

# Performs the copy for each listed server
foreach ($server in $Serverfile){

  #Folder and contents are copied and will over-wwrite existing files, in use files may be skipped - if you want all output remove the ErrorAction and add verbose
   Copy-Item "\\nas-share\Source\Folder" "\\$server\c$\Destination" -Recurse -Force -ErrorAction SilentlyContinue

   Write-Host $server is done!
}

# Result will be \\SERVER\C$\Destination\Folder
