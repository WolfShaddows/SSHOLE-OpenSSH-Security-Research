# Threat model

## Asset
SSH account authentication on a Linux host running OpenSSH with musl libc.

## Reported preconditions (Alpine advisory)
According to the Alpine security advisory, the reported condition requires all of the following:
1. OpenSSH server built without PAM, or PAM configured with `UsePAM no`.
2. Effective `PasswordAuthentication yes`.
3. A target account with `*` in its shadow password field.
4. At least one other local account with a `$5$` or `$6$` password hash.
5. An overlong password input of 257–1024 bytes.
6. Network reachability to sshd and knowledge of the target account name.

A shadow field containing `!` is not equivalent to `*`.

## Reported mechanism
The vendor advisory describes a musl `crypt()` error condition in which an overlong password can result in `*`. In the affected sshd authentication path, that result can compare equal to a stored `*` shadow field.

OpenSSH 10.6p2 documents a workaround for the reported condition. This is a specific interaction and must not be generalized to all Linux or SSH configurations.

## Project laboratory assessment
The tested target used Alpine Linux 3.24.4, musl libc, and OpenSSH package revision `10.3_p1-r2`. The project system inventory records this revision; the Alpine advisory identifies it as fixed for the Alpine 3.24 branch.

The laboratory therefore represents a patched baseline. It was not qualified as an affected target, and the reported bypass was not reproduced.

## Defensive controls examined
- `PasswordAuthentication no`
- `PermitRootLogin no`
- Public-key authentication policy
- Agent-forwarding restrictions
- TCP-forwarding restrictions
- StreamLocal-forwarding restrictions
- Container capability restrictions
- `no-new-privileges`
- Internal Docker networking and absence of published SSH ports

These are laboratory configuration observations, not a complete security assessment of a production SSH deployment.

## Exclusions and limitations
- Public-key authentication key length is not the reported vulnerability mechanism.
- The reported condition is not asserted for glibc systems or PAM configurations with `UsePAM yes`, consistent with the vendor advisory.
- Accounts with `!` in the shadow field do not satisfy the stated `*` precondition.
- No external or third-party target was tested.
- No vulnerable package build was tested.
- No successful bypass was demonstrated.

## Risk communication
This project documents vendor-reported conditions and defensive behavior observed in its laboratory. It does not claim that the tested patched baseline was exploitable, nor that it independently disproved the vulnerability.
