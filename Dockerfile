FROM 595508394202.dkr.ecr.us-west-2.amazonaws.com/syn-bot-base:latest

ADD syn-bot.tar /root

RUN set -eux; \
    	cd; \
	bundle config set without development; \
	bundle config set path vendor/bundle; \
	bundle install; \
	find . -name interaction.rb

CMD cd; ./syndicate-bot.rb ./production-config.yml

