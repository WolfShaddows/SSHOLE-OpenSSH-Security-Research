param(
    [Parameter(Mandatory = $true)]
    [string]$Manifest
)

$ErrorActionPreference = "Stop"

$ManifestPath = (Resolve-Path $Manifest).Path
$ManifestDir = Split-Path $ManifestPath -Parent

$Rows = Import-Csv -LiteralPath $ManifestPath

$Results = foreach ($Row in $Rows) {
    $Candidate = $null

    foreach ($Column in @("Path", "File", "Filename")) {
        if ($Row.PSObject.Properties.Name -contains $Column) {
            $Value = [string]$Row.$Column

            if (-not [string]::IsNullOrWhiteSpace($Value)) {
                if ([System.IO.Path]::IsPathRooted($Value)) {
                    if (Test-Path -LiteralPath $Value) {
                        $Candidate = $Value
                    }
                } else {
                    $Local = Join-Path $ManifestDir $Value
                    if (Test-Path -LiteralPath $Local) {
                        $Candidate = $Local
                    }
                }
            }

            if ($Candidate) { break }
        }
    }

    $Expected = $null

    foreach ($Column in @("SHA256", "Hash", "Checksum")) {
        if ($Row.PSObject.Properties.Name -contains $Column) {
            $Expected = [string]$Row.$Column
            if ($Expected) { break }
        }
    }

    if (-not $Candidate -or -not $Expected) {
        [PSCustomObject]@{
            File = $Candidate
            Status = "UNRESOLVED"
        }
        continue
    }

    $Actual = (Get-FileHash -LiteralPath $Candidate -Algorithm SHA256).Hash

    [PSCustomObject]@{
        File = $Candidate
        Status = if ($Actual -eq $Expected) { "VERIFIED" } else { "MISMATCH" }
    }
}

$Results | Format-Table -AutoSize

$Good = @($Results | Where-Object Status -eq "VERIFIED").Count
$Bad = @($Results | Where-Object Status -ne "VERIFIED").Count

Write-Host "VERIFIED: $Good" -ForegroundColor Green
Write-Host "UNVERIFIED: $Bad" -ForegroundColor $(if ($Bad -eq 0) {"Green"} else {"Red"})
