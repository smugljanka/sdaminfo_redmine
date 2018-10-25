#!/usr/bin/env sh

local_hostname=$(hostname)

postconf -e inet_interfaces="all"
postconf -e inet_protocols="ipv4"

############# Update generic map
cat >> /etc/postfix/generic <<EOF
@${local_hostname} admin@${POSTFIX_DOMAIN}
EOF
postmap /etc/postfix/generic || true
# Optional lookup tables that perform address rewriting in the Postfix SMTP client, typically to transform
# a locally valid address into a globally valid address when sending mail across the Internet.
postconf -e smtp_generic_maps="hash:/etc/postfix/generic"
postconf -e append_at_myorigin="yes"

# Fix host lookup errors like this "postfix/smtpd[236]: connect from unknown[10.0.1.2]"
postconf -e smtp_host_lookup="dns,native"

############# Update aliases
cat > /etc/postfix/aliases <<EOF
# Basic system aliases -- these MUST be present.
mailer-daemon:  postmaster
postmaster:     root

# General redirections for pseudo accounts.
bin:            root
daemon:         root
adm:            root
lp:             root
sync:           root
shutdown:       root
halt:           root
mail:           root
news:           root
uucp:           root
operator:       root
games:          root
gopher:         root
ftp:            root
nobody:         root
radiusd:        root
nut:            root
dbus:           root
vcsa:           root
canna:          root
wnn:            root
rpm:            root
nscd:           root
pcap:           root
apache:         root
webalizer:      root
dovecot:        root
fax:            root
quagga:         root
radvd:          root
pvm:            root
amandabackup:           root
privoxy:        root
ident:          root
named:          root
xfs:            root
gdm:            root
mailnull:       root
postgres:       root
sshd:           root
smmsp:          root
postfix:        root
netdump:        root
ldap:           root
squid:          root
ntp:            root
mysql:          root
desktop:        root
rpcuser:        root
rpc:            root
nfsnobody:      root

ingres:         root
system:         root
toor:           root
manager:        root
dumper:         root
abuse:          root

newsadm:        news
newsadmin:      news
usenet:         news
ftpadm:         ftp
ftpadmin:       ftp
ftp-adm:        ftp
ftp-admin:      ftp
www:            webmaster
webmaster:      root
noc:            root
security:       root
hostmaster:     root
info:           postmaster
marketing:      postmaster
sales:          postmaster
support:        postmaster

# trap decode to catch security attacks
decode:         root

# Person who should get root's mail
#root:          marc
EOF
postalias -r hash:/etc/postfix/aliases
postconf -e alias_database="hash:/etc/postfix/aliases"
postconf -e alias_maps="hash:/etc/postfix/aliases"
#############

# Enable DKIM in postfix configuration
postconf -e milter_default_action=accept
postconf -e milter_protocol=2
postconf -e smtpd_milters="inet:${DKIM_ADDRESS}:${DKIM_PORT}"
postconf -e non_smtpd_milters="inet:${DKIM_ADDRESS}:${DKIM_PORT}"

# The  list of domains that are delivered via the $local_transport mail delivery transport.
# By default this is the Postfix local(8) delivery agent which looks up all recipients in /etc/passwd and /etc/aliases.
postconf -e mydestination="\$myhostname, localhost.$mydomain, localhost"
# The  internet hostname of this mail system. The default is to use the fully-qualified domain name (FQDN)
# from gethostname(), or to use the non-FQDN result from gethostname() and append ".$mydomain".
postconf -e myhostname="${POSTFIX_HOSTNAME}"

# The internet domain name of this mail system. The default is to use $myhostname minus the first component, or "localdomain"
postconf -e mydomain="${POSTFIX_DOMAIN}"
# Postfix  should  "trust"  remote SMTP clients in the same IP subnetworks as the local machine.
postconf -e myorigin=\$mydomain

# The list of "trusted" remote SMTP clients that have more privileges than "strangers".
# If you specify the mynetworks list by hand, Postfix ignores the mynetworks_style setting.
if [ "${POSTFIX_NETWORKS:-##}" != "##" ]; then
postconf -e mynetworks="127.0.0.0/8,${POSTFIX_NETWORKS}"
else
# Postfix should "trust" remote SMTP clients in the same IP subnetworks as the local machine.
postconf -e mynetworks_style="subnet"
fi

# SMTP parameters
postconf -e smtp_helo_name="${POSTFIX_DOMAIN}"   # The hostname to send in the SMTP HELO or EHLO command.
postconf -e smtp_quit_timeout="300s"             # he Postfix SMTP client time limit for sending the QUIT command, and for receiving the remote SMTP server response.
postconf -e smtpd_client_restrictions="permit_mynetworks,permit_sasl_authenticated,reject"
postconf -e smtpd_helo_restrictions="reject_unknown_helo_hostname"   # Reject the request when the HELO or EHLO hostname has no DNS A or MX record.
postconf -e smtpd_sender_restrictions="reject_unknown_sender_domain"
# Optional restrictions that the Postfix SMTP server applies in the context of a client RCPT  TO  command
postconf -e smtpd_recipient_restrictions="permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination,reject_rbl_client zen.spamhaus.org,reject_rhsbl_reverse_client dbl.spamhaus.org,reject_rhsbl_helo dbl.spamhaus.org,reject_rhsbl_sender dbl.spamhaus.org"
# Access restrictions for mail relay control that the Postfix SMTP server applies in the context of the RCPT TO command,
# before smtpd_recipient_restrictions.
postconf -e smtpd_relay_restrictions="permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination"
postconf -e smtpd_data_restrictions="reject_unauth_pipelining"


# Consider (a bounce message/a message) as undeliverable, when delivery fails with a temporary error, and the time in the queue has
# reached
postconf -e bounce_queue_lifetime="23h"
postconf -e maximal_queue_lifetime="23h"
postconf -e relay_domains=""  # What destination domains (and subdomains thereof) this system will relay mail to.

# Don't show service name, version and release data
postconf -e mail_name="RedMail v1.0.2"
postconf -e mail_release_date=20000101
postconf -e mail_version="1.0.2"
postconf -e smtpd_banner="ESMTP \$mail_name (\$mail_version)"

# We have to check postfix first to populate postfix spool directory.
/usr/sbin/postfix -c /etc/postfix check >/dev/null 2>&1
/usr/sbin/postfix -c /etc/postfix set-permissions >/dev/null 2>&1

