#!/bin/sh
export BOKEH_ROOT=$(pwd)
export GROUP_ID=$(id -g)
export USER_ID=$(id -u)
export USERNAME=$(whoami)
export DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))
cd $( dirname -- "${BASH_SOURCE[0]}" )
docker-compose -f compose.yml ${*}
