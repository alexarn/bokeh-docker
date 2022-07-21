#!/bin/sh
export BOKEH_ROOT=$(pwd)
export GROUP_ID=$(id -g)
export USER_ID=$(id -u)
export USERNAME=$(whoami)

cd $( dirname -- "${BASH_SOURCE[0]}" )
docker-compose -f compose.yml ${*}
