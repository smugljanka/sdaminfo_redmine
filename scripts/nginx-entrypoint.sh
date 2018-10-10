#!/bin/sh

# Create acme-challenge folder in /var/www
acme-challenge="/var/www/.well-known/acme-challenge"
if [ ! -e "${acme-challenge}" ];then
    mkdir -p ${acme-challenge}
    chown -R nginx. ${acme-challenge}
    cat > ${acme-challenge}/index.html <<EOF
acme-challenge test page !
EOF
fi

exec nginx -g "daemon off;"
