# SSHOLE PROJECT — LOAD 007
## Authentication Policy Validation

Session: SSHOLE_LOAD_007_20261108_110253
Status: COMPLETED — OBSERVATIONS RECORDED

### Test scenarios

1. Password authentication request.
2. Keyboard-interactive authentication request.
3. Public-key authentication negotiation without a valid key.

### Kali client observations

- Three SSH connections established.
- Server advertised publickey as the available authentication method.
- All three attempts ended with Permission denied (publickey).
- No successful authentication was observed.
- SSH exit code: 255 in all three scenarios.

### Alpine server observations

- Three root pre-authentication connection closures from 172.23.0.4.
- Source address corresponds to Kali Client.
- Events occurred between 14:08:08 and 14:08:09 UTC.
- No source-limit penalty appears in the collected log window.

### Findings

The client-side negotiation output and server-side connection records
are consistent with three rejected authentication sessions.

### Limitations

Server logs identify the connections but do not identify the requested
authentication method for each individual closure.

No valid public key was presented. Public-key authentication acceptance
was therefore not tested.

No successful login or authentication bypass was demonstrated.

### Evidence

- ALPINE-SSH-LOGS.log
- Operator-observed Kali negotiation output.
- LOAD 007 network precheck screenshot.

Final status: AUTHENTICATION VALIDATION COMPLETED.
