FROM 595508394202.dkr.ecr.us-west-2.amazonaws.com/syn-bot-base:latest

ADD syn-bot.tar /root
RUN cd && bundle config set path vendor/bundle && bundle config set without development,test && bundle install
CMD cd; ./syndicate-bot.rb

