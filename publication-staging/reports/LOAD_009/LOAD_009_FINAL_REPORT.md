# SSHOLE PROJECT
## LOAD 009 — Defensive Policy Assessment

### Session
SSHOLE_LOAD_009_20261108_112806

### Objective
Evaluate the effective SSH security policy under the existing baseline
and compare it with a candidate defensive policy that disables forwarding.

### Environment
- Target: Alpine Linux
- Hostname: sshole-target
- SSH daemon: OpenSSH
- Network: isolated Docker lab network
- Target address: 172.23.0.3

### Baseline effective policy
- PermitRootLogin: no
- PasswordAuthentication: no
- KbdInteractiveAuthentication: no
- X11Forwarding: no
- AllowTcpForwarding: no
- AllowAgentForwarding: yes
- DisableForwarding: no
- AllowStreamLocalForwarding: yes

### Candidate effective policy
Evaluated using query-time sshd options:
- DisableForwarding yes
- AllowAgentForwarding no
- AllowStreamLocalForwarding no

Observed candidate:
- PermitRootLogin: no
- PasswordAuthentication: no
- KbdInteractiveAuthentication: no
- X11Forwarding: no
- AllowTcpForwarding: no
- AllowAgentForwarding: no
- DisableForwarding: yes
- AllowStreamLocalForwarding: no

### Findings
1. The candidate policy reduces the effective forwarding capabilities
   reported by sshd -T.
2. Authentication-related settings remain unchanged between baseline
   and candidate.
3. The original configuration passes sshd -t.
4. The SSH daemon remains active as PID 1 during the inspection.
5. Candidate settings were evaluated as command-line overrides only.
   No persistent configuration file or running daemon configuration
   was modified.

### Limitations
- No forwarding session was attempted.
- No runtime enforcement behavior was tested.
- The candidate policy was not deployed.
- This assessment does not demonstrate an authentication bypass
  or a vulnerability.
- Results describe the inspected lab configuration only.

### Evidence
- POLICY-COMPARISON.txt

SHA-256:
60FAB367BA6B00E205E5CF8925A2651CF438FACC14408E33A98D76F241FF8C36

### Conclusion
LOAD 009 confirms that a stricter forwarding policy can be represented
in the effective sshd configuration without changing the inspected
authentication settings.

The result is a configuration-level assessment, not a runtime
security enforcement test.

Status: COMPLETED