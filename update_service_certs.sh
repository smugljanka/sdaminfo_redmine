#!/bin/sh
# Update SSL certificate and private key in the frontend service.
# If certificate of server and certificate created by Certbot utility are
# different then the following script will update the certificate and private key
# in the frontend service.

# USAGE:
# update_service_certs.sh <DOMAIN> <STACK_NAME> <FRONTEND_SERVICE_NAME>

# Required arguments:
# DOMAIN - FQDN of your domain
# STACK_NAME - the name of docker stack
# FRONTEND_SERVICE_NAME - the name of frontend service running in stack

set -x

# Ensure that stack name and service name are given
if [ $# -lt 3 ]; then
  usage
fi

# Provide a path to LetsEncrypt working directory.
# If your path is different you must change it.
LETSENCRYPT_WORKDIR=/opt/www/redmine/data/letsencrypt/live

# Domain name
DOMAIN="${1}"
# The name of deployed stack
STACK_NAME="${2:redmine}"
# The name of frontend service that should be processed
FRONTEND_SERVICE="${3:redmine-frontend}"

usage () {
    echo "Usage `basename $0` <domain> <stack_name> <frontend_service_name>"
    exit 1
}

verify_certificates () {
    # Function that compares a certificate installed in a frontend service
    # and certificate generated by Certbot utility

    domain=${1}
    certbot_workdir=${2}
    curr_cert_path=/tmp/$(date +%F)-${domain}.pem
    certbot_certs_path=${certbot_workdir}/${domain}/fullchain.pem

    if [ ! -e "${certbot_certs_path}" ]; then
        echo "Certbot certificate ${certbot_certs_path} not found"
        exit 1
    fi
    # Get the current domain certificate
    echo | openssl s_client -showcerts -connect ${domain}:443 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${curr_cert_path}

    # Get the difference between the current and generated by certbot
    # if files are different than return 1, otherwise return 0
    diff -q ${curr_cert_path} ${certbot_certs_path}

    return $?
}

verify_certificates ${DOMAIN} ${LETSENCRYPT_WORKDIR}

if [ "XYZ$?" == "XYZ1" ]; then

    # Update service - remove secrets from service
    docker service update --secret-rm front-cert --secret-rm front-key ${STACK_NAME}_${FRONTEND_SERVICE}

    # Remove secrets from the docker secrets
    docker secret rm front-cert front-key

    # Create new external secrets
    docker secret create front-cert ${LETSENCRYPT_WORKDIR}/${DOMAIN}/fullchain.pem
    docker secret create front-key ${LETSENCRYPT_WORKDIR}/${DOMAIN}/privkey.pem

    # Update service - add new secrets to the service
    docker service update --secret-add "source=front-cert,target=front-cert,mode=0664" --secret-add "source=front-key,target=front-key,mode=0600" ${STACK_NAME}_${FRONTEND_SERVICE}
fi