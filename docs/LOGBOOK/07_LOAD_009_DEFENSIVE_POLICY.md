# LOAD 009 — Defensive Policy Assessment

**Date:** 2026-11-08<br>
**Session:** SSHOLE_LOAD_009_20261108_112806<br>
**Target:** Alpine Linux / sshole-target

## Objective

Compare the effective SSH baseline policy with a candidate policy
that disables forwarding capabilities.

## Procedure

1. Validate the original SSH configuration with `sshd -t`.
2. Inspect effective baseline settings using `sshd -T`.
3. Evaluate candidate settings using query-time command-line overrides.
4. Validate the original configuration again.
5. Confirm the SSH daemon remains active.
6. Extract and hash the resulting evidence.

## Results

The baseline allowed agent forwarding and stream-local forwarding,
while TCP forwarding and X11 forwarding were disabled.

The candidate policy reported:

- `disableforwarding yes`
- `allowagentforwarding no`
- `allowstreamlocalforwarding no`

Authentication settings remained unchanged.

The original configuration remained valid and the SSH listener
process remained active.

## Interpretation

The experiment demonstrates a configuration-level reduction in
effective forwarding permissions.

It does not establish runtime enforcement because no forwarding
session was attempted. The candidate was not deployed and no
persistent configuration was changed.

No authentication bypass was demonstrated.

## Evidence

`evidence/sessions/SSHOLE_LOAD_009_20261108_112806/POLICY-COMPARISON.txt`

SHA-256:

`60FAB367BA6B00E205E5CF8925A2651CF438FACC14408E33A98D76F241FF8C36`

## Status

COMPLETED
