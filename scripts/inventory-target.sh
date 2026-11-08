#!/bin/sh
set -eu
echo '=== OS ==='
cat /etc/alpine-release 2>/dev/null || true
echo '=== OpenSSH package ==='
apk info -v openssh-server 2>/dev/null || true
echo '=== sshd linkage ==='
ldd /usr/sbin/sshd 2>&1 || true
echo '=== effective SSH authentication settings ==='
sshd -T 2>/dev/null | grep -Ei '^(passwordauthentication|usepam|permitrootlogin|kbdinteractiveauthentication) ' || true
echo '=== shadow field classes (no hashes printed) ==='
awk -F: 'BEGIN{OFS=":"} {v=$2; if(v=="*") s="asterisk"; else if(v ~ /^!/) s="locked-bang"; else if(v ~ /^\$/) s="hash-present"; else s="other"; print $1,s}' /etc/shadow 2>/dev/null || true
