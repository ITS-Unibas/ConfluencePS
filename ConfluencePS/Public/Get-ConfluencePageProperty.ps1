function Get-ConfluencePageProperty {
    [CmdletBinding()]
    [OutputType([ConfluencePS.ContentLabelSet])]
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
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Body,

        [Parameter()]
        [string[]]
        $FilterById
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    PROCESS {
        foreach ($Content in $Body) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

            # Extract page properties
            $PageProperties = foreach ($Match in [regex]::Matches($Content, '\<ac:structured-macro ac:name="details(?s)(.*?)\</ac:structured-macro>')) {

                $Match.Value
            }

            # Optionally filter by page property id
            if ($FilterById) {
                $PatternArray = foreach ($Filter in $FilterById) {
                    '\<ac:parameter ac:name="id"\>{0}\</ac:parameter\>' -f $Filter
                }
                $Pattern = $PatternArray -join '|'
                $PageProperties = $PageProperties | Where-Object { $_ -match $Pattern }
            }

            # Extract table body
            $TableBody = foreach ($Match in [regex]::Matches($PageProperties, '\<tbody.*?\>(?<TableBody>(?s).*?)\</tbody\>')) {
                $Match.Groups['TableBody'].Value
            }

            # Only match the table rows
            $TableRows = [regex]::Matches($TableBody, '\<tr.*?\>(.*?)\</tr\>', [System.Text.RegularExpressions.RegexOptions]::Singleline).ForEach({ $_.Groups[1].Value })
            $CurrentObject = [PSCustomObject]@{}
            foreach ($Row in $TableRows) {
                $Match = [regex]::Match($Row, '\<th.*?\>(?<PropertyName>.*?)\</th\>(?s)(.*?)\<td.*?\>(?s)(?<PropertyValue>.*?)\</td\>')
                $Name = $Match.Groups['PropertyName'].Value -Replace '\<.*?\>', ''
                $Value = $Match.Groups['PropertyValue'].Value

                switch -Regex ($Value) {
                    '\<br /\>' {
                        $Value = ($Value -split '<br />') | ForEach-Object {
                            $_ -replace '<.*?>', ''
                        }
                    }

                    'ac:link' {
                        $Value = [regex]::Match($Value, '\<ac:link.*?\>.*?ri:content-title=\"(?<LinkTitle>.*?)\".*?</ac:link\>').Groups['LinkTitle'].Value
                    }

                    'ac:placeholder' {
                        $Value = $null
                    }

                    '\<ul\>' {
                        $ListMatches = [regex]::Matches($Value, '\<li\>(?<ListItem>(?s).*?)\</li\>')
                        $ListItems = foreach ($ListItem in $ListMatches) {
                            $ListItem.Groups['ListItem'].Value
                        }
                        $Value = $ListItems
                    }

                    'ac:name="status"' {
                        $Value = [regex]::Match($Value, '\<ac:parameter ac:name="title"\>(?<MacroValue>.*?)\</ac:parameter\>').Groups['MacroValue'].Value.ToUpper()
                    }

                    'ac:name="children"' {
                        Write-Verbose "'Children Display' macros cannot be parsed!"
                        $SkipIteration = $true # Set a flag to skip the iteration
                    }
                    default { $Value = $Value -replace "\<.*?\>" }
                }

                if ($SkipIteration) {
                    $SkipIteration = $false # Reset flag
                    continue # Continue the foreach loop
                }

                $CurrentObject | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
            }
            $CurrentObject
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
