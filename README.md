# SSHOLE Project

**DarkShadows Group — Security Research**<br>
**Case:** SSHOLE-2026-001<br>
**Status:** Defensive and configuration research completed; the reported password-authentication bypass was not reproduced.

## Mission

Investigate the reported OpenSSH password-authentication bypass condition associated with musl-based Linux systems, examine SSH authentication and forwarding behavior, and document defensive controls in an isolated laboratory.

> **Safety boundary:** Testing was limited to disposable Docker containers on a private internal network, using synthetic accounts and test keys. No public SSH service, third-party system, real credentials, persistence, or external target was used.

## Executive conclusion

The reported password-authentication bypass was **not reproduced**.

The laboratory target ran Alpine Linux 3.24.4 with musl libc and OpenSSH packages at revision `10.3_p1-r2`. The project inventory records this revision, and the Alpine advisory dated 2026-11-05 identifies it as the fixed revision for the Alpine 3.24 branch. The target is therefore classified as a **patched baseline**, not a vulnerable test target.

The project produced scoped observations about connection handling, authentication policy, container isolation, agent forwarding, TCP forwarding restrictions, and remote StreamLocal forwarding. These observations do not constitute reproduction of the password-authentication bypass.

## Reported vulnerability conditions

According to the Alpine security advisory, the reported condition requires:

1. Linux using musl libc.
2. OpenSSH server built without PAM, or PAM configured with `UsePAM no`.
3. Effective `PasswordAuthentication yes`.
4. A target account whose shadow password field is `*`.
5. At least one other local account with a `$5$` or `$6$` password hash.
6. An overlong password between 257 and 1024 bytes.

A shadow field containing `!` is not equivalent to `*`. This is not a public-key length vulnerability.

## Laboratory architecture

| Terminal | Environment | Role |
|---|---|---|
| 1 | Windows PowerShell | Docker orchestration and evidence management |
| 2 | Ubuntu Analyst | Inventory, SSH client and configuration analysis |
| 3 | Kali Client | Controlled SSH client operations |
| 4 | Alpine SSH Target | Disposable OpenSSH server |

The three Linux environments are Docker Compose services on the internal `labnet` network. No SSH host port is published.

### Implemented hardening

The target service uses dropped Linux capabilities with a restricted explicit capability set, `no-new-privileges`, and temporary filesystem mounts. The Compose network is marked internal.

## Quick start

### Requirements

- Windows with PowerShell.
- Docker Desktop configured for Linux containers.
- Docker Compose plugin.
- Git, if cloning the repository.
- Internet access for the initial image build.

Versions recorded during the original project session:

| Component | Recorded version |
|---|---|
| Docker Engine | 29.2.1 |
| Docker Compose | v5.1.0 |
| Git | 2.56.0.windows.4 |

These are historical environment records, not minimum-version guarantees.

### Build and start

Run from the repository root:

```powershell
docker compose config
docker compose build
docker compose up -d
docker compose ps
```

### Open the four terminals

Open four PowerShell tabs/windows, each from the repository root.

**Terminal 1 — Windows host**

```powershell
docker compose ps
docker compose logs --tail 100 target
```

**Terminal 2 — Ubuntu Analyst**

```powershell
docker compose exec analyst bash
```

**Terminal 3 — Kali Client**

```powershell
docker compose exec client bash
```

**Terminal 4 — Alpine SSH Target**

```powershell
docker compose exec target sh
```

Verified tools in the recorded running environment:

| Environment | Verified tools |
|---|---|
| Ubuntu Analyst | Bash, SSH client |
| Kali Client | Bash, SSH client, OpenBSD Netcat |
| Alpine Target | `sh`, `sshd`, `ssh-keygen` |

Netcat was not installed in the recorded Ubuntu image. Alpine's available utilities are intentionally limited; do not assume it has Python, Socat, Perl, or an SSH client.

For detailed setup, inventory commands, evidence tooling, LOAD qualifications and teardown, see [`docs/REPLICATION_GUIDE.md`](docs/REPLICATION_GUIDE.md).

## Experiment overview

