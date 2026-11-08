# SSHOLE — System Inventory
## Session 002 — 2026-11-08

Project: DARKSHADOWS GROUP / SSHOLE
Session ID: 20261108_073035
Status: COMPLETED

### 1. Configuration correction

Removed unsupported UsePAM directive from the Alpine SSH configuration.

File:
containers/target/Dockerfile

Effective configuration:
- PermitRootLogin no
- PasswordAuthentication no
- KbdInteractiveAuthentication no

Build result: SUCCESS

Container recreation: SUCCESS

### 2. Ubuntu Analyst inventory

Observed:
- Distribution: Ubuntu
- GLIBC: 2.39
- OpenSSH Client: 9.6p1
- OpenSSL: 3.0.13

Evidence:
evidence/sessions/SSHOLE_20261108_073035.log

### 3. Alpine Target inventory

Observed:
- Alpine Linux: 3.24.4
- openssh-keygen: 10.3_p1-r2
- openssh-server: 10.3_p1-r2
- openssh-server-common: 10.3_p1-r2
- Runtime libc: musl x86_64

### 4. SSH configuration

Observed effective settings:
- passwordauthentication no
- kbdinteractiveauthentication no

SSH daemon:
- Listening on 0.0.0.0:22
- Listening on :::22
- No unsupported UsePAM warning after correction.

### 5. Network

Previous session established:
- Kali resolves target through Docker DNS.
- Kali connects to target TCP port 22.
- Connection succeeded.

### 6. Security research finding

IMPORTANT:

Alpine 3.24.4 ships openssh-server 10.3_p1-r2.

According to the Alpine security advisory published on 2026-11-05, this is the fixed package revision for the Alpine 3.24 branch.

Therefore, the current target is classified as PATCHED BASELINE.

This environment must not be represented as a vulnerable reproduction.

### 7. Limitations

Not yet collected:
- Ubuntu /etc/os-release output.
- Fresh Kali system inventory.
- Historical vulnerable package verification.
- Controlled before/after authentication comparison.

### 8. Session conclusion

Infrastructure configuration correction completed.
Ubuntu and Alpine runtime identification completed.
musl detection confirmed.
Defensive SSH configuration verified.

Next milestone:
Historical vulnerable build qualification and isolated comparative testing.

### 9. References

OpenSSH 10.6p2 Release Notes:
https://www.openssh.org/releasenotes.html

Alpine Security Advisory:
https://www.alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/


### 10. Exact package revision verification

Verification date: 2026-11-08

Command:
apk info -v | grep -E '^openssh-(server|server-common|keygen)-'

Installed packages:
- openssh-keygen-10.3_p1-r2
- openssh-server-10.3_p1-r2
- openssh-server-common-10.3_p1-r2

Result: CONFIRMED

The installed package revision matches the fixed Alpine 3.24
revision documented in the official security advisory.

DNS warnings occurred while apk attempted to refresh remote
package indexes. Local installed-package information was
successfully retrieved.

Classification:
PATCHED BASELINE — CONFIRMED

Evidence:
evidence/sessions/SSHOLE_20261108_073644.log


## 11. SSH connection failure — privilege separation diagnosis

Date: 2026-11-08
Status: ROOT CAUSE HYPOTHESIS IDENTIFIED
Configuration modified: NO

### Observed behavior

- Ubuntu resolves the Alpine target.
- Ubuntu reaches TCP port 22.
- Kali resolves the Alpine target.
- Kali establishes TCP connectivity to port 22.
- SSH negotiation is interrupted before authentication.

### Server log evidence

Observed Alpine SSH daemon messages:

chroot("/var/empty"): Operation not permitted [preauth]

### Target container status

- Container: ssholeproject-target-1
- Service: target
- State: Up
- SSH listener: 0.0.0.0:22 and [::]:22
- SSH configuration validation: SUCCESS

### Existing capability configuration

cap_drop: ALL

cap_add:
- CHOWN
- SETUID
- SETGID
- DAC_OVERRIDE
- NET_BIND_SERVICE

### Technical hypothesis

The SSH daemon cannot perform the chroot operation required
by its privilege-separation process.

Missing SYS_CHROOT capability is the leading hypothesis.

This has not yet been experimentally confirmed.

### Evidence

