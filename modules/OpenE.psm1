Add-Type -AssemblyName System.Web
[Net.ServicePointManager]::SecurityProtocol = "TLS12"

[xml]$Credentials = Get-Content -Path "$PSScriptRoot\..\private\Credentials.xml"

$Hostname = $Credentials.Credentials.Hostname
$Username = $Credentials.Credentials.Username
$Password = $Credentials.Credentials.Password | ConvertTo-SecureString
$Password = [System.Net.NetworkCredential]::new("", $Password).Password

function New-BasicAuthenticationHeader {
    $base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))

    return "Basic $($base64)"
}

function Get-Eservices {
    $ApiBase = "/api/v1/getflows/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

function Get-Categories {
    $ApiBase = "/api/v1/getcategories/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString
    
    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

function Get-EservicesByCategory {
    param (
        [Parameter(Mandatory=$true)]
        [string]$CategoryID
    )

    $ApiBase = "/api/v1/getflowsincategory/$($CategoryID)/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

function Get-Eservice {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VersionID
    )

    $ApiBase = "/api/v1/getflow/$($VersionID)/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

function Get-EserviceByFamilyID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FamilyID
    )

    $ApiBase = "/api/v1/getflowbyfamily/$($FamilyID)/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

function Get-PopularEservices {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Limit
    )

    $ApiBase = "/api/v1/getpopularflows/$($Limit)/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

function Search-EservicesByQuery {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SearchQuery
    )

    $ApiBase = "/api/v1/search/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    $QueryParamters.Add('q',$SearchQuery)
    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

function Get-ErrandsByVersion {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VersionID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/instanceapi/getinstances/$($VersionID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-ErrandsByFamilyID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FamilyID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/instanceapi/getinstances/family/$($FamilyID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-ErrandsByFamilyIDAndStatus {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FamilyID,
        [Parameter(Mandatory=$true)]
        [string]$Status,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $Status = [System.Web.HttpUtility]::UrlEncode($Status)

    $ApiBase = "/api/instanceapi/getinstances/family/$($FamilyID)/$($Status)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-ErrandsByVersionIDAndStatus {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VersionID,
        [Parameter(Mandatory=$true)]
        [string]$Status,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $Status = [System.Web.HttpUtility]::UrlEncode($Status)

    $ApiBase = "/api/instanceapi/getinstances/$($VersionID)/$($Status)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-ErrandsByAttribute {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AttributeName,
        [Parameter(Mandatory=$true)]
        [string]$Value,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $AttributeName = [System.Web.HttpUtility]::UrlEncode($AttributeName)
    $Value = [System.Web.HttpUtility]::UrlEncode($Value)

    $ApiBase = "/api/instanceapi/getinstancesbyattribute"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    $QueryParamters.Add('attribute',$AttributeName)
    $QueryParamters.Add('value',$Value)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri "" -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-ErrandXML {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FlowInstanceID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/instanceapi/getinstance/$($FlowInstanceID)/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-ErrandPDF {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FlowInstanceID,
        [Parameter(Mandatory=$true)]
        [string]$Filename,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/instanceapi/getinstance/$($FlowInstanceID)/pdf"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -OutFile $filename -Headers $Headers
}

function Get-Status {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FlowInstanceID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/instanceapi/getstatus/$($FlowInstanceID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-Events {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FlowInstanceID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate,
        [Parameter(Mandatory=$false)]
        [string]$FromEventID,
        [Parameter(Mandatory=$false)]
        [string]$ToEventID
    )

    $ApiBase = "/api/instanceapi/getevents/$($FlowInstanceID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }
    if ($FromEventID) {
        $QueryParamters.Add('fromEventID',$FromEventID)
    }
    if ($ToEventID) {
        $QueryParamters.Add('toEventID',$ToEventID)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-EventsByVersionID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VersionID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate,
        [Parameter(Mandatory=$false)]
        [string]$FromEventID,
        [Parameter(Mandatory=$false)]
        [string]$ToEventID
    )

    $ApiBase = "/api/instanceapi/getevents/flow/$($VersionID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }
    if ($FromEventID) {
        $QueryParamters.Add('fromEventID',$FromEventID)
    }
    if ($ToEventID) {
        $QueryParamters.Add('toEventID',$ToEventID)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-EventsByFamilyID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FamilyID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate,
        [Parameter(Mandatory=$false)]
        [string]$FromEventID,
        [Parameter(Mandatory=$false)]
        [string]$ToEventID
    )

    $ApiBase = "/api/instanceapi/getevents/family/$($FamilyID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }
    if ($FromEventID) {
        $QueryParamters.Add('fromEventID',$FromEventID)
    }
    if ($ToEventID) {
        $QueryParamters.Add('toEventID',$ToEventID)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-MessagesByVersionID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VersionID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/messageapi/getmessages/$($VersionID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-MessagesByFamilyID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FamilyID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/messageapi/getmessages/family/$($FamilyID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$MessageID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/messageapi/getmessage/$($MessageID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-Attachment {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AttachmentID,
        [Parameter(Mandatory=$true)]
        [string]$Filename,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/messageapi/getattachment/$($AttachmentID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -OutFile $filename -Headers $Headers
}

function Get-StatisticsByDate {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FromDate,
        [Parameter(Mandatory=$true)]
        [string]$ToDate
    )

    $ApiBase = "/api/flowinstancestatistics/getflowinstances/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    $QueryParamters.Add('fromdate',$FromDate)
    $QueryParamters.Add('todate',$ToDate)

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-Statistics {
    $ApiBase = "/api/flowinstancestatistics/getflows/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-CulledErrand {
    param (
        [Parameter(Mandatory=$false)]
        [string]$FlowInstanceID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate,
        [Parameter(Mandatory=$false)]
        [string]$FromCullingID,
        [Parameter(Mandatory=$false)]
        [string]$ToCullingID
    )

    $ApiBase = "/api/cullingapi/getevents/$($FlowInstanceID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }
    if ($FromCullingID) {
        $QueryParamters.Add('fromCullingID',$FromCullingID)
    }
    if ($ToCullingID) {
        $QueryParamters.Add('toCullingID',$ToCullingID)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-CulledErrandByVersionID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VersionID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate,
        [Parameter(Mandatory=$false)]
        [string]$FromCullingID,
        [Parameter(Mandatory=$false)]
        [string]$ToCullingID
    )

    $ApiBase = "/api/cullingapi/getevents/flow/$($VersionID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }
    if ($FromCullingID) {
        $QueryParamters.Add('fromCullingID',$FromCullingID)
    }
    if ($ToCullingID) {
        $QueryParamters.Add('toCullingID',$ToCullingID)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-CulledErrandByFamilyID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FamilyID,
        [Parameter(Mandatory=$false)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate,
        [Parameter(Mandatory=$false)]
        [string]$FromCullingID,
        [Parameter(Mandatory=$false)]
        [string]$ToCullingID
    )

    $ApiBase = "/api/cullingapi/getevents/family/$($FamilyID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ($FromDate) {
        $QueryParamters.Add('fromdate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('todate',$ToDate)
    }
    if ($FromCullingID) {
        $QueryParamters.Add('fromCullingID',$FromCullingID)
    }
    if ($ToCullingID) {
        $QueryParamters.Add('toCullingID',$ToCullingID)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-Queues {
    $ApiBase = "/api/queueapi/getqueues"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-ActiveQueuesByID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$QueueID
    )

    $ApiBase = "/api/queueapi/getactivequeueslots/$($QueueID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-ArchivedQueuesByID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$QueueID
    )

    $ApiBase = "/api/queueapi/getactivequeueslots/$($QueueID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-QueueByID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$QueueID
    )

    $ApiBase = "/api/queueapi/getqueueslot/$($QueueID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-QueueByPersonIDAndQueueID {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PersonID,
        [Parameter(Mandatory=$true)]
        [string]$QueueID
    )

    $ApiBase = "/api/queueapi/getqueueslot/$($QueueID)/$($PersonID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

function Get-Reservations {
    $ApiBase = "/api/reservations/getreservations"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
    
}

function Remove-Reservation {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ReservationID
    )

    $ApiBase = "/api/reservations/deletereservation/$($ReservationID)"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

Export-ModuleMember -Function Get-Eservices
Export-ModuleMember -Function Get-Categories
Export-ModuleMember -Function Get-EservicesByCategory
Export-ModuleMember -Function Get-Eservice
Export-ModuleMember -Function Get-EserviceByFamilyID
Export-ModuleMember -Function Get-PopularEservices
Export-ModuleMember -Function Search-EservicesByQuery
Export-ModuleMember -Function New-BasicAuthenticationHeader
Export-ModuleMember -Function Get-ErrandXML
Export-ModuleMember -Function Remove-Reservation
Export-ModuleMember -Function Get-Reservations
Export-ModuleMember -Function Get-QueueByPersonIDAndQueueID
Export-ModuleMember -Function Get-QueueByID
Export-ModuleMember -Function Get-ArchivedQueuesByID
Export-ModuleMember -Function Get-ActiveQueuesByID
Export-ModuleMember -Function Get-Queues
Export-ModuleMember -Function Get-CulledErrandByFamilyID
Export-ModuleMember -Function Get-CulledErrandByVersionID
Export-ModuleMember -Function Get-CulledErrand
Export-ModuleMember -Function Get-Statistics
Export-ModuleMember -Function Get-StatisticsByDate
Export-ModuleMember -Function Get-Attachment
Export-ModuleMember -Function Get-Message
Export-ModuleMember -Function Get-MessagesByFamilyID
Export-ModuleMember -Function Get-MessagesByVersionID
Export-ModuleMember -Function Get-EventsByFamilyID
Export-ModuleMember -Function Get-EventsByVersionID
Export-ModuleMember -Function Get-Events
Export-ModuleMember -Function Get-Status
Export-ModuleMember -Function Get-ErrandPDF
Export-ModuleMember -Function Get-ErrandsByAttribute
Export-ModuleMember -Function Get-ErrandsByVersionIDAndStatus
Export-ModuleMember -Function Get-ErrandsByFamilyIDAndStatus
Export-ModuleMember -Function Get-ErrandsByFamilyID
Export-ModuleMember -Function Get-ErrandsByVersion