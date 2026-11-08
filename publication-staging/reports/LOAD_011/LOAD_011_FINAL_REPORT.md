# SSHOLE LOAD 011 — Forwarding Policy and StreamLocal Runtime Validation

**Project:** SSHOLE Project
**Experiment:** LOAD 011
**Date:** 2026-11-08
**Environment:** Isolated Docker laboratory
**Target OS:** Alpine Linux 3.24.4
**SSH server runtime:** OpenSSH_10.3p1
**Status:** Experimental validation completed

---

## 1. Objective

Evaluate SSH forwarding behavior under different server-side policies, with particular attention to TCP forwarding and Remote StreamLocal forwarding.

The experiment compares the original baseline, a defensive candidate configuration, a positive control, and an isolated control that changes only the `AllowTcpForwarding` directive relative to the baseline.

The experiment is limited to configuration and runtime behavior. It is not an authentication-bypass test.

## 2. Laboratory topology

The experiment used the existing isolated Docker laboratory:

- Kali client: 172.23.0.4
- Alpine SSH target: 172.23.0.3
- Ubuntu analyst: 172.23.0.2
- Docker network: internal laboratory network
- SSH authentication: Ed25519 public key
- Test account: `labuser`

No host SSH port was published for external access.

## 3. Configurations

| Instance | Port | AllowTcpForwarding | AllowStreamLocalForwarding | DisableForwarding | AllowAgentForwarding |
|---|---:|---|---|---|---|
| Baseline | 22 | no | yes | no | yes |
| Candidate | 2222 | no | no | yes | no |
| Positive control | 2223 | yes | yes | no | no |
| Isolated control | 2224 | yes | yes | no | yes |

The isolated control was derived from the baseline configuration. Its effective configuration was checked with `sshd -T -C`.

The isolated comparison changed only `AllowTcpForwarding` from `no` to `yes`, while preserving the other compared effective forwarding directives.

## 4. TCP forwarding observations

The initial TCP forwarding tests attempted local forwarding against an analyst-side endpoint.

Both baseline and candidate returned:

`channel 1: open failed: administratively prohibited: open failed`

The target server logs also recorded refused local port-forward requests.

The analyst-side endpoint was not confirmed listening during the test. Therefore, no successful end-to-end TCP data transfer was demonstrated.

The result supports the observation that both server configurations rejected the tested forwarding requests. It does not establish endpoint reachability or successful data transfer.

## 5. StreamLocal forwarding observations

### 5.1 Initial comparison

The initial Remote StreamLocal tests showed:

- Baseline: request rejected.
- Candidate: request rejected.
- Positive control: request accepted.

The positive control differed from the baseline in more than one effective directive. It was therefore treated as preliminary evidence, not as an isolated causal comparison.

### 5.2 Isolated control

A fourth SSHD instance was started on port 2224.

Its effective configuration was verified:

- `AllowTcpForwarding yes`
- `AllowStreamLocalForwarding yes`
- `DisableForwarding no`
- `AllowAgentForwarding yes`

The baseline retained:

- `AllowTcpForwarding no`
- `AllowStreamLocalForwarding yes`
- `DisableForwarding no`
- `AllowAgentForwarding yes`

The same Ed25519 key authenticated successfully to both instances.

Observed client results:

**Baseline, port 22**

`remote forward failure`

`Error: remote port forwarding failed for listen path ...`

**Isolated control, port 2224**

`remote forward success`

The target-side socket check showed:

- Baseline socket: absent.
- Isolated control socket: present.

The socket metadata reported:

- Type: UNIX socket
- Owner: `labuser`
- UID: 1000
- GID: 1000
- Permissions: `0600`

This provides two independent observations: SSH client acceptance of the remote forwarding request and existence of the corresponding UNIX socket on the target filesystem.

## 6. Main finding

Within this laboratory configuration and OpenSSH runtime, changing only the effective `AllowTcpForwarding` value from `no` to `yes` changed the outcome of the tested Remote StreamLocal forwarding request.

With the baseline policy, the request was rejected and the remote socket was absent.

With the isolated control policy, the request was accepted and the remote socket was created.

This is an experimentally observed configuration-dependent behavior in this environment. The report does not generalize the result to all OpenSSH versions or distributions.

## 7. Limitations

The experiment did not demonstrate:

- A password-authentication bypass.
- An authentication vulnerability.
- Unauthorized account access.
- Successful end-to-end data transfer through the StreamLocal socket.
- A complete application-level UNIX socket exchange.
- Identical behavior across other OpenSSH releases or operating systems.

The TCP endpoint was not confirmed listening during the initial TCP forwarding tests.

The package revision query could not independently retrieve the Alpine package revision during the final capture because APK index access encountered transient DNS errors. The runtime version reported by `sshd -V` was `OpenSSH_10.3p1`.

The socket verification establishes filesystem socket creation, not successful communication through that socket.

## 8. Evidence inventory

Evidence directory:

`evidence/sessions/SSHOLE_LOAD_011_20261108/`

Files:

- `STREAMLOCAL_BASELINE_FINAL.log`
- `STREAMLOCAL_ISOLATED_CONTROL_FINAL.log`
- `STREAMLOCAL_ISOLATED_SERVER.log`
- `STREAMLOCAL_SOCKET_METADATA.txt`
- `TCP_BASELINE_SERVER_LOG.txt`
- `TCP_CANDIDATE_SERVER_LOG.txt`
- `TCP_CLIENT_RESULTS.txt`
- `LOAD_011_SHA256.csv`

The SHA-256 manifest records seven exported evidence files.

Integrity verification result:

`INTEGRITY=VERIFIED`

`FILES_VERIFIED=7`

The manifest itself is not included in its own hash list.

## 9. Conclusion

LOAD 011 completed its forwarding-policy runtime comparison.

The isolated control provides evidence that the effective `AllowTcpForwarding` setting influenced the acceptance of Remote StreamLocal forwarding in the tested environment.

The result is limited to the observed configuration and runtime. It is not a vulnerability reproduction or an authentication bypass.

All seven exported evidence files passed SHA-256 integrity verification at the time of validation.

**Final status:** COMPLETED — configuration/runtime observations documented; limitations retained.
