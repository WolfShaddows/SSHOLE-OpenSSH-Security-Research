# SSHOLE — Laboratory Replication Guide

## 1. Purpose and scope

This guide describes how to reconstruct the SSHOLE Docker laboratory, access its four working terminals, inspect the environment, and review the documented research experiments.

It distinguishes between infrastructure reconstruction, repeating documented operational checks, reviewing historical LOAD001–LOAD012 results, and reproducing original experimental conditions. These activities are not equivalent. The repository does not provide a single automated runner for all twelve historical LOAD experiments.

The reported password-authentication bypass was not reproduced. The recorded Alpine target was a patched baseline.

## 2. Safety requirements

Use this laboratory only in an isolated, disposable environment.

- Do not connect experiments to public SSH services.
- Do not use third-party systems or real credentials.
- Use synthetic accounts and test keys only.
- Do not expose the target SSH port to the host or external networks.
- Do not replace the patched target with an affected build without a separately documented, authorized research plan.
- Preserve original evidence and distinguish it from sanitized publication copies.

The Compose network is configured as internal and no host port is published.

## 3. Host requirements

Required software:

- Windows host with PowerShell.
- Docker Desktop configured for Linux containers.
- Docker Compose plugin.
- Git, if cloning the repository.
- Internet connectivity during the initial image build.

Versions recorded during the original project session:

| Component | Recorded version |
|---|---|
| Docker Engine | 29.2.1 |
| Docker Compose | v5.1.0 |
| Git | 2.56.0.windows.4 |

These are historical environment records, not minimum-version guarantees.

Docker needs sufficient memory, CPU and disk space to build and run three Linux containers. Exact minimum resource requirements were not benchmarked.

## 4. Laboratory architecture

| Terminal | Environment | Service | Role |
|---|---|---|---|
| 1 | Windows PowerShell | Host | Docker orchestration and evidence management |
| 2 | Ubuntu Analyst | `analyst` | Inventory, SSH client and configuration analysis |
| 3 | Kali Client | `client` | Controlled SSH client operations |
| 4 | Alpine Target | `target` | Disposable OpenSSH server |

Container hostnames are `ubuntu-analyst`, `kali-client`, and `sshole-target`. The Compose network is `labnet`, an internal Docker bridge with no published SSH host port.

## 5. Build and start

From the repository root in PowerShell:

```powershell
docker compose config
docker compose build
docker compose up -d
docker compose ps
```

Inspect the network:

```powershell
docker network ls
docker network inspect ssholeproject_labnet
```

The actual network name may differ if the Compose project name is changed.

The target runs `/usr/sbin/sshd -D -e`. Analyst and client containers remain available using `sleep infinity`.

## 6. Four terminals

Keep one PowerShell window or tab for each terminal. Run commands from the repository root.

### Terminal 1 — Windows PowerShell

```powershell
Set-Location "C:\path\to\SSHOLE-OpenSSH-Security-Research"
docker compose ps
docker compose config
docker compose logs --tail 100 target
```

### Terminal 2 — Ubuntu Analyst

Open:

```powershell
docker compose exec analyst bash
```

Inside Ubuntu:

```bash
cat /etc/os-release
ldd --version
ssh -V
```

Run the inventory helper from Windows PowerShell:

```powershell
docker compose cp .\scripts\inventory-analyst.sh analyst:/tmp/inventory-analyst.sh
docker compose exec analyst bash /tmp/inventory-analyst.sh
```

The script reports OS, libc and SSH client version. Tools verified in the recorded environment: Bash, OpenSSH client, IP routing utilities and process inspection utilities. Netcat was not installed in the recorded Ubuntu image.

### Terminal 3 — Kali Client

Open:

```powershell
docker compose exec client bash
```

Inside Kali:

```bash
cat /etc/os-release
ssh -V
nc -h
```

The recorded Kali image included Bash, OpenSSH client, IP routing utilities and OpenBSD Netcat. Use only synthetic accounts and test keys.

### Terminal 4 — Alpine SSH Target

Open:

```powershell
docker compose exec target sh
```

Inside Alpine:

```sh
cat /etc/alpine-release
apk info -v openssh-server
/usr/sbin/sshd -V 2>&1
sshd -T | grep -Ei '^(passwordauthentication|usepam|permitrootlogin|kbdinteractiveauthentication) '
```

Run the target inventory helper from Windows PowerShell:

```powershell
docker compose cp .\scripts\inventory-target.sh target:/tmp/inventory-target.sh
docker compose exec target sh /tmp/inventory-target.sh
```

