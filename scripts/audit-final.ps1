param(
    [string]$OutputDirectory = ".\evidence"
)

$ErrorActionPreference = "Continue"

$Root = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$AuditDirectory = Join-Path $OutputDirectory "FINAL_AUDIT_$Timestamp"

New-Item -ItemType Directory -Path $AuditDirectory -Force | Out-Null

$Excluded = @("\.git\")

$Files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
    Where-Object {
        $Relative = $_.FullName.Substring($Root.Length)
        -not ($Excluded | Where-Object { $Relative -match [regex]::Escape($_) })
    }

$Inventory = foreach ($File in $Files) {

    $RelativePath = $File.FullName.Substring($Root.Length + 1)
    $Hash = ""
    $Status = "HASHED"
    $ErrorText = ""

    try {
        $Hash = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
    }
    catch {
        $Status = "DEFERRED_LOCKED_OR_UNREADABLE"
        $ErrorText = $_.Exception.Message
    }

    [PSCustomObject]@{
        RelativePath = $RelativePath
        Bytes = $File.Length
        SHA256 = $Hash
        Status = $Status
        Error = $ErrorText
    }
}

$Inventory |
    Export-Csv (Join-Path $AuditDirectory "FILE_INVENTORY.csv") -NoTypeInformation -Encoding UTF8

$Duplicates = $Inventory |
    Where-Object { $_.Status -eq "HASHED" } |
    Group-Object SHA256 |
    Where-Object Count -gt 1

$DuplicateRows = foreach ($Group in $Duplicates) {
    foreach ($Entry in $Group.Group) {
        [PSCustomObject]@{
            SHA256 = $Group.Name
            Count = $Group.Count
            File = $Entry.RelativePath
        }
    }
}

$DuplicateRows |
    Export-Csv (Join-Path $AuditDirectory "DUPLICATES.csv") -NoTypeInformation -Encoding UTF8

$EmptyFiles = $Files |
    Where-Object Length -eq 0 |
    Select-Object @{
        Name = "File"
        Expression = { $_.FullName.Substring($Root.Length + 1) }
    }, Length

$EmptyFiles |
    Export-Csv (Join-Path $AuditDirectory "EMPTY_FILES.csv") -NoTypeInformation -Encoding UTF8

$Deferred = $Inventory |
    Where-Object Status -ne "HASHED"

$Deferred |
    Export-Csv (Join-Path $AuditDirectory "DEFERRED_FILES.csv") -NoTypeInformation -Encoding UTF8

$Summary = [PSCustomObject]@{
    Timestamp = $Timestamp
    TotalFiles = $Inventory.Count
    HashedFiles = @($Inventory | Where-Object Status -eq "HASHED").Count
    DeferredFiles = @($Deferred).Count
    EmptyFiles = @($EmptyFiles).Count
    DuplicateHashGroups = @($Duplicates).Count
    DuplicateFileEntries = @($DuplicateRows).Count
}

$Summary |
    Export-Csv (Join-Path $AuditDirectory "SUMMARY.csv") -NoTypeInformation -Encoding UTF8

Write-Host "`n========== SSHOLE FINAL AUDIT ==========" -ForegroundColor Cyan
$Summary | Format-List

Write-Host "AUDIT DIRECTORY: $AuditDirectory" -ForegroundColor Green
