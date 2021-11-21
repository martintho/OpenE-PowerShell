[xml]$Credentials = Get-Content -Path "$PSScriptRoot\private\Credentials.xml"

$Username = Read-Host -Prompt 'Enter the username of the user with API priviliges'
$Hostname = Read-Host -Prompt 'Enter hostname (eg: https://etjanster.kommun.se)'
$Password = Read-Host -Prompt 'Enter password for the user with API priviliges'

$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force 
$SecureText = $SecurePassword | ConvertFrom-SecureString

[string]$Credentials.Credentials.Hostname = $Hostname
[string]$Credentials.Credentials.Username = $Username
[string]$Credentials.Credentials.Password = $SecureText

$Credentials.Save("$PSScriptRoot\private\Credentials.xml")