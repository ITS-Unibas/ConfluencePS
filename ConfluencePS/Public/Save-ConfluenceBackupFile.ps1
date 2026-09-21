function Save-ConfluenceBackupFile {
    [CmdletBinding()]
    [OutputType([Bool])]
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
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange(1, [UInt64]::MaxValue)]
        [Alias('ID')]
        [UInt64]$JobId,

        [Parameter( Mandatory = $true )]
        [ValidateScript(
            {
                if (-not (Test-Path $_ -PathType Container)) {
                    $errorItem = [System.Management.Automation.ErrorRecord]::new(
                        ([System.ArgumentException]"Path not found"),
                        'ParameterValue.DirectoryNotFound',
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                        $_
                    )
                    $errorItem.ErrorDetails = "Invalid directory path '$_'."
                    $PSCmdlet.ThrowTerminatingError($errorItem)
                }
                else {
                    return $true
                }
            }
        )]
        [String]$OutputFolder
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $authAndApiUri = Copy-CommonParameter -InputObject $PSBoundParameters -AdditionalParameter 'ApiUri'
    }

    PROCESS {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if (($_) -and -not($_ -is [PSCustomObject] -or $_ -is [UInt64])) {
            $message = "The Object in the pipe is not a backup job or a job ID."
            $exception = New-Object -TypeName System.ArgumentException -ArgumentList $message
            Throw $exception
        }

        $iwParameters = Copy-CommonParameter -InputObject $PSBoundParameters
        $iwParameters['Method'] = 'Get'
        $iwParameters['Uri'] = "$ApiUri/backup-restore/jobs/$JobId/download"

        $fileName = if ($_ -and $_.FileName) {
            $_.FileName
        }
        else {
            (Get-ConfluenceJob -JobId $JobId @authAndApiUri).FileName
        }

        if ([String]::IsNullOrWhiteSpace($fileName)) {
            $message = "The backup job $JobId did not provide a file name."
            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $message
            Throw $exception
        }

        $iwParameters['OutFile'] = Join-Path -Path $OutputFolder -ChildPath $fileName

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Downloading backup job $JobId to $($iwParameters['OutFile'])"
        $result = Invoke-ConfluenceMethod @iwParameters
        Write-Host "Saved backup job file to $($iwParameters['OutFile'])"
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
