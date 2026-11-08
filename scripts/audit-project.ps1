$ErrorActionPreference = "Continue"

Write-Host "`n========== SSHOLE PROJECT AUDIT ==========" -ForegroundColor Cyan

$Required = @(
    "README.md",
    "FINAL_RESEARCH_REPORT.md",
    "PACKAGE_MANIFEST.md",
    "docker-compose.yml",
    "docs\ARCHITECTURE.md",
    "docs\FINDINGS.md",
    "docs\RESEARCH_PROTOCOL.md",
    "docs\SOURCES.md",
    "docs\THREAT_MODEL.md",
    "scripts\inventory-analyst.sh",
    "scripts\inventory-target.sh",
    "scripts\build-evidence-index.ps1",
    "scripts\verify-manifest.ps1"
)

foreach ($Item in $Required) {
    if (Test-Path $Item) {
        Write-Host "[OK] $Item" -ForegroundColor Green
    } else {
        Write-Host "[MISSING] $Item" -ForegroundColor Red
    }
}

Write-Host "`n========== DIRECTORY FILE COUNTS =========="

Get-ChildItem -Directory -Recurse |
    ForEach-Object {
        $Count = @(Get-ChildItem $_.FullName -File -Recurse).Count
        [PSCustomObject]@{
            Directory = $_.FullName.Substring((Get-Location).Path.Length + 1)
            Files = $Count
        }
    } |
    Format-Table -AutoSize

Write-Host "`n========== ROOT FILES =========="

Get-ChildItem -File |
    Select-Object Name, Length |
    Format-Table -AutoSize
