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

# Copy certificates from LetsEncrypt runtime folder
cp --force -H /etc/letsencrypt/live/${DOMAIN}/*.pem /etc/nginx/certs/ || true

# If a certificate and a privkey not found, copy the self-signed certificate and privkey
if [ ! -e "/etc/nginx/certs/privkey.pem" ];then
  cp /etc/nginx/certs/dev-privkey.pem /etc/nginx/certs/privkey.pem
fi
if [ ! -e "/etc/nginx/certs/fullchain.pem" ]; then
  cp /etc/nginx/certs/dev-fullchain.pem /etc/nginx/certs/fullchain.pem
fi

# Set required mode
chmod 0600 /etc/nginx/certs/privkey.pem || true
chmod 0640 /etc/nginx/certs/fullchain.pem || true

# Start nginx
exec nginx -g "daemon off;"