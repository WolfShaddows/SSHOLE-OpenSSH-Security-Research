# Environment Verification — 2026-11-08

## Purpose

This document records a post-experiment verification of the SSHOLE Docker environment performed on 2026-11-08.

These observations are supplementary to LOAD001–LOAD012. They do not modify, replace, or retroactively validate historical experiment results.

## Verified environment

| Component | Operating system | OpenSSH | Result |
|---|---|---|---|
| Analyst | Ubuntu 24.04.5 LTS | 9.6p1 Ubuntu-3ubuntu13.20 | Verified |
| Client | Kali GNU/Linux Rolling 2026.3 | 10.6p1 Debian-1 | Verified |
| Target | Alpine Linux 3.24.4 | 10.3_p1-r2 (openssh-server) | Verified |

## Additional runtime observations

### Ubuntu Analyst

- GLIBC: 2.39-0ubuntu8.9
- OpenSSL: 3.0.13
- SSH client version obtained using `ssh -V`.

### Kali Client

- OpenSSL: 3.6.5
- SSH client version obtained using `ssh -V`.

### Alpine Target

- Architecture: x86_64
- C library: musl
- OpenSSH server package revision: 10.3_p1-r2
- Package revision obtained from the local APK database: `/lib/apk/db/installed`
- The query did not require external package-index access.

The Alpine inventory also confirmed these effective settings:

- PermitRootLogin: no
- PasswordAuthentication: no
- KbdInteractiveAuthentication: no

The shadow inventory reported account-field classes only. No password hashes were printed.

## Verification method

The checks were performed against the running Docker Compose services:

- `analyst`
- `client`
- `target`

The Ubuntu and Alpine inventory scripts were copied into their respective containers and executed there.

The Kali and Ubuntu client versions were queried directly with `ssh -V`.

The Alpine package revision was queried from its local APK database. An attempted APK index refresh produced transient DNS errors; the local database query succeeded independently.

## Scope and limitations

This is an operator-executed verification of the environment at the time recorded above.

It is not a new LOAD experiment, a historical package-state reconstruction, or an independent reproduction of the reported OpenSSH password-authentication bypass.

The reported bypass was not reproduced in this laboratory. The Alpine 3.24 branch fixed package listed by the official Alpine advisory is 10.3_p1-r2. The locally observed target package revision matches that vendor-listed revision. The Alpine target package revision is recorded as observed; the security significance of that revision must be interpreted against the official vendor advisory and release documentation.

## Official references

- OpenSSH release notes: https://www.openssh.org/releasenotes.html
- Alpine OpenSSH password-authentication bypass advisory: https://www.alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/
- Alpine release announcement: https://www.alpinelinux.org/posts/alpine-3.21.10-3.22.8-3.23.8-3.24.4-released/

## Evidence classification

Classification: supplementary environment verification.

Historical experiment reports remain unchanged.
