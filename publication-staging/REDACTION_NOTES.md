# Publication Redaction Notes

## Scope

This directory contains sanitized copies prepared for public publication. Original evidence files were not modified.

## Sanitization

The staging process replaced local Windows project paths and non-placeholder Linux home paths with neutral placeholders to avoid exposing workstation-specific directory names and user information.

The Docker laboratory's private internal network addresses are retained where relevant to understanding the recorded topology and experiments. They are lab-only addresses, not public service endpoints.

## Integrity

`PUBLICATION_MANIFEST.csv` records SHA-256 hashes for the sanitized publication files. It does not include its own hash.

The original per-LOAD SHA-256 manifests are intentionally excluded from publication staging. They refer to original evidence files whose contents differ from sanitized copies. Those original manifests are retained in the private research area; the publication manifest is the correct integrity reference for sanitized copies.

## Review limitations

Sanitization and pattern scans reduce accidental disclosure risk but cannot guarantee detection of every possible secret or sensitive datum. Review published files before release. Do not publish raw evidence, private audit outputs, credentials, private keys, or workstation-specific records.
