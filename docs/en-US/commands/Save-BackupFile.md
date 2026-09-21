---
external help file: ConfluencePS-help.xml
online version: https://atlassianps.org/docs/ConfluencePS/commands/Save-BackupFile/
Module Name: ConfluencePS
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/ConfluencePS/commands/Save-BackupFile/
---
# Save-BackupFile

## SYNOPSIS

Download a Confluence backup file for a completed backup job.

## SYNTAX

```powershell
Save-ConfluenceBackupFile -ApiUri <Uri> [-Credential <PSCredential>]
 [-PersonalAccessToken <String>] [-Certificate <X509Certificate>]
 -JobId <UInt64> -OutputFolder <String>
```

## DESCRIPTION

Download the backup file associated with a Confluence backup job.

The job ID can be supplied directly, through the pipeline, or by piping a job
object returned from `Get-ConfluenceJob`. The command returns `$true` when the
download request completes successfully.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```powershell
Save-ConfluenceBackupFile -JobId 123
```

Save job 123 to the user's Downloads directory as `backup-123.zip`.

### -------------------------- EXAMPLE 2 --------------------------

```powershell
Get-ConfluenceJob -JobId 123 | Save-ConfluenceBackupFile -OutputFolder 'C:\Backups'
```

Save a job returned by `Get-ConfluenceJob` to the specified directory.

## PARAMETERS

### -ApiUri

The URi of the API interface.
Value can be set persistently with Set-ConfluenceInfo.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:
Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Confluence's credentials for authentication.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PersonalAccessToken

Confluence's Personal Access Token for authentication.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Certificate

Certificate for authentication.

```yaml
Type: X509Certificate
Parameter Sets: (All)
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobId

ID of the backup job to download. Accepts pipeline input by value and by the
`ID` or `JobId` property.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: ID
Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -OutputFolder

Existing directory in which to save the backup file. The file name returned by
the Confluence API is always used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### System.UInt64

### System.Management.Automation.PSObject

## OUTPUTS

### System.Boolean

## NOTES

The backup job must be available for download, and the caller must have the
required permissions for the spaces included in the job.

## RELATED LINKS

[https://github.com/AtlassianPS/ConfluencePS](https://github.com/AtlassianPS/ConfluencePS)