evidence/sessions/SSHOLE_DIAGNOSTIC_20261108_074502.log

### Next action

Inspect effective container capabilities.
If confirmed, add SYS_CHROOT only to the target service.
Recreate target and repeat controlled SSH connectivity tests.

No changes to the patched OpenSSH package or authentication
configuration are authorized during this diagnostic stage.


## 12. SSH privilege-separation correction

Date: 2026-11-08
Session: 20261108_074903
Status: CONFIGURATION CHANGE SUCCESSFUL

### Original problem

OpenSSH reported:

chroot("/var/empty"): Operation not permitted [preauth]

### Root cause

The target container had dropped all Linux capabilities
and had not explicitly restored SYS_CHROOT.

Docker inspection confirmed its absence.

### Corrective action

Added SYS_CHROOT to the target service capabilities.

Previous configuration:
cap_drop: [ALL]
cap_add: [CHOWN, SETUID, SETGID, DAC_OVERRIDE, NET_BIND_SERVICE]

Updated configuration:
cap_drop: [ALL]
cap_add: [CHOWN, SETUID, SETGID, DAC_OVERRIDE, NET_BIND_SERVICE, SYS_CHROOT]

### Backup

evidence/sessions/docker-compose.before-SYS_CHROOT.20261108_074903.yml

### Validation

- Docker Compose configuration: SUCCESS
- Target recreation: SUCCESS
- Effective SYS_CHROOT capability: CONFIRMED
- SSH daemon startup: SUCCESS
- SSH configuration validation: SUCCESS
- No chroot error in post-recreation startup logs.

### Security considerations

The correction preserves:
- cap_drop ALL
- no-new-privileges:true

Only SYS_CHROOT was added.

### Evidence

evidence/sessions/SSHOLE_CAPABILITY_FIX_20261108_074903.log

### Pending verification

Repeat SSH protocol negotiation from Kali.
Confirm successful SSH handshake and expected authentication rejection.


## 13. SSH protocol negotiation — successful progress

Date: 2026-11-08

### Test environment

Client:
- Kali GNU/Linux Rolling 2026.3
- OpenSSH 10.6p1

Server:
- Alpine Linux 3.24.4
- OpenSSH 10.3
- Package revision 10.3_p1-r2
- musl x86_64

### Observed results

- DNS resolution: SUCCESS
- TCP connection to port 22: SUCCESS
- SSH protocol identification: SUCCESS
- KEXINIT exchange: SUCCESS
- ECDH key exchange reply: SUCCESS
- Server host key received: SUCCESS

### Observed client message

Host key verification failed.

### Interpretation

The SSH negotiation advanced beyond the initial TCP connection
and completed key exchange.

The client stopped because the server host key was not yet
trusted by the client's known_hosts database.

This is a host identity verification issue, not an authentication
failure and not evidence of the OpenSSH vulnerability.

### Next verification

Compare the server Ed25519 host key fingerprint with the
fingerprint independently collected by Kali.

After verification, register the host key and repeat the
controlled authentication test.

### Evidence

User-provided Alpine inventory and Kali SSH verbose output.
PowerShell diagnostic transcript:
evidence/sessions/SSHOLE_CAPABILITY_FIX_20261108_074903.log


## 14. SSH Protocol Negotiation and Authentication Boundary

Date: 2026-11-08
Environment: Isolated Docker laboratory
Client: Kali GNU/Linux Rolling 2026.3
Target: Alpine Linux 3.24.4
SSH client: OpenSSH 10.6p1
SSH server: OpenSSH 10.3

### 14.1 Host Identity Verification

The ED25519 host key fingerprint was independently inspected
from the target container and compared against the key collected
by the Kali client.

Verified fingerprint:

SHA256:oG8siRmtyt3m5sCcQnlRDqyy07sLyOWzgFZL8VeZM5k

Both fingerprints matched.

Kali subsequently confirmed:

Host 'target' is known and matches the ED25519 host key.

### 14.2 SSH Key Exchange

The Kali client successfully completed:

- TCP connection to target port 22.
- SSH protocol version exchange.
- KEXINIT negotiation.
- ECDH key exchange.
- ED25519 server host-key verification.
- NEWKEYS exchange.
- SSH user-authentication service negotiation.

The client reached the SSH user-authentication service.

### 14.3 Authentication Policy Observation

