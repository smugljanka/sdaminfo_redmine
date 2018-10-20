#!/usr/bin/env sh

PIDFILE="/var/run/rsyslogd.pid"
CONFIGFILE="/etc/rsyslog.conf"

# Delete PID-file
if [ -e "${PIDFILE}" ]; then rm ${PIDFILE}; fi

# Configure rsyslog to send received logs to stdout
cat > /etc/rsyslog.conf <<EOF
\$ModLoad imuxsock
\$template noTimestampFormat,"%syslogtag%%msg%\n"
\$ActionFileDefaultTemplate noTimestampFormat
*.*;auth,authpriv.none /dev/stdout
EOF

# Start rsyslog-daemon
/usr/sbin/rsyslogd -i "${PIDFILE}" -f "${CONFIGFILE}"