The script classifies shadow password field types without printing password hashes. The recorded target provides `sh`, `sshd` and `ssh-keygen`. Do not assume Python, Socat, Perl, Netcat or an SSH client is installed.

## 7. Baseline SSH policy

The documented baseline includes:

```text
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AllowTcpForwarding no
AllowAgentForwarding yes
DisableForwarding no
AllowStreamLocalForwarding yes
MaxStartups 10:30:100
MaxAuthTries 6
```

Inspect effective policy with `sshd -T`. Do not assume a configuration file alone establishes effective runtime policy.

## 8. Inventory and evidence tools

Run PowerShell scripts from the project root.

| Script | Purpose |
|---|---|
| `scripts/inventory-analyst.sh` | Analyst OS, libc and SSH client inventory |
| `scripts/inventory-target.sh` | Target OS, package, linkage and SSH policy inventory |
| `scripts/build-evidence-index.ps1` | Creates a SHA-256 inventory under evidence |
| `scripts/distribute-evidence.ps1` | Distributes session evidence into categories |
| `scripts/verify-manifest.ps1` | Verifies files listed in a compatible CSV manifest |
| `scripts/audit-project.ps1` | Checks required project files and directory counts |
| `scripts/audit-final.ps1` | Creates a project file inventory and duplicate report |

Examples:

```powershell
.\scripts\build-evidence-index.ps1
.\scripts\audit-project.ps1
.\scripts\audit-final.ps1
.\scripts\verify-manifest.ps1 -Manifest ".\path\to\manifest.csv"
```

The manifest verifier accepts path columns `Path`, `File`, or `Filename`, and hash columns `SHA256`, `Hash`, or `Checksum`.

Do not use original private manifests to verify sanitized publication copies. `publication-staging/PUBLICATION_MANIFEST.csv` is the integrity reference for sanitized publication files.

**Caution:** evidence scripts write under `evidence`. Do not run them against a publication copy unless you intentionally want new audit artifacts there.

## 9. Historical LOAD001–LOAD012

| LOAD | Scope |
|---|---|
| 001 | Connection handling |
| 002 | Sequential connections |
| 003 | Baseline telemetry |
| 004 | Concurrent connections |
| 005 | Post-test connectivity |
| 006 | Effective configuration |
| 007 | Authentication policy |
| 008 | Container security boundary |
| 009 | Defensive policy assessment |
| 010 | Agent forwarding |
| 011 | TCP and StreamLocal forwarding |
| 012 | Final documentation and evidence audit |

Detailed historical results are in `FINAL_RESEARCH_REPORT.md`, `docs/FINDINGS.md`, `docs/RESEARCH_PROTOCOL.md`, and `docs/LOGBOOK/`.

These are historical reports, not executable experiment scripts. Some stages used temporary accounts, additional sshd instances, alternate ports, or temporary configuration files not created by baseline Compose.

A repeat must record exact image identifiers/digests, package revisions, effective SSH configuration, synthetic account/key setup, commands, timestamps, exit codes, client/server output, evidence hashes, and deviations.

Do not claim a historical LOAD has been reproduced merely because the baseline containers start successfully.

## 10. Limitations

- The vulnerable OpenSSH package was not installed or tested.
- The reported password-authentication bypass was not reproduced.
- The Alpine target was a patched baseline.
- LOAD 007 did not test successful valid-key authentication.
- LOAD 010 did not perform a remote agent signing operation.
- LOAD 011 did not demonstrate end-to-end application data transfer.
- LOAD 005 did not measure recovery time after an actual penalty.
- The six historical SHA-256 manifests covered 27 listed files, not every project file.

Consult `docs/FINDINGS.md` and `docs/RESEARCH_PROTOCOL.md` before interpreting results.

## 11. Stop the laboratory

From the repository root:

```powershell
docker compose down --remove-orphans
docker compose ps -a
```

This removes Compose containers and network; it does not intentionally delete evidence directories. Do not delete evidence as part of routine teardown.

## 12. Image drift and strict reproduction

The Dockerfiles use upstream tags including `ubuntu:24.04`, `kalilinux/kali-rolling`, and `alpine:3.24`. Tags such as `kali-rolling` can change. A new build may install different package revisions from those recorded historically.

For strict reproduction, record image digests and package versions at build time. Do not describe a new environment as identical to the historical one unless equivalence has been verified.

## 13. Research integrity

SSHOLE distinguishes observed behavior, vendor-confirmed statements, inference and untested conditions. The absence of a successful vulnerability reproduction is an explicit research result. The laboratory is intended for defensive configuration research, controlled SSH behavior analysis and evidence-based security documentation.