The server advertised:

Authentications that can continue: publickey

The test used:

BatchMode=yes
PreferredAuthentications=none

The client did not present a public key for authentication.
The resulting message was:

Permission denied (publickey).

This is recorded as an unsuccessful authentication attempt,
not as a completed test of the PermitRootLogin restriction.

### 14.4 Server-Side Evidence

The target logs recorded:

Connection closed by authenticating user root [preauth]

The connections were closed before authentication completed.

### 14.5 Evidence Files

- evidence/sessions/SSHOLE_HOSTKEY_20261108_075511.log
- evidence/sessions/SSHOLE_AUTH_TEST_20261108_080035.log

### 14.6 Current Conclusion

The patched baseline successfully negotiates an SSH session
with the Kali client, verifies the server identity, establishes
session keys, and reaches the authentication service.

Password and keyboard-interactive authentication are disabled
in the configured baseline.

No successful login or vulnerability exploitation has been
demonstrated in this test.


# SSHOLE — Load Experiment 001

Date: 2026-11-08
Environment: Isolated Docker laboratory
Target: Alpine 3.24.4 / OpenSSH 10.3
Client: Kali GNU/Linux Rolling 2026.3
Analyst: Ubuntu 24.04.5 LTS

## 1. Experimental Design

A controlled SSH connection test was performed using:

- 20 SSH connection attempts from Kali.
- Maximum configured concurrency: 4.
- No passwords or authentication credentials supplied.
- 30 TCP availability probes from Ubuntu.
- Server-side logs collected through Docker Compose.

## 2. Ubuntu Observations

Total TCP probes: 30
Successful probes: 30
Failed probes: 0
Observed TCP availability: 100%

This measurement represents TCP port availability during
the observation interval. It does not represent successful
SSH authentication or complete SSH session establishment.

## 3. Kali Observations

Total requested connections: 20
Expected authentication rejections: 16
Connection/protocol errors: 4
Unexpected successful authentications: 0

The four connection/protocol errors require correlation
with server-side rate-limiting events.

## 4. Alpine Server Observations

Server logs included:

srclimit_penalise: 172.23.0.4/32:
activating ipv4 penalty of approximately 15.7 seconds
for penalty: connections without attempting authentication

The server subsequently logged connection drops associated
with the same source address and penalty reason.

This indicates activation of OpenSSH source-based
connection limiting.

Ubuntu TCP probes also generated pre-authentication
connection-close events from 172.23.0.2.

## 5. Interpretation

The server remained operational during the observation.

The TCP availability probes succeeded throughout their
30-probe interval.

OpenSSH activated its source-based penalty mechanism
for connections from the Kali client.

The observed protocol errors are consistent with
server-side connection limiting, although individual
client errors have not been correlated one-to-one with
specific server log entries.

No successful authentication was observed.

## 6. Limitations

- This was a controlled connection test, not a full
  performance benchmark.
- No CPU or memory time-series measurements were collected.
- No latency distribution was calculated.
- No successful authenticated session was tested.
- The experiment does not establish vulnerability status.
- Results apply only to this laboratory configuration.

## 7. Evidence

- evidence/sessions/SSHOLE_LOAD_001_20261108_082151.log
- evidence/sessions/SSHOLE_BASELINE_PRESERVATION_20261108_080531.log

## 8. Conclusion

The patched Alpine baseline remained available during
the observed TCP probes.

OpenSSH source-based connection limiting was activated
during the Kali connection test.

The experiment provides initial reproducible evidence
of SSH connection handling and defensive rate limiting.


# SSHOLE — Load Experiment 001

Date: 2026-11-08
Environment: Isolated Docker laboratory
Target: Alpine 3.24.4 / OpenSSH 10.3
Client: Kali GNU/Linux Rolling 2026.3
Analyst: Ubuntu 24.04.5 LTS

## 1. Experimental Design

A controlled SSH connection test was performed using:

- 20 SSH connection attempts from Kali.
- Maximum configured concurrency: 4.
- No passwords or authentication credentials supplied.
- 30 TCP availability probes from Ubuntu.
- Server-side logs collected through Docker Compose.

## 2. Ubuntu Observations

Total TCP probes: 30
Successful probes: 30
Failed probes: 0
Observed TCP availability: 100%

