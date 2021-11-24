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

# Get all eservices
function Get-Eservices {
    $ApiBase = "/api/v1/getflows/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

# Get all categories
function Get-Categories {
    $ApiBase = "/api/v1/getcategories/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri
    $Uri = $Uri.Uri.OriginalString

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml"
}

# Get eservices filtered by category ID
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

# Get a specific eservice by version ID
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

# Get eservices filtered by family ID
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

# Get the most popular eservices
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

# Get eservice defined by a search filter
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

# Get errands by eservice version ID
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get errands by eservice family ID
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    Write-Host "$Uri"

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get errands by eservice family ID and status
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get errands by eservice version ID and status
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get errands by attribute
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri "" -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get a specific errand filtered by errand (Flow Instance) ID
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}
    Write-Host "$Uri"
    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get errand as PDF filtered by errand (Flow Instance) ID
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -OutFile $filename -Headers $Headers
}

# Get status of an errand
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get events
# Optional: Filter by fromDate & toDate
# Optional: Filter by fromEventID & toEventID
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
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

# Get events by version ID
# Optional: Filter by fromDate & toDate
# Optional: Filter by fromEventID & toEventID
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
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

# Get events by family ID
# Optional: Filter by fromDate & toDate
# Optional: Filter by fromEventID & toEventID
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
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

# Get messages by eservice version ID
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get messages by eservice family ID
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get message filtered by message ID
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get attachment filtered by attachment ID
# Optional: Filter by fromDate & toDate
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    }

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -OutFile $filename -Headers $Headers
}

# Get eservice statistics filtered by fromDate
# Optional: Filter by fromDate & toDate
function Get-StatisticsByDate {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FromDate,
        [Parameter(Mandatory=$false)]
        [string]$ToDate
    )

    $ApiBase = "/api/flowinstancestatistics/getflowinstances/xml"
    $Uri = "$($Hostname)$($ApiBase)"
    $Uri = [System.UriBuilder]$Uri

    $QueryParamters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    $QueryParamters.Add('fromDate',$FromDate)
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
    } 

    $Uri.Query = $QueryParamters.ToString()
    $Uri = $Uri.Uri.OriginalString

    $Headers = @{
		Authorization = New-BasicAuthenticationHeader
	}

    return Invoke-RestMethod -Uri $Uri -Method Get -ContentType "application/xml" -Headers $Headers
}

# Get eservice statistics
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

# Get culled errands filtered by errand (Flow Instance) ID
# Optional: Filter by fromDate & toDate
# Optional: Filter by fromCullingID & toCullingID
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
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

# Get culled errands filtered by eservice version ID
# Optional: Filter by fromDate & toDate
# Optional: Filter by fromCullingID & toCullingID
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
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

# Get culled errands filtered by eservice family ID
# Optional: Filter by fromDate & toDate
# Optional: Filter by fromCullingID & toCullingID
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
        $QueryParamters.Add('fromDate',$FromDate)
    }
    if ($ToDate) {
        $QueryParamters.Add('toDate',$ToDate)
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

# Get queues
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

# Get active queue by queue ID
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

# Get archived queue by queue ID
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

# Get queue by queue ID
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

# Get queue by person ID and queue ID
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

# Get reservations
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

# Remove reservations
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
