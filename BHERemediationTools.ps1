function Get-BHEAceFindingTypes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DomainID
    )

    $aceFindingTypes = @(
        'T0GenericAll', 'T0GenericWrite', 'T0WriteDACL', 'T0WriteGPLink', 'T0AddSelf',
        'T0AllExtendedRights', 'T0ForceChangePassword', 'T0AddMember', 'T0AddAllowedToAct',
        'T0DCOM', 'T0Owns', 'T0ReadGMSA', 'T0DumpSMSA', 'T0ReadLAPS', 'T0WriteOwner',
        'T0AddKeyCredentialLink', 'T0SyncLAPSPassword', 'T0WriteAccountRestrictions',
        'LargeDefaultGroupsDCOM', 'LargeDefaultGroupsAddSelf', 'LargeDefaultGroupsPSRemote',
        'LargeDefaultGroupsGenericAll', 'LargeDefaultGroupsGenericWrite', 'LargeDefaultGroupsOwns',
        'LargeDefaultGroupsWriteDacl', 'LargeDefaultGroupsWriteGPLink', 'LargeDefaultGroupsWriteOwner',
        'LargeDefaultGroupsAllExtendedRights', 'LargeDefaultGroupsReadLAPS', 'LargeDefaultGroupsReadGMSA',
        'LargeDefaultGroupsAddKeyCredentialLink', 'LargeDefaultGroupsForceChangePassword',
        'LargeDefaultGroupsSyncLAPSPassword', 'LargeDefaultGroupsWriteAccountRestrictions',
        'LargeDefaultGroupsAddMember'
    )

    try {
        $availableFindingTypes = Get-BHPathFinding -ListAvail -DomainID $DomainID -ErrorAction Stop
    } catch {
        Write-Error "Failed to retrieve available finding types: $($_.Exception.Message)"
        return
    }

    $matchedTypes = $aceFindingTypes | Where-Object { $_ -in $availableFindingTypes }
    $total = $matchedTypes.Count
    $collected = @()
    $i = 0

    foreach ($type in $matchedTypes) {
        $i++
        $percentComplete = [math]::Round(($i / $total) * 100)
        Write-Progress -Activity "Collecting ACE Findings" -Status "Processing: $type" -PercentComplete $percentComplete

        try {
            $collected += Get-BHPathFinding -Detail -FindingType $type -DomainID $DomainID -ErrorAction Stop |
                Where-Object { $_.IsInherited -eq $false } |
                Select-Object FromPrincipal, ToPrincipal, FromPrincipalName, ToPrincipalName,
                              @{Name='FindingType'; Expression={ $type }}
        } catch {
            Write-Warning "Failed to retrieve findings for ${type}: $($_.Exception.Message)"
        }
    }

    Write-Progress -Activity "Collecting ACE Findings" -Completed

    if (-not $collected) {
        Write-Warning "No findings returned."
        return
    }

    $grouped = $collected |
    Group-Object FromPrincipal, ToPrincipal, FromPrincipalName, ToPrincipalName |
    Sort-Object Count -Descending |
    ForEach-Object {
        $sample = $_.Group[0]
        $findingTypes = $_.Group | Select-Object -ExpandProperty FindingType -Unique
        [PSCustomObject]@{
            Count              = $_.Count
            FromPrincipal      = $sample.FromPrincipal
            ToPrincipal        = $sample.ToPrincipal
            FromPrincipalName  = $sample.FromPrincipalName
            ToPrincipalName    = $sample.ToPrincipalName
            FindingTypes       = ($findingTypes -join '; ')
        }
    }

$grouped | Format-Table -AutoSize

}
