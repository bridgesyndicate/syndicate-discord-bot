#!/bin/bash
set -evx
REPOSITORY_HOST=595508394202.dkr.ecr.us-west-2.amazonaws.com
REPOSITORY_URI=$REPOSITORY_HOST/syn-bot-base
S3_BUCKET=syndicate-versioned-artifacts
aws s3 cp s3://${S3_BUCKET}/ruby-2.7.6.tar.gz .
docker build -t $REPOSITORY_URI:latest .
docker push $REPOSITORY_URI:latest
