# Research protocol

## Purpose
Document the methodology used in SSHOLE-2026-001 and distinguish the original planned vulnerability-reproduction workflow from the experiments actually completed.

## Evidence classifications
- **Observed:** directly captured in this laboratory.
- **Vendor-confirmed:** stated by OpenSSH or Alpine.
- **Inferred:** reasoned from observations and explicitly qualified.
- **Not tested:** outside the completed scope.

Record timestamps, package versions, commands, exit codes and relevant logs where available. Redact secrets and personal data.

## Original planned workflow
1. Record host and container environment.
2. Inventory target package, libc and effective sshd configuration.
3. Verify every vendor advisory precondition.
4. Acquire an exact affected Alpine package/image from official sources and record its digest.
5. Perform controlled reproduction inside the internal network.
6. Repeat against the fixed build using identical inputs.
7. Validate mitigations and archive sanitized evidence.
8. Tear down disposable containers.

## Actual execution and deviation
The target was Alpine Linux 3.24.4 with musl libc and OpenSSH packages recorded at revision `10.3_p1-r2`. The Alpine advisory dated 2026-11-05 identifies that revision as fixed for the Alpine 3.24 branch.

The target was classified as a patched baseline. The project did not qualify or install a vulnerable package build and did not perform a vulnerable-versus-patched reproduction.

Instead, the completed experiments examined connection handling, authentication policy, defensive configuration, container boundaries, agent forwarding and TCP/StreamLocal forwarding behavior. This deviation must remain visible in research summaries.

## Completed experiment sequence
| Experiment | Scope | Summary |
|---|---|---|
| LOAD 001 | Connection handling | Source-based penalty observed in server logs |
| LOAD 002 | Sequential connections | Expected authentication rejections; no penalty event in supplied logs |
| LOAD 003 | Baseline telemetry | Connectivity and resource observations recorded |
| LOAD 004 | Concurrent connections | 12 expected authentication rejections; no unexpected success |
| LOAD 005 | Recovery | Five post-test TCP probes succeeded; post-penalty recovery time not measured |
| LOAD 006 | Configuration | Effective security policy and package context documented |
| LOAD 007 | Authentication | Public-key-only rejection behavior observed; valid-key acceptance not tested in this experiment |
| LOAD 008 | Security boundary | Container isolation and hardening controls inspected |
| LOAD 009 | Defensive policy | Candidate restrictions assessed at configuration level |
| LOAD 010 | Agent forwarding | Remote agent socket present in baseline session and absent in candidate session |
| LOAD 011 | Forwarding | TCP attempts denied; baseline StreamLocal request denied and isolated control accepted |
| LOAD 012 | Final audit | Documentation and manifest-listed evidence integrity review |

## Experiment-specific qualifications

### LOAD 001–005
These experiments examined connection behavior, sequential/concurrent traffic, telemetry and post-test connectivity. The source-based penalty is an observation from LOAD 001. LOAD 004's broad log collection window does not establish that LOAD 004 itself triggered a penalty. LOAD 005 did not measure recovery time after an actual penalty event.

### LOAD 006–009
These experiments documented effective configuration, authentication policy, container security boundaries and defensive configuration candidates. LOAD 009 was a configuration-level assessment; its candidate restrictions were not a forwarding runtime result at that stage.

### LOAD 010
The same Ed25519 key authenticated successfully to baseline port 22 and candidate port 2222. The baseline remote session exposed `SSH_AUTH_SOCK`; the candidate session did not. No remote agent signing operation or cryptographic agent query was performed.

### LOAD 011
Local TCP forwarding attempts were denied by both baseline and candidate server policies. The intended analyst-side TCP endpoint was not listening, and no data transfer was demonstrated.

For remote StreamLocal forwarding, the baseline denied the tested request and the remote socket was absent. An isolated control with effective `AllowTcpForwarding yes` accepted the request and created the remote socket. No end-to-end application data exchange was demonstrated.

## Integrity audit
The corrected LOAD 012 verifier reported 27 SHA256 matches across six experiment manifests:

| Manifest | Verified files |
|---|---:|
| LOAD 006 | 7/7 |
| LOAD 007 | 2/2 |
| LOAD 008 | 5/5 |
| LOAD 009 | 2/2 |
| LOAD 010 | 4/4 |
| LOAD 011 | 7/7 |
| **Total** | **27/27** |

This check covers only files listed in those six manifests. It is not a repository-wide integrity assertion.

## Future affected-build qualification
Any future reproduction attempt must first identify the exact affected Alpine package revision from official sources, record and verify package/image digests, independently confirm every advisory precondition, use only a disposable isolated environment and synthetic test data, capture client and server evidence, and repeat against the fixed build with identical inputs.

No test should be described as a reproduction until the affected build and all preconditions are independently verified.

## Teardown
```powershell
docker compose down --remove-orphans
```
Record final image/package state and archive sanitized evidence before teardown.
