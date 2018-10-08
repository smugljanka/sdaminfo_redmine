#!/usr/bin/env sh
#set -e
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/usr/bin:/bin
CRON_TZ=UTC

# configure root crontab
crontab -u root /tmp/cron-root

# Link cron logs to FD of docker container
ln -s /proc/1/fd/1 /var/log/cron.log

# Set executable mode for docker-wrapper.sh
find / -type f -name "/*.sh" -exec chmod +x {} \;

exec "$@"