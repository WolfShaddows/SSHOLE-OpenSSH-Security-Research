SSHOLE PROJECT — LOAD 005
RECOVERY & CONNECTION HANDLING
FINAL VALIDATION

Session: SSHOLE_LOAD_005_20261108_092014
Validation recorded: 2026-11-08T13:33:11.8631149Z

POST-TEST UBUNTU VALIDATION
TCP probes: 5
Successful: 5
Failed: 0
Observed availability: 100%

KALI FINAL SSH VALIDATION
Authentication result: Permission denied (publickey).
SSH exit code: 255
Interpretation: Expected authentication rejection.
Unexpected access: None observed.

FINAL FINDINGS
- TCP availability remained successful during post-test checks.
- SSH authentication remained restricted.
- No source-limit penalty was observed during LOAD 005.
- No connection drops attributable to source-limit penalties were observed.
- No actual post-penalty recovery time was measured.

LIMITATIONS
The experiment validates post-test service availability.
It does not establish recovery time after an actual source-limit penalty.
The final screenshot is operator-observed evidence, not an independently
captured machine-generated result file.

FINAL STATUS: VALIDATION COMPLETED
