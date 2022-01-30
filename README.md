# syn-bot

run local postgres like:
```
docker run -d -p5432:5432 -e POSTGRES_USER=AmazonPgUsername -e POSTGRES_PASSWORD=AmazonPgPassword -e POSTGRES_HOST_AUTH_METHOD=trust postgres:12.8
```

connect like:
```
psql postgres://AmazonPgUsername:AmazonPgPassword@localhost/postgres
```

create test queue tables like:
```
POSTGRES_HOST=localhost rake
```

connect to a docker container
```
aws ecs execute-command --cluster SyndicateECSCluster --task 921bcfd8299644f2a71681d6a2726db3 --command "/bin/bash" --interactive
```

to get psql to do work there:
```
apt-get update
apt-get postgresql-client-common
apt-get postgresql-client-11
``

and then

`ALTER TABLE discord_user_queue ALTER COLUMN discord_id SET DATA TYPE bigint;`

because I don't know how to do this in ROM and it seemed silly to learn to just do it once.


### Webhook
The webhook must be owned by the bot to creat buttons in webhooks:

```
bot.channel(855996952348327949).webhooks
bot.channel(855996952348327949).create_webhook('test-bot-webhook')
bot.channel(855996952348327949).webhooks
(bot.channel(855996952348327949).webhooks[1]).token
```

Once created, you can rename the webhook and add an image on the Web.

### Curl for Webhooks

curl -v -H "Content-Type: application/json"  -d@foo.json https://discord.com/api/webhooks/{ID}/{TOKEN}
