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

# Create a folder for nginx certificates
if [ ! -e "/etc/nginx/certs" ]; then
  mkdir -p /etc/nginx/certs
fi

if [ -e "/etc/nginx/certs/privkey.pem" ]; then
  chown -R root. /etc/nginx/certs
  chmod 0600 /etc/nginx/certs/privkey.pem
  chmod 0640 /etc/nginx/certs/fullchain.pem
fi

exec nginx -g "daemon off;"