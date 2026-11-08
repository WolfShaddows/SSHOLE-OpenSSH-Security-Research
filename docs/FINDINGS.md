# Findings

**Case:** SSHOLE-2026-001<br>
**Status:** Defensive and configuration research completed; vulnerability reproduction not performed.

## Evidence classifications
- **Observed:** directly captured in this laboratory.
- **Vendor-confirmed:** stated by OpenSSH or Alpine.
- **Inferred:** interpretation supported by observations, with limitations.
- **Not tested:** outside the completed experimental scope.

## Findings register
| ID | Claim | Classification | Evidence |
|---|---|---|---|
| F-001 | OpenSSH 10.6p2 documents a workaround for the reported musl/PAM-disabled password-authentication condition. | Vendor-confirmed | OpenSSH release notes |
| F-002 | The Alpine target used OpenSSH package revision `10.3_p1-r2`, identified by Alpine as fixed for the 3.24 branch. | Observed + Vendor-confirmed | System inventory; Alpine advisory |
| F-003 | The reported password-authentication bypass was not reproduced in this laboratory. | Not reproduced | No vulnerable package was tested |
| F-004 | Baseline and candidate configurations produced different remote agent-socket availability. | Observed | LOAD 010 |
| F-005 | The tested local TCP forwarding requests were denied by both baseline and candidate server policies. | Observed | LOAD 011 |
| F-006 | The baseline denied the tested remote StreamLocal request, while an isolated control with `AllowTcpForwarding yes` accepted it and created the remote socket. | Observed | LOAD 011 |
| F-007 | The laboratory used an internal Docker network and documented container hardening controls. | Observed | LOAD 008 and system inventory |
| F-008 | Six experiment manifests listed 27 evidence files whose SHA256 values matched. | Observed | LOAD 012 integrity audit |

## Detailed findings

### F-001 — Upstream workaround
[OpenSSH 10.6p2 release notes](https://www.openssh.org/releasenotes.html) document a workaround associated with the reported musl and PAM-disabled password-authentication condition. The [Alpine security advisory](https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/) describes the affected conditions and fixed package revisions. This is vendor-confirmed, not a reproduction result from this project.

### F-002 — Patched Alpine baseline
The system inventory records Alpine 3.24.4, musl x86_64, and:
- `openssh-keygen-10.3_p1-r2`
- `openssh-server-10.3_p1-r2`
- `openssh-server-common-10.3_p1-r2`

The [Alpine advisory](https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/) identifies `10.3_p1-r2` as the fixed revision for the Alpine 3.24 branch; the [3.24.4 release announcement](https://www.alpinelinux.org/posts/alpine-3.21.10-3.22.8-3.23.8-3.24.4-released/) confirms that the release includes the OpenSSH fix. The target is classified as a patched baseline.

### F-003 — No vulnerability reproduction
The project did not qualify or install a vulnerable package build. The affected-build comparison was not performed. No claim is made that the bypass was reproduced, exploited, or independently disproved.

### F-004 — Agent forwarding
LOAD 010 compared baseline sshd on port 22 with a candidate service on port 2222. The same Ed25519 key authenticated successfully to both. The baseline remote session exposed `SSH_AUTH_SOCK`; the candidate session did not. No remote signing operation or cryptographic agent query was performed.

### F-005 — TCP forwarding
LOAD 011 attempted local TCP forwarding against baseline and candidate services. Both requests were denied by server policy with `administratively prohibited` channel errors. The intended analyst-side TCP endpoint was not listening. No successful data transfer was demonstrated.

### F-006 — StreamLocal forwarding
LOAD 011 compared baseline with an isolated control. The baseline denied the tested remote StreamLocal request and the requested remote socket was absent. The isolated control used effective `AllowTcpForwarding yes`, preserving the other compared effective forwarding directives; it accepted the request and created the remote UNIX socket. No end-to-end application data exchange was demonstrated. This is a scoped observation, not a universal claim.

### F-007 — Container security boundary
LOAD 008 documented Docker isolation and hardening settings, including dropped capabilities, explicit additions, `no-new-privileges`, internal networking and temporary filesystem mounts. These observations do not prove protection against every possible container escape or host compromise.

### F-008 — Evidence integrity
The corrected LOAD 012 audit verified 27 files referenced by six manifests: LOAD 006 7/7; LOAD 007 2/2; LOAD 008 5/5; LOAD 009 2/2; LOAD 010 4/4; LOAD 011 7/7. Total: 27 verified, zero mismatches, zero missing. This does not cover every repository file.

## Limitations
- No vulnerable package build was installed.
- No password-authentication bypass was reproduced.
- LOAD 007 did not demonstrate successful public-key authentication.
- LOAD 010 did not perform a remote agent signing operation.
- LOAD 011 did not demonstrate successful TCP data transfer or end-to-end StreamLocal application exchange.
- No generalization beyond the tested container configuration is justified.

## Conclusion
The completed work supports defensive and configuration-level observations about SSH behavior in the tested Alpine environment. It does not establish successful reproduction of the reported OpenSSH password-authentication bypass.


## Official vendor references

- [Alpine Linux security advisory: OpenSSH password-authentication bypass (2026-11-05)](https://www.alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/)
