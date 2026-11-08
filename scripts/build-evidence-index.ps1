$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
$EvidenceRoot = Join-Path $Root "evidence"
$Output = Join-Path $EvidenceRoot "EVIDENCE_INDEX.csv"

$Files = Get-ChildItem -Path $EvidenceRoot -File -Recurse |
    Where-Object { $_.FullName -ne $Output }

$Rows = foreach ($File in $Files) {

    $Hash = $null
    $Status = "HASHED"
    $ErrorMessage = ""

    for ($Attempt = 1; $Attempt -le 3; $Attempt++) {
        try {
            $Hash = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
            $Status = "HASHED"
            break
        }
        catch {
            $ErrorMessage = $_.Exception.Message

            if ($Attempt -lt 3) {
                Start-Sleep -Seconds 2
            }
            else {
                $Status = "DEFERRED_LOCKED_OR_UNREADABLE"
            }
        }
    }

    [PSCustomObject]@{
        RelativePath = $File.FullName.Substring($Root.Length + 1)
        Name = $File.Name
        Extension = $File.Extension
        SizeBytes = $File.Length
        LastWriteTime = $File.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        SHA256 = $Hash
        Status = $Status
        Error = $ErrorMessage
    }
}

$Rows |
    Sort-Object RelativePath |
    Export-Csv -Path $Output -NoTypeInformation -Encoding UTF8

$Hashed = @($Rows | Where-Object Status -eq "HASHED").Count
$Deferred = @($Rows | Where-Object Status -ne "HASHED").Count

Write-Host "`n========== EVIDENCE INDEX ==========" -ForegroundColor Cyan
Write-Host "TOTAL FILES: $($Rows.Count)"
Write-Host "HASHED: $Hashed" -ForegroundColor Green
Write-Host "DEFERRED: $Deferred" -ForegroundColor Yellow
Write-Host "OUTPUT: $Output"

if ($Deferred -gt 0) {
    Write-Host "`nFiles requiring a later retry:" -ForegroundColor Yellow

    $Rows |
        Where-Object Status -ne "HASHED" |
        Select-Object RelativePath, Status, Error |
        Format-List
}
