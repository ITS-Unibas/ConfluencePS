function Get-User {
    [CmdletBinding(SupportsPaging)]
    [OutputType([ConfluencePS.User])]
    param (
        [Parameter(Mandatory)]
        [uri]
        $ApiUri,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [ValidateNotNull()]
        [System.Security.Cryptography.X509Certificates.X509Certificate]
        $Certificate,

        [Parameter(
            ParameterSetName = "byName"
        )]
        [string]
        $UserName,

        [Parameter(
            ParameterSetName = "byKey"
        )]
        [string[]]
        $UserKey,

        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $PageSize = 25
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceApi = "$ApiUri/user?{0}"

        #setup defaults that don't change based on the pipeline or the parameter set
        $iwParameters = Copy-CommonParameter -InputObject $PSBoundParameters
        $iwParameters['Method'] = 'Get'
        $iwParameters['GetParameters'] = @{
            expand = "space,version,body.storage,ancestors"
            limit  = $PageSize
        }
        $iwParameters['OutputType'] = [ConfluencePS.User]
    }

    PROCESS {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $iwParameters[$_] = $PSCmdlet.PagingParameters.$_
        }

        switch -regex ($PsCmdlet.ParameterSetName) {
            "byKey" {
                $iwParameters["Uri"] = $resourceApi -f "key=$UserKey"
                Invoke-Method @iwParameters
                break
            }
            "byName" {
                $iwParameters["Uri"] = $resourceApi -f "username=$UserName"
                Invoke-Method @iwParameters
                break
            }
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
