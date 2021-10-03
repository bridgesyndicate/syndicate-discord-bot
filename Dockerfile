FROM ruby:2.7.3-slim-buster

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		build-essential \
		git \
		libsqlite3-dev

ADD syn-bot.tar /root

RUN set -eux; \
    	cd; \
	bundle install; \
	find . -name interaction.rb

CMD cd; ./syndicate-bot.rb

