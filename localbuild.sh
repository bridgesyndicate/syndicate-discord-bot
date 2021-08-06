#!/usr/bin/env bash
set -e

./localbuild.rb | grep -v 'aws ecr' | bash
docker run -it 595508394202.dkr.ecr.us-west-2.amazonaws.com/syn-bot:latest
