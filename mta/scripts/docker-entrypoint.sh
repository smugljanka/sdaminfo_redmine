#!/usr/bin/env sh

# Create init scripts like 01_init_postfix.sh, 02_init_rsyslog.sh, ... and mount them
# into the container in folder /docker-entrypoint.d/
# They will started consistently when the container is started
for i_script in $(ls /docker-entrypoint.d/*.sh); do . ${i_script}; done

exec "$@"