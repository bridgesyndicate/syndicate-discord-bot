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
apt-get install -y postgresql-client-common postgresql-client-11
psql postgres://AmazonPgUsername:AmazonPgPassword@${POSTGRES_HOST}/postgres
``

and then (I don't think we need this any more, please remove)

`ALTER TABLE discord_user_queue ALTER COLUMN discord_id SET DATA TYPE bigint;`

because I don't know how to do this in ROM and it seemed silly to learn to just do it once.

## Bastion

```
aws ecs run-task --enable-execute-command --task-definition SyndicateBastionTaskDefinition --cluster SyndicateECSCluster  --network-configuration 'awsvpcConfiguration={subnets=[subnet-02f0a2e9ba4b5d279],securityGroups=[sg-0cde2458dac7fcd35],assignPublicIp=DISABLED}'
aws ecs list-tasks --cluster SyndicateECSCluster --family SyndicateBastionTaskDefinition
aws ecs execute-command --cluster SyndicateECSCluster --command "/bin/bash" --interactive --task cd22bf17bad34bd7af2fdf14906c4aa3
psql postgres://AmazonPgUsername:AmazonPgPassword@${POSTGRES_HOST}/postgres
aws ecs stop-task --cluster SyndicateECSCluster --task 8b4882f0be4b4d02be54f084b70533bb
```



### Webhook
The webhook must be owned by the bot to creat buttons in webhooks:

```
get the channel_id by right-clicking text channel that will be the game stream, copy id

bot.channel(channel_id).webhooks
bot.channel(channel_id).create_webhook('test-bot-webhook')
bot.channel(channel_id).webhooks
(bot.channel(channel_id).webhooks[1]).token
```

Once created, you can rename the webhook and add an image on the Web.

### Curl for Webhooks

curl -v -H "Content-Type: application/json"  -d@foo.json https://discord.com/api/webhooks/{ID}/{TOKEN}
```

Moving to a new Discord Server:
```
Set up the server first:

1. create private categories `UNVERIFIED` and `VERIFIED` and make it so no one can see them
2. add #verify channel in `UNVERIFIED` category
3. create `verified` role. make it so they can see the `VERIFIED` category, and can NOT see the `UNVERIFIED` category
4. create `banned`, `*` and `moderator` roles. can have same permissions as `verified`
5. Server Settings -> Roles -> all of the roles you made -> View Server as Role, to make sure everything looks right

Invite the bot:

1. @owner of the bot, go to https://discord.com/developers/applications
2. go to THIS bot -> OAuth2 -> URL Generator
3. on `SCOPES` section, check `bot` and `applications.commands`
4. on `BOT PERMISSIONS` section, check `Administrator`
5. go to the link -> select server of choice -> continue -> authorize
6. change the DISCORD_SERVER_ID in lib/helpers.rb (right click server icon, copy id)
7. add the webhook to the bot by following the Webhook steps above
8. `toys create-barr-command` (since it's the only guild command we have)

Lastly:

1. double check that everything looks right
2. run the bot on the cloud and test out all of the slash commands, both in the server and in DMs
3. add the "Welcome" embed to the #verify channel. either with disco-hook or hard coded from a local bot instance
```


## Dropping tables
I didn't want to commit this into the code because mistakenly dropping tables is bad.
`lib/scrims.rb`
```ruby
    def drop_pg_tables
      ROM.container(:sql, container_type) do |conf|
        conf.default.drop_table(:discord_user_queue)
        conf.default.drop_table(:members)
        conf.default.drop_table(:parties)
        conf.default.drop_table(:locks)
        conf.default.drop_table(:duels)
        conf.default.drop_table(:syndicate_leader_board)
      end
    end
```

`Rakefile`

```ruby
task :drop_scrims_tables do
  puts "Dropping tables on #{ENV['POSTGRES_HOST']}"
  puts 'ctrl-c to ABORT, enter to continue'
  foo = STDIN.gets
  storage = Scrims::Storage.new
  storage.drop_pg_tables
end
```