This measurement represents TCP port availability during
the observation interval. It does not represent successful
SSH authentication or complete SSH session establishment.

## 3. Kali Observations

Total requested connections: 20
Expected authentication rejections: 16
Connection/protocol errors: 4
Unexpected successful authentications: 0

The four connection/protocol errors require correlation
with server-side rate-limiting events.

## 4. Alpine Server Observations

Server logs included:

srclimit_penalise: 172.23.0.4/32:
activating ipv4 penalty of approximately 15.7 seconds
for penalty: connections without attempting authentication

The server subsequently logged connection drops associated
with the same source address and penalty reason.

This indicates activation of OpenSSH source-based
connection limiting.

Ubuntu TCP probes also generated pre-authentication
connection-close events from 172.23.0.2.

## 5. Interpretation

The server remained operational during the observation.

The TCP availability probes succeeded throughout their
30-probe interval.

OpenSSH activated its source-based penalty mechanism
for connections from the Kali client.

The observed protocol errors are consistent with
server-side connection limiting, although individual
client errors have not been correlated one-to-one with
specific server log entries.

No successful authentication was observed.

## 6. Limitations

- This was a controlled connection test, not a full
  performance benchmark.
- No CPU or memory time-series measurements were collected.
- No latency distribution was calculated.
- No successful authenticated session was tested.
- The experiment does not establish vulnerability status.
- Results apply only to this laboratory configuration.

## 7. Evidence

- evidence/sessions/SSHOLE_LOAD_001_20261108_082151.log
- evidence/sessions/SSHOLE_BASELINE_PRESERVATION_20261108_080531.log

## 8. Conclusion

The patched Alpine baseline remained available during
the observed TCP probes.

OpenSSH source-based connection limiting was activated
during the Kali connection test.

The experiment provides initial reproducible evidence
of SSH connection handling and defensive rate limiting.


# SSHOLE — Load Experiment 002

Date: 2026-11-08
Environment: Isolated Docker laboratory

Target: Alpine Linux 3.24.4
SSH Server: OpenSSH 10.3
Client: Kali GNU/Linux Rolling 2026.3
Analyst: Ubuntu 24.04.5 LTS

## 1. Experimental Design

- 8 sequential SSH connection attempts.
- One concurrent SSH connection.
- Three-second interval between attempts.
- No authentication credentials supplied.
- 25 TCP availability probes from Ubuntu.
- Server-side logs collected through Docker Compose.

## 2. Ubuntu TCP Results

Total probes: 25
Successful probes: 25
Failed probes: 0
Observed availability: 100%

Minimum observed connection time: 7 ms
Maximum observed connection time: 17 ms
Mean observed connection time: 10.08 ms

## 3. Kali SSH Results

Requested connections: 8
Expected authentication rejections: 8
Connection/protocol errors: 0
Unexpected successful authentications: 0

Observed total time until rejection:

Minimum: 83 ms
Maximum: 132 ms
Mean: 95 ms

These measurements represent total connection-attempt duration,
not isolated cryptographic handshake duration.

## 4. Alpine Server Observations

The supplied server log output showed:

- Pre-authentication connection closures from Ubuntu.
- Authentication-stage connection closures associated with root
  connection attempts from Kali.
- No srclimit_penalise or penalty-related drop event in the
  supplied LOAD 002 log excerpt.

The absence of a penalty event in this run is an observation,
not proof that source limiting cannot activate at this rate.

## 5. Comparison With LOAD 001

LOAD 001:
- 20 requested SSH connections.
- Configured concurrency: 4.
- 16 expected authentication rejections.
- 4 connection/protocol errors.
- Source-based penalty observed.

LOAD 002:
- 8 sequential SSH connections.
- Configured concurrency: 1.
- 8 expected authentication rejections.
- 0 connection/protocol errors.
- No source-based penalty observed in supplied logs.

## 6. Interpretation

The lower-rate sequential test completed all eight SSH attempts
through the expected authentication rejection stage.

Ubuntu TCP probes also completed without failures.

The observed results are consistent with a difference in server
behavior under the two tested connection patterns.

The experiments do not establish a universal rate threshold
for OpenSSH source limiting.

## 7. Limitations

- No continuous CPU or memory measurements were collected.
- No peak resource usage was recorded.
- The test does not isolate cryptographic handshake duration.
- The test does not establish vulnerability status.
- Results apply only to this laboratory configuration.

