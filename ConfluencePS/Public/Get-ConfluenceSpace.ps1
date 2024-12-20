function Get-ConfluenceSpace {
    [CmdletBinding(
        SupportsPaging = $true
    )]
    [OutputType([ConfluencePS.Space])]
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
            Position = 0
        )]
        [Alias('Key')]
        [string[]]$SpaceKey,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$PageSize = 25
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceApi = "$ApiUri/space{0}"
    }

    PROCESS {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = Copy-CommonParameter -InputObject $PSBoundParameters
        $iwParameters['Method'] = 'Get'
        $iwParameters['GetParameters'] = @{
            expand = "description.plain,icon,homepage,metadata.labels"
            limit  = $PageSize
        }
        $iwParameters['OutputType'] = [ConfluencePS.Space]

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
        }

        if ($SpaceKey) {
            foreach ($_space in $SpaceKey) {
                $iwParameters["Uri"] = $resourceApi -f "/$_space"

                Invoke-ConfluenceMehtod @iwParameters
            }
        } else {
            $iwParameters["Uri"] = $resourceApi -f ""

            Invoke-ConfluenceMehtod @iwParameters
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
