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

# Copy the server certificate and private key to the nginx certs folder
cp -a -f /run/secrets/fullchain.pem /etc/nginx/certs/ || true
cp -a -f /run/secrets/privkey.pem /etc/nginx/certs/ || true

exec nginx -g "daemon off;"