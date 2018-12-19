#!/usr/bin/env sh
set -e
set -x

echo "$(date) - Starting synchronization to AWS S3"
aws s3 sync /backup s3://$AWS_S3_BUCKET
echo "$(date) - Synchronization successfully ended"
