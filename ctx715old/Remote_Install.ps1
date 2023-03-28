$servers = get-content “ServersList.txt”
Foreach ($server in $servers){
Write-Host -BackgroundColor white -ForegroundColor blue "Updating $server"
Invoke-Command -ComputerName $server -ScriptBlock -AsJob {(& cmd.exe /c " Path to Powershell scrip/CMD File/MSI/or ARP Entry")}
}
