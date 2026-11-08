# SSHOLE PROJECT — LOAD 006
## Configuration Behavior & Effective Security Policy

Session: SSHOLE_LOAD_006_20261108_103425

### Infrastructure
Three Docker nodes:
- Ubuntu Analyst
- Kali Client
- Alpine SSH Target

### Ubuntu observations
- DNS resolution: target resolved to 172.23.0.3.
- TCP probes: 3 successful, 0 failed.

### Kali observations
Default client configuration:
- PasswordAuthentication: yes
- KbdInteractiveAuthentication: yes
- StrictHostKeyChecking: ask

Explicit test configuration:
- PasswordAuthentication: no
- KbdInteractiveAuthentication: no
- PreferredAuthentications: publickey
- StrictHostKeyChecking: yes

### Alpine effective configuration
- PermitRootLogin: no
- PubkeyAuthentication: yes
- PasswordAuthentication: no
- KbdInteractiveAuthentication: no
- MaxAuthTries: 6
- MaxStartups: 10:30:100
- AuthenticationMethods: any

### Context comparison
The root/Kali and labuser/Ubuntu effective configuration files
have identical SHA-256 hashes.

### Findings
The server policy is consistent across the two evaluated contexts.
The default Kali client preferences differ from the server policy.
The explicit Kali test configuration aligns with the disabled
password and keyboard-interactive methods.

### Limitations
This experiment evaluates effective configuration and TCP reachability.
It does not dynamically test every authentication method.
The package evidence records package names; exact installed revisions
must be taken from the separate system inventory.
No vulnerability or authentication bypass is demonstrated.

Status: CONFIGURATION AUDIT COMPLETED
