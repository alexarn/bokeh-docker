#!/bin/bash

function availablePort() {
    local OPENED_PORTS=$(ss -lntu| awk '{split($5, array, ":"); print array[2]}')
    local HTTP_PORT
    for port_value in {10000..10500}
    do
        if [[ ! $(echo "$OPENED_PORTS" | grep ${port_value}) ]]
        then
            HTTP_PORT=$port_value; break
        fi
    done

    echo $HTTP_PORT
}

BOKEH_ROOT=$(pwd)
ENV_BASIC=$BOKEH_ROOT/docker/.env
ENV_DEV=$BOKEH_ROOT/docker/.env.dev

if [ ! -f $ENV_DEV ]
then
    cp $ENV_BASIC $ENV_DEV
    WEB_PORT=$(availablePort)
    if [ -z "${WEB_PORT}" ]
    then
	info "no HTTP port left"
	exit 2
    fi

    sed -i "s:WEB_PORT=.*:WEB_PORT=$WEB_PORT:" $ENV_DEV

    echo "" >> $ENV_DEV
    echo "BOKEH_ROOT=$BOKEH_ROOT" >> $ENV_DEV
    echo "GROUP_ID=$(id -g)" >> $ENV_DEV
    echo "USER_ID=$(id -u)" >> $ENV_DEV
    echo "USERNAME=$(whoami)" >> $ENV_DEV
    echo "DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))" >> $ENV_DEV
fi

cd $(dirname $(realpath $0))
docker-compose --env-file $ENV_DEV -f $BOKEH_ROOT/docker/compose.yml -f compose.yml ${*}
