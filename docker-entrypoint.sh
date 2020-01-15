#!/bin/bash -e

mkdir -p /var/log/parsoid
nohup node bin/server.js 2>/var/log/parsoid/error.log 1>/var/log/parsoid/access.log&

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"