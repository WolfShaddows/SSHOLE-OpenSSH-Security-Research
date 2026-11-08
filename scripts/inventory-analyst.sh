#!/bin/bash
set -euo pipefail
cat /etc/os-release
echo '=== libc ==='
ldd --version 2>&1 | head -n 2 || true
echo '=== SSH client ==='
ssh -V 2>&1 || true
