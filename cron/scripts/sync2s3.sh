#!/usr/bin/env sh
set -x
set -a

# Getting a folder which contains AWS credentials
AWS_CONFIG_FOLDER="$(dirname ${AWS_CONFIG})"

# Getting ID of redmine database container
peer_cont_id=$(docker container ls --filter 'label=com.bolyshev.redmine.description=Redmine database service' -q | head -n1)

docker run --privileged --rm \
           --name sync_to_aws_s3 \
           --volumes-from ${peer_cont_id} \
           -e "AWS_S3_BUCKET=${AWS_S3_BUCKET}" \
           -v "${AWS_CONFIG_FOLDER}:/root/.aws" \
           ${AWS_S3_IMAGE}

