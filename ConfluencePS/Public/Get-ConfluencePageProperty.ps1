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
        [Object]
        $Page
    )

    BEGIN {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        function Resolve-XmlContent {
            <#
            .DESCRIPTION
                Resolves the content of an XML node, handling various child node types.
            #>
            param (
                $Node
            )

            if ($Node -is [String]) {
                return $Node

            }
            elseif ($Node -is [System.Xml.XmlLinkedNode]) {
                # <p>
                if ($Node.FirstChild.Name -eq 'p') {
                    Resolve-XmlContent $Node.'p'
                }
                # <div>
                elseif ($Node.FirstChild.Name -eq 'div') {
                    Resolve-XmlContent $Node.'div'
                }
                # <br>
                elseif ($Node.FirstChild.Name -contains 'br') {
                    return $Node.FirstChild.'#text'.Where({ -not ([string]::IsNullOrEmpty($_)) }) -join ";"
                }
                # <ul>
                elseif ($Node.FirstChild.Name -eq 'ul') {
                    return $Node.ul.li.Where({ -not ([string]::IsNullOrEmpty($_)) }) -join ";"
                }
                # macro 'status'
                elseif ($Node.FirstChild.Name -eq 'status') {
                    return ($Node.'structured-macro'.parameter | Where-Object { $_.name -eq 'title' }).'#text'.ToUpper()
                }
                # status-handy
                elseif ($Node.FirstChild.Name -eq 'status-handy') {
                    Resolve-XmlContent $Node.'structured-macro'.FirstChild.'#text'
                }
                # macro 'link'
                elseif ($Node.FirstChild.Name -eq 'ac:link') {
                    $SubTypeName = $Node.'link' |
                    Get-Member -MemberType Property |
                    Select-Object -ExpandProperty Name

                    if ($SubTypeName -eq 'page') {
                        return $Node.'link'.'page'.'content-title'
                    }
                    elseif ($SubTypeName -eq 'user') {
                        $Users = foreach ($UserKey in $Node.'link'.'user'.'userkey') {
                            Get-UniConfluenceUser -UserKey $UserKey -Credential $Credential -ApiUri $ApiUri
                        }
                        return $Users | Select-Object UserName, DisplayName
                    }
                    else {
                        Write-Verbose "Unknown link subtype '$SubTypeName'"
                        return 'CONTENT_NOT_PARSABLE'
                    }
                }
                # ignore: macro 'children' and 'placeholder'
                elseif ($Node.FirstChild.Name -match 'children|placeholder') {
                    Write-Verbose "'Children Display' macros cannot be parsed!"
                    return 'CONTENT_NOT_PARSABLE'
                }
                else {
                    return $Node.InnerText
                }
            }

        }
    }

    PROCESS {
        foreach ($P in $Page) {
            $Xml = [xml]$('<root xmlns:ac="http://atlassian.com/content" xmlns:ri="http://atlassian.com/resource/identifier" xmlns:at="http://atlassian.com/template">' + $P.Body + '</root>')
            $Ns = @{
                ac = "http://atlassian.com/content"
                ri = "http://atlassian.com/resource/identifier"
                at = "http://atlassian.com/template"
            }

            $PagePropertyMacro = Select-Xml -Xml $Xml -XPath "//ac:structured-macro[@ac:name='details']" -Namespace $ns | Select-Object -ExpandProperty Node

            $PageProperties = foreach ($Element in $PagePropertyMacro) {
                $PagePropertyMacroId = ($Element.parameter | Where-Object { $_.name -eq 'id' })."#text"

                $TableRows = $Element.'rich-text-body'.table.tbody.tr
                foreach ($Row in $TableRows) {

                    if ($Row.th -is [System.Xml.XmlLinkedNode]) {
                        $PropertyName = $Row.th.InnerText
                    }
                    elseif ($Row.th -is [String]) {
                        $PropertyName = $Row.th
                    }
                    else {
                        Write-Warning "Unexpected type for th element: $($Row.th.GetType().FullName)"
                        continue
                    }

                    $PropertyValue = Resolve-XmlContent $Row.td

                    [PSCustomObject]@{
                        PagePropertyMacroId = $PagePropertyMacroId
                        PropertyName        = $PropertyName
                        PropertyValue       = $PropertyValue
                    }
                }

            }

            [PSCustomObject]@{
                Id             = $P.Id
                Title          = $P.Title
                PageProperties = $PageProperties | Where-Object { $_.PropertyValue -ne 'CONTENT_NOT_PARSABLE' }
            }
        }
    }

    END {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
