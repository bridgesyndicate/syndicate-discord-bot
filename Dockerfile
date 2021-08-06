FROM ruby:2.7.3-slim-buster

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		build-essential \
		git

ADD syn-bot.tar /root

RUN set -eux; \
    	cd; \
	bundle install

CMD cd; bundle exec ruby syndicate-bot.rb

