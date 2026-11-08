# SSHOLE-2026-001 — Final Research Report

**Organization:** DarkShadows Group<br>
**Research environment:** Docker Desktop / Alpine Linux / Ubuntu / Kali<br>
**Report status:** Final documentation of completed defensive and configuration experiments<br>
**Vulnerability reproduction:** Not performed

## 1. Executive summary
SSHOLE-2026-001 investigated a reported OpenSSH password-authentication bypass condition associated with musl-based Linux systems and specific PAM/password-authentication configurations.

The project built an isolated Docker laboratory and completed experiments covering connection behavior, baseline telemetry, authentication policy, container security boundaries, agent forwarding, and TCP/StreamLocal forwarding.

The reported password-authentication bypass was not reproduced. The issue and its remediation are documented by the [official OpenSSH 10.6p2 release notes](https://www.openssh.org/releasenotes.html) and [Alpine Linux security advisory](https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/).

The Alpine target ran version 3.24.4 with musl libc and OpenSSH package revision `10.3_p1-r2`. The project system inventory records this revision, and the [Alpine advisory dated 2026-11-05](https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/) identifies it as the fixed revision for the Alpine 3.24 branch. The [Alpine 3.24.4 release announcement](https://www.alpinelinux.org/posts/alpine-3.21.10-3.22.8-3.23.8-3.24.4-released/) independently states that the OpenSSH fix is included. The target was therefore a patched baseline, not a vulnerable test target.

The project produced scoped observations about SSH configuration and runtime behavior. These findings must not be represented as an exploit or successful vulnerability reproduction.

## 2. Research objective
The original objective was to understand the reported interaction between musl `crypt()`, PAM configuration, OpenSSH password authentication, and specific shadow-account states; compare affected and fixed configurations; and document defensive controls.

The intended vulnerable-versus-patched comparison was not completed because the tested target was already at the fixed Alpine 3.24 package revision. No vulnerable package was installed.

## 3. Reported vulnerability conditions
According to the Alpine advisory, the reported condition requires:
1. musl libc.
2. OpenSSH server built without PAM, or PAM configured with `UsePAM no`.
3. Effective `PasswordAuthentication yes`.
4. A target account with `*` in its shadow password field.
5. At least one other local account with a `$5$` or `$6$` password hash.
6. An overlong password input between 257 and 1024 bytes.

A shadow field containing `!` is not equivalent to `*`. The reported issue concerns password authentication, not public-key length.

The vendor advisory and OpenSSH release notes are the authority for the reported conditions and workaround. The project did not independently validate the vulnerability on an affected build.

## 4. Laboratory architecture and controls
The laboratory contained three disposable containers:

| Component | Role |
|---|---|
| Alpine | OpenSSH target |
| Ubuntu | Analyst and evidence collection |
| Kali | Controlled SSH client |

The containers communicated through an internal Docker network with no published SSH port.

Recorded hardening included `privileged=false`, `cap_drop: ALL`, explicit capability additions, `no-new-privileges:true`, temporary `/run` and `/tmp` mounts, and no published host port.

The target's recorded software baseline was Alpine 3.24.4, musl x86_64, and OpenSSH package revision `10.3_p1-r2`.

## 5. Experiment results

### LOAD 001 — Connection handling
A source-based penalty was observed in Alpine server logs. The recorded log included activation of an IPv4 penalty for connections that did not attempt authentication. This is an observation from LOAD 001; it should not be generalized into a universal threshold.

### LOAD 002 — Sequential connections
Eight sequential SSH attempts were performed. Supplied evidence records expected authentication rejections and no connection/protocol errors. No penalty event appeared in the supplied LOAD 002 logs.

### LOAD 003 — Baseline telemetry
Ubuntu recorded 25/25 TCP probes successful. Kali's eight SSH attempts ended in expected authentication rejection, with no successful authentication. The experiment also recorded container CPU and memory telemetry. These measurements describe the observed collection window and are not a production performance benchmark.

### LOAD 004 — Concurrent connections
The experiment used concurrency phases of 1, 2 and 4, with four attempts per phase. It recorded 12 expected authentication rejections, zero connection errors and zero unexpected successes.

The target log collection window was broad. Its entries cannot all be attributed exclusively to LOAD 004, and the evidence does not establish that LOAD 004 triggered a source penalty.

### LOAD 005 — Recovery
Five post-test TCP probes succeeded. The run did not measure elapsed recovery time after an actual source-penalty event.

### LOAD 006 — Configuration inventory
The experiment documented the effective SSH security policy and target configuration. The system inventory separately records the exact installed OpenSSH package revisions.

### LOAD 007 — Authentication policy
The server advertised public-key authentication, and attempts ended with `Permission denied (publickey)`. No valid public key was presented in this experiment, so successful public-key authentication was not established by LOAD 007.

### LOAD 008 — Security boundary
The experiment inspected Docker isolation and hardening controls, including capability restrictions, `no-new-privileges`, temporary filesystem mounts and internal networking. These observations document the tested configuration; they do not prove immunity to every container escape or host compromise.

### LOAD 009 — Defensive policy
The experiment compared baseline effective SSH policy with candidate defensive restrictions at configuration level. It should not be treated as a runtime forwarding test.

### LOAD 010 — Agent forwarding
The same Ed25519 key authenticated successfully to the baseline service on port 22 and the candidate service on port 2222.

The baseline remote session exposed `SSH_AUTH_SOCK`; the candidate session did not. This demonstrates a difference in remote agent-socket availability under the tested configurations. No remote agent query or signing operation was performed.

### LOAD 011 — TCP and StreamLocal forwarding
Local TCP forwarding attempts against the baseline and candidate services were denied by server policy with `administratively prohibited` errors. The intended analyst-side TCP endpoint was not listening, and no data transfer was demonstrated.

For remote StreamLocal forwarding, the baseline denied the tested request and the requested remote socket was absent.

An isolated control configuration with effective `AllowTcpForwarding yes`, while preserving the other compared effective forwarding directives, accepted the remote request and created the remote UNIX socket.

No end-to-end application data exchange through the socket was demonstrated. This result is limited to the tested OpenSSH environment and configuration.

## 6. Final evidence-integrity audit
The corrected LOAD 012 verifier checked files listed in six experiment manifests:

| Experiment manifest | SHA256 verified |
|---|---:|
| LOAD 006 | 7/7 |
| LOAD 007 | 2/2 |
| LOAD 008 | 5/5 |
| LOAD 009 | 2/2 |
| LOAD 010 | 4/4 |
| LOAD 011 | 7/7 |
| **Total** | **27/27** |

Result: 27 matching hashes, zero mismatches, zero missing files.

This audit applies only to the files listed in those six manifests. It is not a hash audit of every project file.

The five original documentation files were backed up before the documentation update and their SHA256 values matched their originals. `ARCHITECTURE.md` received a separate pre-update backup.

## 7. Limitations
The following were not established:
- Successful reproduction of the reported password-authentication bypass.
- Behavior of an exact affected OpenSSH/Alpine package build.
- A vulnerable-versus-patched test using identical inputs.
- Successful public-key authentication in LOAD 007.
- A remote agent signing operation in LOAD 010.
- Successful TCP data transfer in LOAD 011.
- End-to-end application data exchange through the StreamLocal socket in LOAD 011.
- Generalization of these observations to other OpenSSH releases, distributions or production environments.

## 8. Conclusions
The project documented an isolated SSH laboratory and produced observations about defensive configuration and SSH runtime behavior.

The strongest scoped runtime finding from LOAD 011 is that the tested baseline denied a remote StreamLocal forwarding request, while an isolated control with effective `AllowTcpForwarding yes` accepted the request and created the remote socket. No application data exchange was demonstrated.

The project did not reproduce the reported password-authentication bypass because the target was a patched Alpine baseline and no vulnerable build was tested.

This is the correct final research conclusion. The absence of a reproduction is a material limitation and must remain explicit in future summaries, presentations and publications.

## 9. Future work
A future vulnerability-reproduction study would require an exact affected package revision obtained from an official source, verified package and image digests, independent confirmation of every advisory precondition, a disposable isolated target, and an identical comparison against the fixed package.

Until those requirements are met, SSHOLE should be presented as defensive/configuration research, not as a successful exploit reproduction.


## 10. Official references

The authoritative vulnerability and remediation references are maintained in [`docs/SOURCES.md`](docs/SOURCES.md), including the OpenSSH 10.6p2 release notes, Alpine Linux security advisory, and Alpine 3.24.4 release announcement.


## Official vendor references

- [Alpine Linux security advisory: OpenSSH password-authentication bypass (2026-11-05)](https://www.alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/)
