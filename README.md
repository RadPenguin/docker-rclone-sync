# docker-rclone

Perform an [rclone](http://rclone.org) command based on a cron schedule, with [healthchecks.io](https://healthchecks.io) monitoring.

## Usage
```
docker create \
  --name=rclone \
  --env COMMAND="sync" \
  --env COMMAND_OPTS="-v" \
  --env CRON="0 * * * *" \
  --env DESTINATION="gdrive:media" \
  --env HEALTH_URL=http://example.com/asdf1234 \
  --env SOURCE=/source \
  --env TZ="America/Edmonton" \
  --volume <path to data>:/config \
  radpenguin/rclone
```

## Parameters
The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
```
--volume /config - config file and for rclone
--env COMMAND - The command to run. Defaults to "sync"
--env COMMAND_OPTS - additional options for rclone command. Defaults to `-v`
--env CRON - cron schedule, defaults to hourly
--env DESTINATION - The destination on the rclone remote
--env HEALTH_URL - monitoring service url to GET after a successful rclone command
--env SOURCE - The local source directory
--env TZ - the timezone to use for the cron and log. Defaults to `America/Edmonton`
```

It is based on alpine linux. For shell access while the container is running, `docker exec -it rclone /bin/bash`.

See [rclone docs](https://rclone.org/commands/) for syntax and additional options.
