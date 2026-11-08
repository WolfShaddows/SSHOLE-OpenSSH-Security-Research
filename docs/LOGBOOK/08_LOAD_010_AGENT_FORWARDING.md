# LOAD 010 — SSH Agent Forwarding Runtime Validation

**Date:** 2026-11-08<br>
**Session:** SSHOLE_LOAD_010_20261108_113500<br>
**Status:** COMPLETED

## Objective

Compare baseline SSH agent forwarding with a candidate hardened SSH configuration using the same synthetic account and Ed25519 identity.

## Runtime configuration

Baseline:
- Port 22
- AllowAgentForwarding yes
- DisableForwarding no
- AllowTcpForwarding no
- AllowStreamLocalForwarding yes

Candidate:
- Port 2222
- AllowAgentForwarding no
- DisableForwarding yes
- AllowTcpForwarding no
- AllowStreamLocalForwarding no

## Observations

1. Public-key authentication succeeded against both instances.
2. The baseline remote session exposed SSH_AUTH_SOCK as a UNIX socket.
3. The candidate remote session did not expose SSH_AUTH_SOCK.
4. The same client identity was used for both tests.
5. The candidate configuration passed SSHD syntax validation.

## Limitations

No remote agent query or signing operation was performed because the target did not have the ssh-add client utility installed.

TCP forwarding and stream-local forwarding were not tested at runtime.

No authentication bypass was demonstrated.

## Conclusion

The experiment demonstrated a runtime difference in agent-forwarding socket availability between the baseline and candidate configurations.

This is a defensive policy validation, not a reproduction of the SSHOLE vulnerability.

Evidence and hashes are preserved in the corresponding LOAD 010 session directory.
