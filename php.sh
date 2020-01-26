#!/usr/bin/env bash

docker exec -i --user=1000:1000 php-debug php "$@"