#!/usr/bin/env sh

cat > /etc/opendkim/opendkim.conf <<EOF
Background              No
AutoRestart             Yes
AutoRestartRate         10/1h
Umask                   002
Syslog                  yes
SyslogFacility          mail
SyslogSuccess           Yes

Canonicalization        relaxed/simple

Domain                  ${POSTFIX_DOMAIN}
KeyFile                 /run/secrets/domain.private
Selector                ${DKIM_SELECTOR}
Socket                  inet:${DKIM_PORT}
UserID                  opendkim:opendkim

ExternalIgnoreList      refile:/etc/opendkim/ExternalHosts
InternalHosts           refile:/etc/opendkim/TrustedHosts

Mode                    sv
SignatureAlgorithm      rsa-sha256

LogWhy                  Yes
EOF

cat > /etc/opendkim/ExternalHosts <<EOF
*.${POSTFIX_DOMAIN}
EOF

cat > /etc/opendkim/TrustedHosts <<EOF
127.0.0.1
localhost
${POSTFIX_NETWORKS_REGEXP_MAP:-10.*.*.*}
EOF

# Set correct permission for the user opendkim
chown -R opendkim:opendkim /etc/opendkim/*
chmod g+r /etc/opendkim/*
