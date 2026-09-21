function Get-ConfluenceJob {
    [CmdletBinding(
        SupportsPaging = $true,
        DefaultParameterSetName = 'Filters'
    )]
    [OutputType([PSObject])]
    param (
        [Parameter( Mandatory = $true )]
        [Uri]$ApiUri,

        [Parameter( Mandatory = $false )]
        [PSCredential]$Credential,

        [Parameter( Mandatory = $false )]
        [String]
        $PersonalAccessToken,

        [Parameter( Mandatory = $false )]
        [ValidateNotNull()]
        [System.Security.Cryptography.X509Certificates.X509Certificate]
        $Certificate,

        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'JobId',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange(1, [UInt64]::MaxValue)]
        [Alias('ID')]
        [UInt64]$JobId,

        [Parameter(ParameterSetName = 'Filters')]
        [String]$Owner,

        [Parameter(ParameterSetName = 'Filters')]
        [Alias('Key')]
        [String]$SpaceKey,

        [Parameter(ParameterSetName = 'Filters')]
        [String]$FromDate,

        [Parameter(ParameterSetName = 'Filters')]
        [String[]]$JobStates,

        [Parameter(ParameterSetName = 'Filters')]
        [String]$ToDate,

        [Parameter(ParameterSetName = 'Filters')]
        [String]$JobOperation,

        [Parameter(ParameterSetName = 'Filters')]
        [String]$JobScope,

        [Parameter(ParameterSetName = 'Filters')]
        [ValidateRange(1, [UInt32]::MaxValue)]
        [UInt32]$PageSize = 25
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceApi = "$ApiUri/backup-restore/jobs"
    }

    PROCESS {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = Copy-CommonParameter -InputObject $PSBoundParameters
        $iwParameters['Method'] = 'Get'

        if ($PsCmdlet.ParameterSetName -eq 'JobId') {
            $iwParameters['Uri'] = "$resourceApi/$JobId"
        }
        else {
            $iwParameters['Uri'] = $resourceApi
            $iwParameters['GetParameters'] = @{
                limit = $PageSize
            }

            foreach ($parameterName in @(
                    'Owner',
                    'SpaceKey',
                    'FromDate',
                    'JobStates',
                    'ToDate',
                    'JobOperation',
                    'JobScope'
                )) {
                if ($PSBoundParameters.ContainsKey($parameterName)) {
                    $parameterValue = $PSBoundParameters[$parameterName]
                    $queryName = $parameterName.Substring(0, 1).ToLowerInvariant() + $parameterName.Substring(1)
                    $iwParameters['GetParameters'][$queryName] = $parameterValue
                }
            }
        }

        # Paging parameters are added after the API filters so Skip/First can be used normally.
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
        }

        Invoke-ConfluenceMethod @iwParameters
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
