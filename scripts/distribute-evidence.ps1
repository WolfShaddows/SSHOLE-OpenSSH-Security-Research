$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
$Sessions = Join-Path $Root "evidence\sessions"
$Categories = @(
    "alpine",
    "ubuntu",
    "kali",
    "network",
    "comparisons",
    "reports"
)

foreach ($Category in $Categories) {
    $Path = Join-Path $Root "evidence\$Category"
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

$Catalog = Join-Path $Root "evidence\EVIDENCE_COPY_CATALOG.csv"
$Rows = [System.Collections.Generic.List[object]]::new()

function Get-Category {
    param([System.IO.FileInfo]$File)

    $Name = $File.Name
    $Full = $File.FullName

    if ($Name -match "FINAL_REPORT\.md$") {
        return "reports"
    }

    if ($Name -match "AGENT_SOCKET|POLICY-COMPARISON") {
        return "comparisons"
    }

    if ($Name -match "ALPINE|TARGET|effective_config|labuser_config|root_kali_config|openssh_packages|security\.txt|proc_inspection|DOCKER-SECURITY|candidate\.conf|STREAMLOCAL_.*SERVER") {
        return "alpine"
    }

    if ($Name -match "ubuntu_network|UBUNTU") {
        return "ubuntu"
    }

    if ($Name -match "kali_policy|KALI-SSH|KALI|CURRENT_SESSION") {
        return "kali"
    }

    if ($Name -match "RESOURCES|RESULTS\.csv|TCP_|STREAMLOCAL_|DOCKER-STATS|SOCKET_METADATA") {
        return "network"
    }

    if ($Name -match "LOAD_00[1-5]|LOAD_006|LOAD_007|LOAD_008|LOAD_009|LOAD_010|LOAD_011") {
        return "network"
    }

    return $null
}

$Files = Get-ChildItem -LiteralPath $Sessions -File -Recurse |
    Where-Object {
        $_.Name -notmatch "HOSTKEY_20261108_075511"
    }

foreach ($File in $Files) {

    $Category = Get-Category -File $File

    if (-not $Category) {
        continue
    }

    $Relative = $File.FullName.Substring($Sessions.Length + 1)
    $Load = "GENERAL"

    if ($Relative -match "(LOAD_0\d{2})") {
        $Load = $Matches[1]
    }

    $DestinationDirectory = Join-Path $Root "evidence\$Category\$Load"
    New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null

    $Destination = Join-Path $DestinationDirectory $File.Name

    $SourceHash = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash

    if (Test-Path -LiteralPath $Destination) {
        $ExistingHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash

        if ($ExistingHash -ne $SourceHash) {
            throw "CONFLICT: destination exists with different hash: $Destination"
        }

        $Status = "ALREADY_PRESENT_IDENTICAL"
    }
    else {
        Copy-Item -LiteralPath $File.FullName -Destination $Destination

        $DestinationHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash

        if ($DestinationHash -ne $SourceHash) {
            throw "HASH MISMATCH after copy: $Destination"
        }

        $Status = "COPIED_VERIFIED"
    }

    $Rows.Add([PSCustomObject]@{
        Load = $Load
        Category = $Category
        Source = $Relative
        Destination = $Destination.Substring($Root.Length + 1)
        SHA256_Source = $SourceHash
        SHA256_Destination = $SourceHash
        Status = $Status
        SizeBytes = $File.Length
    })
}

$Rows |
    Sort-Object Load, Category, Source |
    Export-Csv -LiteralPath $Catalog -NoTypeInformation -Encoding UTF8

Write-Host "`n========== EVIDENCE DISTRIBUTION ==========" -ForegroundColor Cyan
Write-Host "FILES PROCESSED: $($Rows.Count)" -ForegroundColor Green
Write-Host "COPIED: $(@($Rows | Where-Object Status -eq 'COPIED_VERIFIED').Count)"
Write-Host "ALREADY PRESENT: $(@($Rows | Where-Object Status -eq 'ALREADY_PRESENT_IDENTICAL').Count)"
Write-Host "CATALOG: $Catalog"

Write-Host "`n========== CATEGORY COUNTS ==========" -ForegroundColor Cyan

$Rows |
    Group-Object Category |
    Sort-Object Name |
    Select-Object Name, Count |
    Format-Table -AutoSize

Write-Host "`nOriginal files were not moved or modified." -ForegroundColor Green