## 8. Conclusion

LOAD 002 completed with 25 successful TCP probes and
8 expected SSH authentication rejections.

No connection/protocol errors were observed in the Kali run.

No source-based penalty event appeared in the supplied
server logs for this experiment.


## 15. LOAD 003 — Continuous Resource Telemetry

Date: 2026-11-08
Environment: Isolated Docker laboratory
Target: Alpine 3.24.4 / OpenSSH 10.3
Client: Kali GNU/Linux Rolling 2026.3
Analyst: Ubuntu 24.04.5 LTS

### 15.1 Experimental Results

Ubuntu TCP availability:
- Total probes: 25
- Successful probes: 25
- Failed probes: 0
- Observed availability: 100%
- Minimum latency: 8 ms
- Maximum latency: 16 ms
- Average latency: 10.32 ms

Kali SSH connection test:
- Total connections: 8
- Expected authentication rejections: 8
- Connection errors: 0
- Successful authentications: 0
- Minimum observed duration: 81 ms
- Maximum observed duration: 115 ms

### 15.2 Resource Telemetry

84 samples were collected for each container.

Ubuntu Analyst:
- Average CPU: 0.15%
- Peak CPU: 1.90%
- Average memory: 3.31 MiB
- Peak memory: 4.31 MiB

Kali Client:
- Average CPU: 0.01%
- Peak CPU: 0.51%
- Average memory: 5.56 MiB
- Peak memory: 9.59 MiB

Alpine Target:
- Average CPU: 0.48%
- Peak CPU: 6.77%
- Average memory: 3.14 MiB
- Peak memory: 6.21 MiB

Sampling interval is approximate because each Docker statistics
query adds execution time to the one-second sleep interval.

### 15.3 Server Observations

The target remained running during the experiment.

Server logs contained pre-authentication connection-close events
from both laboratory nodes.

The collected server log covers a 15-minute window and can include
events preceding LOAD 003. Individual events are therefore not
attributed exclusively to this experiment.

### 15.4 Evidence

- evidence/sessions/SSHOLE_LOAD_003_RESOURCES_20261108_083916.csv
- evidence/sessions/SSHOLE_LOAD_003_SERVER_20261108_084345.log
- evidence/sessions/SSHOLE_LOAD_003_FINAL_20261108_084345.log

### 15.5 Conclusion

LOAD 003 demonstrated successful TCP availability checks,
expected SSH authentication rejections, and low observed
resource consumption across the three laboratory containers.

The experiment provides a reproducible resource-telemetry
baseline for subsequent controlled tests.

These results do not establish maximum server capacity,
production performance, or vulnerability status.


## 16. LOAD 004 — Temporal Validation and Evidence Review

Date: 2026-11-08
Environment: Isolated Docker laboratory

### 16.1 Resource Sampling Window

Resource telemetry file:
SSHOLE_LOAD_004_RESOURCES_20261108_084552.csv

Total samples: 456

First sample: 2026-11-08 08:45:54
Last sample: 2026-11-08 08:53:47

The observation covers approximately eight minutes.

### 16.2 Server Log Review

Total collected events: 108
Pre-authentication connection-close events: 108
Source-limit penalty events: 0
Dropped connections: 0

The collected Docker Compose log does not contain
timestamps for individual server events.

The initial observed source address was 172.23.0.2,
corresponding to the Ubuntu laboratory node.

### 16.3 Correlation Limitations

The server log collection window was broader than
the LOAD 004 experiment window.

Individual server events cannot be reliably attributed
to LOAD 004 without timestamped collection and source
correlation.

No source-limit activation was observed in this
collected log.

### 16.4 Final LOAD 004 Assessment

Kali completed 12 controlled SSH connection attempts.

Expected authentication rejections: 12
Connection errors: 0
Unexpected successful authentications: 0

Resource telemetry recorded 456 samples across
the three laboratory containers.

The experiment demonstrated successful connection
handling and expected authentication rejection.

It did not establish maximum server capacity,
production performance, or vulnerability status.

### 16.5 Methodological Improvement for LOAD 005

Future server log collection will include timestamps.

Client and server observations will be captured
within a defined experimental time window.

Source addresses will be correlated with the
corresponding laboratory nodes.
