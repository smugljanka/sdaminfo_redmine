#!/usr/bin/env sh

# Run init scripts
for i_script in $(ls /docker-entrypoint.d/*.sh); do . ${i_script}; done

exec "$@"