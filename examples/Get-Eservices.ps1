Import-Module -Name "$PSScriptRoot\..\modules\OpenE.psm1"

$Eservices = Get-Eservices

foreach ($Eservice in $Eservices.Flows) {
    $Eservice.Flow
}