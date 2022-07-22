#!/bin/sh
export BOKEH_ROOT=$(pwd)
export GROUP_ID=$(id -g)
export USER_ID=$(id -u)
export USERNAME=$(whoami)
export DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))
cd $(dirname $(realpath $0))
docker-compose --env-file $BOKEH_ROOT/docker/.env -f $BOKEH_ROOT/docker/compose.yml -f compose.yml ${*}
