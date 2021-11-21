Import-Module -Name "$PSScriptRoot\..\modules\OpenE.psm1"

$Errand = Get-ErrandXML -FlowInstanceId "3618"

$Errand.InnerXML

$Errand.FlowInstance.Values

$Errand.FlowInstance.Header.FlowInstanceId
