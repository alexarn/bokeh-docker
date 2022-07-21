#!/bin/bash
me=$(whoami)
pwd=$(pwd)
dockerpath=${pwd/\/opt\/workplace/\/home\/webmaster}
args=${*/\/opt\/workplace/\/home\/webmaster}
container=$(docker ps|grep "$me-bokeh-php"|awk '{print $1}')
#command="docker exec -w /home/webmaster/${me}/php/bokeh/ -it ${me}-bokeh-php-71-dev su webmaster -c \"php $*\""
command="docker exec -w ${dockerpath} -it $container su webmaster -c \"php ${args}\""

echo -e "\n${command}\n"

eval $command


