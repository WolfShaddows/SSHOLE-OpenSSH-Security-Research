# SSHOLE PROJECT — LOAD 006
## Configuration Behavior & Effective Security Policy

Session: SSHOLE_LOAD_006_20261108_103425
Status: COMPLETED

### Verified observations

- Ubuntu DNS resolution: target -> 172.23.0.3.
- Ubuntu TCP probes: 3/3 successful.
- Kali default policy differs from its explicit test policy.
- Alpine password authentication: disabled.
- Alpine keyboard-interactive authentication: disabled.
- Alpine public-key authentication: enabled.
- Alpine root login: prohibited.
- Alpine MaxAuthTries: 6.
- Alpine MaxStartups: 10:30:100.

### Context comparison

The effective configurations for root/Kali and labuser/Ubuntu
were byte-identical according to their SHA-256 hashes.

### Limitations

This experiment evaluated effective configuration and TCP reachability.
It did not dynamically test every authentication method.
No vulnerability or authentication bypass was demonstrated.

### Evidence

The session evidence is stored under:
evidence/sessions/SSHOLE_LOAD_006_20261108_103425/

SHA-256 manifest generated after the final report.
