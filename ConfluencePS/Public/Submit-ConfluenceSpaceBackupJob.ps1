function Submit-ConfluenceSpaceBackupJob {
    [CmdletBinding(
        ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true
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
            ValueFromPipeline = $true
        )]
        [ConfluencePS.Space]$InputObject,

        [Switch]$KeepPermanently,

        [String]$FileNamePrefix
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceApi = "$ApiUri/backup-restore/backup/space"
    }

    PROCESS {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = Copy-CommonParameter -InputObject $PSBoundParameters
        $iwParameters['Uri'] = $resourceApi
        $iwParameters['Method'] = 'Post'

        $Body = @{
            spaceKeys       = @($InputObject.Key)
            keepPermanently = [bool]$KeepPermanently
        }

        if ($FileNamePrefix) {
            $Body['fileNamePrefix'] = $FileNamePrefix
        }

        $iwParameters['Body'] = $Body | ConvertTo-Json

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Backup job request: $($Body | Out-String)"
        if ($PSCmdlet.ShouldProcess("Space $($InputObject.Key)")) {
            Invoke-ConfluenceMethod @iwParameters
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
