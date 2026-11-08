# SSHOLE PROJECT — LOAD 010
## SSH Agent Forwarding Runtime Validation

**Session:** SSHOLE_LOAD_010_20261108_113500
**Date:** 2026-11-08
**Status:** COMPLETED — EVIDENCE PRESERVED

---

## 1. Objective

Compare the runtime behavior of SSH agent forwarding between:

- Baseline OpenSSH instance on TCP port 22.
- Candidate OpenSSH instance on TCP port 2222.

Both instances ran inside the same Alpine target container, using the same synthetic account and authorized Ed25519 public key.

The objective was to determine whether the candidate defensive configuration prevented the creation of a remote agent-forwarding socket.

## 2. Environment

- Target: Alpine Linux 3.24.4.
- C library: musl.
- OpenSSH server package: 10.3_p1-r2.
- Client: Kali GNU/Linux Rolling 2026.3.
- OpenSSH client: 10.6p1.
- Network: isolated Docker internal network.
- Account: labuser, UID/GID 1000.
- Authentication: Ed25519 public key.
- SSH password authentication: disabled.

The private key remained on the Kali client.

## 3. Configuration comparison

| Directive | Baseline | Candidate |
|---|---|---|
| Port | 22 | 2222 |
| PubkeyAuthentication | yes | yes |
| PasswordAuthentication | no | no |
| AllowTcpForwarding | no | no |
| AllowAgentForwarding | yes | no |
| DisableForwarding | no | yes |
| AllowStreamLocalForwarding | yes | no |

The candidate configuration was independently validated with `sshd -t`.

Both SSHD processes remained active during the comparison.

## 4. Authentication validation

The same Ed25519 identity was used against both instances.

Observed results:

- Baseline public-key login: successful.
- Candidate public-key login: successful.
- Candidate server log recorded acceptance of the expected Ed25519 fingerprint.
- The candidate configuration did not require enabling password authentication.

The account initially encountered an account-lock restriction. A random temporary password hash was subsequently assigned to the synthetic account so that OpenSSH would permit public-key authentication. SSH password authentication remained disabled in both configurations.

## 5. Agent forwarding runtime observations

The Kali client confirmed that its local SSH agent contained the expected Ed25519 identity.

### Baseline — TCP 22

- SSH_AUTH_SOCK was defined in the remote session.
- The referenced path was a UNIX socket.
- The socket existed.
- Socket permissions were `srw-------`.
- Socket owner was `labuser`.

Result: `BASELINE_SOCKET_PRESENT`.

### Candidate — TCP 2222

- SSH_AUTH_SOCK was not defined.
- No remote agent socket was detected.

Result: `CANDIDATE_SOCKET_ABSENT`.

The socket comparison was captured in the client evidence file.

## 6. Findings

The experiment demonstrates a runtime difference in remote agent-forwarding socket availability between the baseline and candidate SSH configurations.

The baseline permitted creation of the remote agent socket.

The candidate configuration, with AllowAgentForwarding disabled and DisableForwarding enabled, did not expose an SSH_AUTH_SOCK in the remote session.

This is evidence of the expected defensive configuration behavior at the SSH session/socket level.

## 7. Limitations

The following were not demonstrated:

- End-to-end remote agent protocol queries using remote `ssh-add`.
- A remote cryptographic signing operation through the forwarded agent.
- Runtime TCP forwarding behavior.
- Runtime stream-local forwarding behavior.
- Any authentication bypass or exploitation of the SSHOLE vulnerability.

The Alpine target did not have the `ssh-add` client utility installed. Therefore, socket availability must not be interpreted as proof of a completed remote agent signing operation.

The experiment compared two SSHD instances in the same container, not two independent operating systems.

## 8. Security interpretation

The results support the use of explicit forwarding restrictions as a defensive hardening measure.

The candidate policy reduced the forwarding surface exposed to the authenticated session compared with the baseline configuration.

The experiment does not establish that the baseline is vulnerable or that the candidate fixes the SSHOLE authentication bypass.

The target package revision is the patched Alpine revision documented in the project research baseline.

## 9. Evidence inventory

- `comparisons/AGENT_SOCKET_COMPARISON.txt`
- `target/FINAL_RUNTIME_REPORT.txt`
- `target/sshd_candidate.conf`

SHA-256 integrity verification was completed after extraction from the containers.

## 10. Conclusion

LOAD 010 successfully demonstrated and documented a difference in SSH agent-forwarding socket exposure between baseline and candidate configurations.

Authentication using the same authorized Ed25519 identity succeeded against both instances.

The result is a defensive runtime configuration validation, not a vulnerability reproduction.

**Final status: COMPLETED.**
