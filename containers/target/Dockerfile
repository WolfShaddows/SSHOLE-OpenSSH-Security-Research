FROM alpine:3.24
RUN apk add --no-cache openssh-server \
 && ssh-keygen -A \
 && mkdir -p /run/sshd \
 && printf '%s\n' 'PermitRootLogin no' 'PasswordAuthentication no' 'KbdInteractiveAuthentication no' > /etc/ssh/sshd_config.d/00-lab-baseline.conf
EXPOSE 22
