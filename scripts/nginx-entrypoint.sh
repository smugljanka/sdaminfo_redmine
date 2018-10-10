#!/bin/sh

# Create acme-challenge folder in /var/www
acme="/var/www/.well-known/acme-challenge"
if [ ! -e "${acme}" ];then
    mkdir -p ${acme}
    chown -R nginx. ${acme}
    cat > ${acme}/index.html <<EOF
acme-challenge test page !
EOF
fi

exec nginx -g "daemon off;"