FROM ruby:2.7.3-slim-buster

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		build-essential \
		git \
		libsqlite3-dev \
		libpq-dev
