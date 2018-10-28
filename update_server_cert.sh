#!/bin/sh
set -x

# Script updates a nginx server certificate and a private key in the service "redmine-frontend".
# If you have a custom name of your frontend service you must change the FRONTEND_SERVICE variable

# Usage:
# update_service_certs.sh <STACK_NAME> <FRONTEND_SERVICE_NAME>

usage () {
 echo "Usage `basename $0` <stack_name> <frontend_service_name>"
 exit 1
}

# Ensure that stack name and service name are given
if [ $# -lt 2 ]; then
  usage
fi

# The name of stack
STACK_NAME="${1:redmine}"

# The name of frontend service that should be processed
FRONTEND_SERVICE="${2:redmine-frontend}"

# Update service - remove secrets from service
docker service update --secret-rm front-cert --secret-rm front-key ${STACK_NAME}_${FRONTEND_SERVICE}

# Remove secrets from the docker secrets
docker secret rm front-cert front-key

# Create new external secrets
docker secret create front-cert /opt/www/redmine/data/letsencrypt/live/rm.bolyshev.com/fullchain.pem
docker secret create front-key /opt/www/redmine/data/letsencrypt/live/rm.bolyshev.com/privkey.pem

# Update service - add new secrets to the service
docker service update --secret-add "source=front-cert,target=front-cert,mode=0664" --secret-add "source=front-key,target=front-key,mode=0600" ${STACK_NAME}_${FRONTEND_SERVICE}