# LOAD 011 — StreamLocal Forwarding Policy Validation

**Date:** 2026-11-08<br>
**Session:** SSHOLE_LOAD_011_20261108<br>
**Status:** Completed

## Objective

Compare TCP and Remote StreamLocal forwarding behavior across baseline, candidate, and controlled SSHD configurations.

## Environment

- Kali client: 172.23.0.4
- Alpine target: 172.23.0.3
- Ubuntu analyst: 172.23.0.2
- OpenSSH runtime: 10.3p1
- Authentication: Ed25519 public key
- Account: labuser

## Work performed

1. Reviewed authorized_keys restrictions and confirmed the test key had no key options.
2. Inspected relevant SSHD forwarding directives.
3. Attempted TCP local forwarding against baseline and candidate.
4. Captured client and server rejection messages.
5. Attempted Remote StreamLocal forwarding against baseline and candidate.
6. Created a positive control on port 2223.
7. Detected that the positive control changed multiple effective directives.
8. Created an isolated control on port 2224.
9. Corrected the isolated configuration after detecting duplicate `AllowTcpForwarding` declarations and first-value precedence.
10. Revalidated the effective configuration with `sshd -T -C`.
11. Repeated the baseline-versus-isolated-control comparison.
12. Verified remote socket presence and metadata on Alpine.
13. Exported seven evidence files and generated the SHA-256 manifest.
14. Verified all seven recorded hashes.

## Effective isolated comparison

| Directive | Baseline :22 | Isolated control :2224 |
|---|---|---|
| AllowTcpForwarding | no | yes |
| AllowStreamLocalForwarding | yes | yes |
| DisableForwarding | no | no |
| AllowAgentForwarding | yes | yes |

## Results

### TCP forwarding

Both baseline and candidate rejected the tested local forwarding requests.

The analyst endpoint was not confirmed listening. No successful TCP data transfer was demonstrated.

### Remote StreamLocal forwarding

Baseline rejected the request.

The isolated control accepted the request. The client reported `remote forward success`.

The target-side socket check showed the baseline socket absent and the isolated-control socket present.

The created socket was owned by `labuser` (UID/GID 1000), with mode `0600`.

## Finding

In the tested OpenSSH 10.3p1 environment, changing only the effective `AllowTcpForwarding` directive from `no` to `yes` changed the outcome of the tested Remote StreamLocal forwarding request.

This finding is limited to this environment and configuration.

## Limitations

- No authentication bypass was reproduced.
- No password-authentication vulnerability was tested or demonstrated.
- No end-to-end StreamLocal data transfer was verified.
- No successful TCP data transfer was demonstrated.
- Generalization to other OpenSSH versions remains untested.
- The final APK package revision lookup encountered transient DNS errors.

## Evidence

Directory:

`evidence/sessions/SSHOLE_LOAD_011_20261108/`

Seven evidence files are listed in `LOAD_011_SHA256.csv`.

Integrity check:

`INTEGRITY=VERIFIED`

`FILES_VERIFIED=7`

## Closure

LOAD 011 completed. Results, evidence, and limitations were documented. The experiment is suitable for inclusion in the final project audit, subject to the stated scope and limitations.