| Experiment | Subject | Documented result |
|---|---|---|
| LOAD 001 | Connection handling | Source-based penalty observed in server logs |
| LOAD 002 | Sequential connections | Expected authentication rejections; no penalty event in supplied logs |
| LOAD 003 | Baseline telemetry | Connectivity and resource observations recorded |
| LOAD 004 | Concurrent connections | 12 expected authentication rejections; no unexpected success |
| LOAD 005 | Recovery | Five post-test TCP probes succeeded; recovery time after a penalty was not measured |
| LOAD 006 | Configuration | Effective security policy and package context documented |
| LOAD 007 | Authentication | Public-key-only rejection observed; valid-key acceptance not tested in this experiment |
| LOAD 008 | Security boundary | Container isolation and hardening controls inspected |
| LOAD 009 | Defensive policy | Candidate restrictions assessed at configuration level |
| LOAD 010 | Agent forwarding | Remote agent socket present in baseline session and absent in candidate session |
| LOAD 011 | Forwarding | TCP attempts denied; baseline StreamLocal request denied and isolated control accepted |
| LOAD 012 | Final audit | Documentation and manifest-listed evidence integrity review |

## Important limitations

- No vulnerable OpenSSH package was installed or tested.
- No password-authentication bypass was reproduced.
- LOAD 007 did not demonstrate successful public-key authentication.
- LOAD 010 did not perform a remote agent signing operation.
- LOAD 011 did not demonstrate successful TCP data transfer or end-to-end application data exchange through the StreamLocal socket.
- Findings are scoped to the tested container environment and configurations.
- The final SHA-256 audit covered 27 files listed in six manifests, not every file in the repository.
- The repository does not contain an automated runner for all twelve historical LOAD experiments. The LOAD records are documented historical procedures and results, not a one-command test suite.

## Official vulnerability references

The research question is grounded in the original vendor publications:

- [OpenSSH 10.6p2 release notes (2026-11-05)](https://www.openssh.org/releasenotes.html) — upstream security workaround.
- [Alpine Linux security advisory (2026-11-05)](https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/) — affected conditions, mechanism, mitigations, and fixed package revisions.
- [Alpine Linux 3.24.4 stable-release announcement (2026-11-05)](https://www.alpinelinux.org/posts/alpine-3.21.10-3.22.8-3.23.8-3.24.4-released/) — confirms the OpenSSH fix is included in the 3.24.4 release.

These sources confirm the reported issue and vendor remediation. They do **not** mean SSHOLE reproduced it: this project used the fixed Alpine 3.24.4 package revision and did not test an affected build. See [`docs/SOURCES.md`](docs/SOURCES.md) for the source register and attribution rules.

## Documentation

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — implemented topology and research stages.
- [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md) — reported conditions, scope and exclusions.
- [`docs/RESEARCH_PROTOCOL.md`](docs/RESEARCH_PROTOCOL.md) — methodology, evidence rules and deviations.
- [`docs/FINDINGS.md`](docs/FINDINGS.md) — evidence-backed findings and limitations.
- [`docs/SOURCES.md`](docs/SOURCES.md) — source attribution.
- [`docs/REPLICATION_GUIDE.md`](docs/REPLICATION_GUIDE.md) — detailed laboratory setup and four-terminal guide.
- [`FINAL_RESEARCH_REPORT.md`](FINAL_RESEARCH_REPORT.md) — consolidated final report.

## Stop the laboratory

From the repository root:

```powershell
docker compose down --remove-orphans
```

This stops and removes the Compose containers and network. It does not intentionally delete project evidence directories.

## Research integrity

SSHOLE documents what was tested, observed, confirmed by vendor sources, and left untested. The absence of a successful vulnerability reproduction is an explicit research outcome and must not be replaced by an unsupported exploitability claim.

## Environment verification

See [Environment Verification — 2026-11-08](docs/ENVIRONMENT_VERIFICATION_20261108.md) for the post-experiment verification of the Ubuntu, Kali, and Alpine environments.

## Official vendor references

- [Alpine Linux security advisory: OpenSSH password-authentication bypass (2026-11-05)](https://www.alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/)
