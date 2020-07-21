
#Example of Scriptblock - "msiexec.exe /i FILENAME.MSI /QN
# "FILE.CMD"

$servers = get-content "PATH_TO_SERVER_LIST"

Foreach ($server in $servers){
Write-Host -BackgroundColor white -ForegroundColor blue "Updating $server"
Invoke-Command -ComputerName $server -ScriptBlock {(& cmd.exe /c "PATH_TO_INSTALL_FILE")}
}
