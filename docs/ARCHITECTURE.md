# Architecture

## Implemented topology
```text
Windows host (Docker Desktop)
└── Docker network: labnet [internal=true; no published ports]
    ├── target       Alpine / OpenSSH server
    ├── analyst      Ubuntu / inventory, configuration and log review
    └── client       Kali / controlled SSH client
```

## Roles
- **Alpine target:** disposable SSH server using the recorded patched baseline.
- **Ubuntu analyst:** collects OS, libc, OpenSSH build, effective sshd configuration, logs and evidence.
- **Kali client:** generates controlled SSH traffic inside the laboratory.
- **Windows host:** orchestrates Docker containers; SSH is not published to host interfaces.

## Recorded network addresses
| Container | Address |
|---|---|
| Ubuntu analyst | `172.23.0.2` |
| Alpine target | `172.23.0.3` |
| Kali client | `172.23.0.4` |

These addresses describe the recorded instance and should not be assumed for a recreated deployment.

## Target baseline
- Alpine Linux 3.24.4.
- musl libc, x86_64.
- OpenSSH packages at revision `10.3_p1-r2`.
- Baseline SSH service on container port 22.
- Candidate sshd configuration used on port 2222 in later defensive experiments.

The system inventory records the installed revisions. The Alpine advisory dated 2026-11-05 identifies `10.3_p1-r2` as fixed for the Alpine 3.24 branch. The target is classified as a patched baseline.

## Container hardening
Recorded controls:
- `privileged=false`
- `cap_drop: ALL`
- Explicit capability additions.
- `no-new-privileges:true`
- `/run` and `/tmp` temporary filesystem mounts.
- No published host port.

`SYS_CHROOT` was added to the target capability set after sshd privilege separation failed without it. These settings document the tested configuration; they do not prove immunity to every container escape or host compromise.

## Implemented research stages
1. Environment and package inventory.
2. Baseline connectivity and connection behavior.
3. Sequential and concurrent SSH connection observations.
4. Recovery checks and defensive configuration inspection.
5. Authentication policy inspection.
6. Container security-boundary inspection.
7. Agent-forwarding runtime comparison.
8. TCP and StreamLocal forwarding policy comparison.
9. Evidence integrity and documentation audit.

## Planned but not completed
The original design called for acquiring an exact affected package build from official Alpine sources, verifying all advisory preconditions, and performing a controlled vulnerable-versus-patched comparison.

That comparison was not completed. The target package was already at the fixed Alpine 3.24 revision. No vulnerable package was installed, and no bypass reproduction is claimed.

## Safety controls
The work was restricted to disposable containers and a private internal Docker network. Synthetic accounts and test keys were used. No external or third-party target was tested.
