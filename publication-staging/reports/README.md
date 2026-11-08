# Publication Reports

This directory contains sanitized, publication-ready report copies for the documented LOAD stages.

The consolidated project report is `FINAL_RESEARCH_REPORT.md` in the repository root. Research findings, methodology, architecture, threat model, sources and detailed logbook are maintained under `docs/`.

## Integrity of published copies

`publication-staging/PUBLICATION_MANIFEST.csv` records SHA-256 hashes for sanitized publication artifacts.

The original per-LOAD SHA-256 manifests are intentionally excluded from this publication staging area. They were generated for original evidence files; sanitization changes file contents and therefore changes their hashes. Publishing those original manifests alongside sanitized copies could misleadingly imply that they verify the sanitized files.

Original evidence and original per-LOAD manifests remain in the private research evidence area. Use the publication manifest to verify the sanitized published copies.

`../PUBLICATION_MANIFEST.csv` records SHA-256 and byte size for every file in `publication-staging/` except the manifest itself. It covers this sanitized staging tree only; it does not cover the repository, raw `evidence/`, or private audit material. Regenerate it after any change to staged files.
