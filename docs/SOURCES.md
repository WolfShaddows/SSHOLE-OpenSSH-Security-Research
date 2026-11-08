# Official sources and attribution

**Research case:** SSHOLE-2026-001<br>
**Source access date:** 2026-11-08

This bibliography prioritizes first-party material from the OpenSSH and Alpine Linux projects. The vulnerability description, affected conditions, fixed package revisions, and upstream workaround below are attributed to those official sources. Laboratory observations are attributed separately to SSHOLE evidence and reports.

## Primary official sources

1. **OpenSSH Project — OpenSSH 10.6p2 Release Notes (2026-11-05).** Documents the security workaround in `sshd` for a password-authentication bypass affecting some Linux systems built and run with PAM support disabled. The release notes describe the root cause as outside `sshd`, while noting that the issue is exploitable through `sshd` and can be avoided there.<br>
   https://www.openssh.org/releasenotes.html

2. **Alpine Linux — Security advisory: openssh-server password authentication bypass (2026-11-05).** Official advisory describing the affected configuration, account-shadow conditions, password-length range, musl `crypt()` behavior, mitigations, affected branches, and fixed package revisions. For Alpine 3.24, the advisory lists `10.3_p1-r2` as fixed. It also states that no CVE identifier had been assigned at publication time.<br>
   https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/

3. **Alpine Linux — Alpine 3.21.10, 3.22.8, 3.23.8 and 3.24.4 released (2026-11-05).** Official stable-release announcement confirming that these releases include the OpenSSH server password-authentication-bypass fix and directing readers to the security advisory.<br>
   https://www.alpinelinux.org/posts/alpine-3.21.10-3.22.8-3.23.8-3.24.4-released/

4. **OpenSSH Project — Official project homepage.** Confirms the Portable OpenSSH 10.6p2 release date and links to official release information.<br>
   https://www.openssh.org/

## Attribution of project observations

- The Alpine target package revision `10.3_p1-r2` is recorded in `docs/LOGBOOK/02_SYSTEM_INVENTORY.md`; the Alpine advisory identifies it as the fixed revision for the 3.24 branch.
- LOAD 001–012 results are SSHOLE laboratory observations. They are not vendor-confirmed vulnerability reproductions.
- The LOAD 012 integrity result applies to 27 files listed in six experiment manifests, not every file in the repository.

## Citation discipline

- Use the OpenSSH release notes for the upstream 10.6p2 workaround.
- Use the Alpine security advisory for affected conditions, technical mechanism, mitigations, and fixed package versions.
- Use the Alpine stable-release announcement as corroboration that the 3.24.4 release includes the fix.
- Use SSHOLE reports, logbooks, and evidence manifests for laboratory observations.
- Distinguish vendor-confirmed facts from direct observations, inference, and untested claims.
- Do not describe SSHOLE as having reproduced the bypass, tested an affected build, or independently disproved the vulnerability.
- Do not assign a CVE identifier: the Alpine advisory stated that none had been assigned at publication time.


## Official vendor references

- [Alpine Linux security advisory: OpenSSH password-authentication bypass (2026-11-05)](https://www.alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/)
