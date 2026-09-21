---
external help file: ConfluencePS-help.xml
online version: https://atlassianps.org/docs/ConfluencePS/commands/Submit-SpaceBackupJob/
Module Name: ConfluencePS
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/ConfluencePS/commands/Submit-SpaceBackupJob/
---
# Submit-SpaceBackupJob

## SYNOPSIS

Create a Confluence space backup job.

## SYNTAX

```powershell
Submit-ConfluenceSpaceBackupJob -ApiUri <Uri> [-Credential <PSCredential>]
 [-PersonalAccessToken <String>] [-Certificate <X509Certificate>]
 -InputObject <Space> [-KeepPermanently] [-FileNamePrefix <String>]
 [-WhatIf] [-Confirm]
```

## DESCRIPTION

Submit a backup job for a Confluence space. The space can be supplied directly
or through the pipeline from `Get-ConfluenceSpace`.

The command returns the backup job details returned by Confluence. The backup
is queued asynchronously and is not complete when this command returns.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```powershell
Get-ConfluenceSpace -SpaceKey DEMO | Submit-ConfluenceSpaceBackupJob
```

Submit a backup job for the `DEMO` space.

### -------------------------- EXAMPLE 2 --------------------------

```powershell
Get-ConfluenceSpace -SpaceKey DEMO |
    Submit-ConfluenceSpaceBackupJob -KeepPermanently -FileNamePrefix 'demo-backup'
```

Submit a backup job and keep the resulting backup permanently using the given
file name prefix.

## PARAMETERS

### -ApiUri

The URI of the API interface.
Value can be set persistently with `Set-ConfluenceInfo`.

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

### -InputObject

Confluence space to back up. Accepts `ConfluencePS.Space` objects from the
pipeline.

```yaml
Type: Space
Parameter Sets: (All)
Aliases:
Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -KeepPermanently

Keep the generated backup permanently instead of allowing it to be removed by
the server's retention policy.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:
Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileNamePrefix

Prefix for the generated backup file name.

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

## INPUTS

### ConfluencePS.Space

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

The backup job is asynchronous. The returned job details describe the queued
job and do not indicate that the backup has finished.

## RELATED LINKS

[https://github.com/AtlassianPS/ConfluencePS](https://github.com/AtlassianPS/ConfluencePS)
