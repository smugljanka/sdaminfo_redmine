#!/usr/bin/env sh
set -x
set -a

# Getting a folder which contains AWS credentials
AWS_CONFIG_FOLDER="$(dirname ${AWS_CONFIG})"

# Getting ID of redmine database container
peer_cont_id=$(docker container ls --filter 'label=ru.sdaminfo.description=Redmine database service' -q | head -n1)

docker run --privileged --rm \
           --name sync_to_aws_s3 \
           --volumes-from ${redmine_db_id} \
           -v "${AWS_CONFIG_FOLDER}:${AWS_CONFIG_FOLDER}" \
           ${AWS_S3_IMAGE}

