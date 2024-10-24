function Get-ConfluencePage {
    [CmdletBinding(
        SupportsPaging = $true,
        DefaultParameterSetName = "byId"
    )]
    [OutputType([ConfluencePS.Page])]
    param (
        [Parameter( Mandatory = $true )]
        [uri]$ApiUri,

        [Parameter( Mandatory = $false )]
        [PSCredential]$Credential,

        [Parameter( Mandatory = $false )]
        [ValidateNotNull()]
        [System.Security.Cryptography.X509Certificates.X509Certificate]
        $Certificate,

        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = "byId",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('ID')]
        [int[]]$PageID,

        [Parameter(
            ParameterSetName = "bySpace"
        )]
        [Parameter(
            ParameterSetName = "bySpaceObject"
        )]
        [Alias('Name')]
        [string]$Title,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = "bySpace"
        )]
        [Parameter(
            ParameterSetName = "byLabel"
        )]
        [Alias('Key')]
        [string]$SpaceKey,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "bySpaceObject"
        )]
        [Parameter(
            ValueFromPipeline = $true,
            ParameterSetName = "byLabel"
        )]
        [ConfluencePS.Space]$Space,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = "byLabel"
        )]
        [string[]]$Label,

        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = "byQuery"
        )]
        [string]$Query,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$PageSize = 25
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceApi = "$ApiUri/content{0}"

        #setup defaults that don't change based on the pipeline or the parameter set
        $iwParameters = Copy-CommonParameter -InputObject $PSBoundParameters
        $iwParameters['Method'] = 'Get'
        $iwParameters['GetParameters'] = @{
            expand = "space,version,body.storage,ancestors"
            limit  = $PageSize
        }
        $iwParameters['OutputType'] = [ConfluencePS.Page]
    }

    PROCESS {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Space -is [ConfluencePS.Space] -and ($Space.Key)) {
            $SpaceKey = $Space.Key
        }

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
        }

        switch -regex ($PsCmdlet.ParameterSetName) {
            "byId" {
                foreach ($_pageID in $PageID) {
                    $iwParameters["Uri"] = $resourceApi -f "/$_pageID"

                    Invoke-ConfluenceMehtod @iwParameters
                }
                break
            }
            "bySpace" {
                # This includes 'bySpaceObject'
                $iwParameters["Uri"] = $resourceApi -f ''
                $iwParameters["GetParameters"]["type"] = "page"
                if ($SpaceKey) { $iwParameters["GetParameters"]["spaceKey"] = $SpaceKey }

                if ($Title) {
                    Invoke-ConfluenceMehtod @iwParameters | Where-Object { $_.Title -like "$Title" }
                } else {
                    Invoke-ConfluenceMehtod @iwParameters
                }
                break
            }
            "byLabel" {
                $iwParameters["Uri"] = $resourceApi -f "/search"

                $CQLparameters = @("type=page", "label=`"$Label`"")
                if ($SpaceKey) { $CQLparameters += "space=$SpaceKey" }
                $cqlQuery = ConvertTo-URLEncoded ($CQLparameters -join (" AND "))

                $iwParameters["GetParameters"]["cql"] = $cqlQuery

                Invoke-ConfluenceMehtod @iwParameters
                break
            }
            "byQuery" {
                $iwParameters["Uri"] = $resourceApi -f "/search"

                $cqlQuery = ConvertTo-URLEncoded $Query
                $iwParameters["GetParameters"]["cql"] = "type=page AND $cqlQuery"

                Invoke-ConfluenceMehtod @iwParameters
            }
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
