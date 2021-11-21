Import-Module -Name "$PSScriptRoot\..\modules\OpenE.psm1"
Import-Module -Name "$env:TEIS_PSMODULE_HOME\TeisPS.psm1"
Try {
    # Open Teis connection
    Open-Teis

    $Errand = Get-ErrandXML -FlowInstanceId "1234"
    
    $Errand.InnerXML
    
    $Errand.FlowInstance.Values

    # Write a log message to the service log
    Write-TeisServiceLog 'RL_COMPLETE' "Successfully retrieved errand $($Errand.FlowInstance.Header.FlowInstanceId)"
    # Set the status of the Teis task to Complete
    Set-TeisTaskStatus 'SS_COMPLETE'

    # Close Teis connection
	Close-Teis
}
Catch {
    # Set the status of the Teis task to Error
	Set-TeisTaskStatus 'SS_ERROR'
    # Write a log message to the service log
    Write-TeisServiceLog 'RL_ERROR' "Failed to get errand!"
    # Write a log message to the event log
    Write-TeisEventlog 'RE_ERROR' "$Error"

    # Close Teis connection
	Close-Teis
}