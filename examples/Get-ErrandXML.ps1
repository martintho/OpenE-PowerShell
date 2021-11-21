Import-Module -Name "$PSScriptRoot\..\modules\OpenE.psm1"

$Errands = Get-ErrandXML -FlowInstanceId "1234"

foreach ($Errand in $Errands) {
    $Errand.InnerXML

    $Errand.FlowInstance.Values
}