# OpenE-PowerShell
PowerShell library made for easy integration with the public open-source platform Open ePlatform (http://oeplatform.org/)

# Installation
Fork or clone this repository

Run the script Add-Credentials.ps1 in the terminal of your choice either by running .\Add-Credentials.ps1 in a PowerShell terminal or powershell ./Add-Credentials.ps1 in a non-PowerShell terminal.

To confirm that it's working you can run the example files. The script Get-ErrandXML will use basic authentication with the credentials you entered when you ran Add-Credentials

# Note
This library includes all of the API's available to customers of Open ePlatform.
If you are running a private cloud installation of Open ePlatform chances are you do not have access to all of the API's.
If you are running a public cloud installation managed by Nordic Peak then consult with them regarding any missing API.

Teis example ("Get-ErrandXML-Teis.ps1") requires the PowerShell Adapter and Teis integration platform version 3.2 or higher

Tested with PowerShell 5.x
Compatible with PowerShell version 3.0+
