---
external help file: ConfluencePS-help.xml
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-Job/
Module Name: ConfluencePS
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/ConfluencePS/commands/Get-Job/
---
# Get-Job

## SYNOPSIS

Retrieve Confluence backup and restore jobs.

## SYNTAX

### JobId

```powershell
Get-ConfluenceJob -ApiUri <Uri> [-Credential <PSCredential>]
 [-PersonalAccessToken <String>] [-Certificate <X509Certificate>]
 -JobId <UInt64>
```

### Filters (Default)

```powershell
Get-ConfluenceJob -ApiUri <Uri> [-Credential <PSCredential>]
 [-PersonalAccessToken <String>] [-Certificate <X509Certificate>]
 [-Owner <String>] [-SpaceKey <String>] [-FromDate <String>]
 [-JobStates <String[]>] [-ToDate <String>] [-JobOperation <String>]
 [-JobScope <String>] [-PageSize <UInt32>] [-IncludeTotalCount]
 [-Skip <UInt64>] [-First <UInt64>]
```

## DESCRIPTION

Retrieve a Confluence backup or restore job by ID, or retrieve jobs matching
the specified filters.

Job IDs can be supplied directly, from the pipeline, or by an object's `ID` or
`JobId` property.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```powershell
Get-ConfluenceJob -JobId 123
```

Retrieve job 123.

### -------------------------- EXAMPLE 2 --------------------------

```powershell
Get-ConfluenceJob -JobOperation BACKUP -JobScope SPACE
```

Retrieve space backup jobs.

### -------------------------- EXAMPLE 3 --------------------------

```powershell
Get-ConfluenceJob -JobId 123 | Get-ConfluenceJob
```

Retrieve a job using the ID property of a previously returned job object.

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

Retrieve a specific backup or restore job by ID. Accepts pipeline input by value
and by the `ID` or `JobId` property.

```yaml
Type: UInt64
Parameter Sets: JobId
Aliases: ID
Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Owner

Filter jobs by the user who created them.

```yaml
Type: String
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SpaceKey

Filter jobs by space key.

```yaml
Type: String
Parameter Sets: Filters
Aliases: Key
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FromDate

Filter jobs created on or after this date. Use the date format accepted by the
Confluence REST API.

```yaml
Type: String
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobStates

Filter jobs by one or more job states.

```yaml
Type: String[]
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ToDate

Filter jobs created on or before this date. Use the date format accepted by the
Confluence REST API.

```yaml
Type: String
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobOperation

Filter jobs by operation, such as `BACKUP` or `RESTORE`.

```yaml
Type: String
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobScope

Filter jobs by scope, such as `SITE` or `SPACE`.

```yaml
Type: String
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

Maximum number of filtered jobs to fetch per call.

```yaml
Type: UInt32
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: 25
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTotalCount

Causes an extra output of the total count at the beginning.

```yaml
Type: SwitchParameter
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip

Controls how many filtered jobs are skipped before output starts.

```yaml
Type: UInt64
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -First

Indicates how many filtered jobs to return.

```yaml
Type: UInt64
Parameter Sets: Filters
Aliases:
Required: False
Position: Named
Default value: 18446744073709551615
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### System.UInt64

### System.Management.Automation.PSObject

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

Piped job objects are supported through their `ID` or `JobId` property.

## RELATED LINKS

[https://github.com/AtlassianPS/ConfluencePS](https://github.com/AtlassianPS/ConfluencePS)
