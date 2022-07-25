FROM 595508394202.dkr.ecr.us-west-2.amazonaws.com/syn-bot-base:latest

ADD syn-bot.tar /root

RUN set -eux; \
    	cd; \
	bundle install; \
	find . -name interaction.rb

CMD cd; ./idle.sh

