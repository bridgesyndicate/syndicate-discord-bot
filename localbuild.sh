#!/usr/bin/env bash
set -e

./localbuild.rb | grep -v 'aws ecr' | bash
docker run -it \
       -e AWS_REGION=us-west-2 \
       -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
       -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
       595508394202.dkr.ecr.us-west-2.amazonaws.com/syn-bot:latest
