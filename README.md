# syn-bot


create test queue tables like:
```
POSTGRES_HOST=localhost rake
```

and then

`ALTER TABLE discord_user_queue ALTER COLUMN discord_id SET DATA TYPE bigint;`

because I don't know how to do this in ROM and it seemed silly to learn to just do it once.
