#!/bin/bash

REPO=${REPO:-"https://git.afi-sa.net/afi/opacce.git"}

function nextStep() {
    echo ""
    echo "==== $1 ===="
    echo ""
}


function die() {
    echo $1
    exit 1
}


function executeCommand() {
    cmd=$1
    echo "$cmd"
    eval  $cmd || die $2 > /dev/null 2>&1
    echo "done"
    echo ""
}

function printError() {
    errors=$errors$'\n'$1
}

function forceExecuteCommand() {
    cmd=$1
    echo "$cmd"
    eval  $cmd  || printError $2 > /dev/null 2>&1
    echo "done"
    echo ""
}

function printErrors() {
    echo $errors
}

function createSymLinks() {
    local client_dir=$1
    local absolute_current_dir=$2
    switchSymLinks $client_dir $absolute_current_dir
    forceExecuteCommand "ln -fs $absolute_current_dir/local.php $client_dir/local.php && \
 ln -fs $absolute_current_dir/.htaccess  $client_dir/.htaccess && \
 ln -fs ../$absolute_current_dir/cosmogramme/.htaccess  $client_dir/cosmogramme/.htaccess" "can't link to ../$absolute_current_dir" "Unable_to_link_file_in_$client_dir"
}

function switchSymLinks() {
    local client_dir=$1
    local absolute_current_dir=$2

    forceExecuteCommand "ln -fs $absolute_current_dir/index.php $client_dir/index.php && \
 ln -fs $absolute_current_dir/includes.php $client_dir/includes.php && \
 ln -fs $absolute_current_dir/local.php $client_dir/local.php && \
 ln -fs $absolute_current_dir/library $client_dir/ && \
 ln -fs $absolute_current_dir/console.php $client_dir/console.php && \
 ln -fs $absolute_current_dir/public $client_dir/ && \
 ln -fs $absolute_current_dir/amber $client_dir/ && \
 ln -fs $absolute_current_dir/ckeditor $client_dir/ && \
 ln -fs $absolute_current_dir/xhprof $client_dir/ && \
 ln -fs $absolute_current_dir/scripts $client_dir/ && \
 ln -fs $absolute_current_dir/.htaccess  $client_dir/.htaccess && \
 ln -fs ../$absolute_current_dir/cosmogramme/.htaccess  $client_dir/cosmogramme/.htaccess && \
 ln -fs ../$absolute_current_dir/cosmogramme/index.php $client_dir/cosmogramme/index.php && \
 ln -fs ../$absolute_current_dir/cosmogramme/cosmozend $client_dir/cosmogramme/ && \
 ln -fs ../$absolute_current_dir/cosmogramme/css $client_dir/cosmogramme/ && \
 ln -fs ../$absolute_current_dir/cosmogramme/images $client_dir/cosmogramme/ && \
 ln -fs ../$absolute_current_dir/cosmogramme/java_script $client_dir/cosmogramme/ && \
 ln -fs ../$absolute_current_dir/cosmogramme/php $client_dir/cosmogramme/ && \
 ln -fs ../$absolute_current_dir/cosmogramme/sql $client_dir/cosmogramme/" "can't link to ../$absolute_current_dir" "Unable_to_link_file_in_$client_dir"
}


function cloneBranch() {
    local BRANCH=$1
    local BASE_PATH=$2
    local SUBDIR_BRANCH="branches"

    branch_dir="$BASE_PATH/$SUBDIR_BRANCH"
    executeCommand "mkdir -p $branch_dir && cd $branch_dir"

    if [ -d $BRANCH ]; then
        nextStep "Update $BRANCH"
        executeCommand "cd $BRANCH; git reset --hard HEAD; " "error on reset"
    else
        nextStep "Clone $BRANCH"
        executeCommand "git clone -b $BRANCH $REPO $BRANCH; cd $BRANCH"  "Unable to clone"
    fi

    nextStep "Switch to version $BRANCH"
    executeCommand 'git fetch -t --all' '[ERROR] Unable to fetch'
    executeCommand 'git pull --rebase' '[ERROR] Unable to rebase'

    updateSubmodules
}


function cloneBlessedBranch() {
    local BLESSED_BRANCH=$1
    
    if [ -d "bokeh-"$BLESSED_BRANCH ]; then
        nextStep "Update $BLESSED_BRANCH branch"
        executeCommand "cd bokeh-$BLESSED_BRANCH; git reset --hard HEAD; " "error on reset"
    else
        nextStep "Clone $BLESSED_BRANCH branch"
        executeCommand "git clone $REPO bokeh-$BLESSED_BRANCH; cd bokeh-$BLESSED_BRANCH"  "Unable to clone"
    fi
}


function updateSubmodules() {
    nextStep "Update submodules"
    executeCommand "git submodule init && bash update.sh" "Can't update submodules"

    nextStep "Set permissions on temp folder"
    forceExecuteCommand "chmod -R 777 temp" 

    nextStep "Check install"
}


function successMessage() {
    echo "[DONE]"
    echo "[IF NEEDED] copy and configure index.php,config.ini,cosmogramme/config.php"
    echo "Enjoy :)"
}


function errorMessage() {
    local version=$1
    echo "[ERROR] wrong version : $version"
}


function updateSymlinksAndTest() {
    local BRANCH=$1
    local CLIENT_DIR=$2
    local branch_dir=$3
    local version=`git branch |grep "^*"|cut -c3-`
    if [ "$version" == "$BRANCH" ]; then
        switchSymLinks "$CLIENT_DIR" $branch_dir
        echo '{ "branch" : "'$version'"}' >  "$branch_dir/public/opac/branch.txt"
        successMessage
    else
        errorMessage
    fi
}

function updateConfig() {
    local USERNAME=$1
    local PASSWORD=$2
    local DBNAME=$3
    local CONFIGPATH=$4
    local HOST=$5

    sed -i "s/sgbd.config.username =.*/sgbd.config.username = "$USERNAME"/g" $CONFIGPATH"/config.ini"
    sed -i "s/sgbd.config.password =.*/sgbd.config.password = "$PASSWORD"/g" $CONFIGPATH"/config.ini"
    sed -i "s/sgbd.config.dbname =.*/sgbd.config.dbname = "$DBNAME"/g" $CONFIGPATH"/config.ini"
    sed -i "s/sgbd.config.host =.*/sgbd.config.host = "$HOST"/g" $CONFIGPATH"/config.ini"
    sed -i "s/sgbd.user =.*/sgbd.config.user = admpergame/g" $CONFIGPATH"/config.ini"
    sed -i "s/sgbd.user =.*/sgbd.config.pwd = "$PASSWORD"/g" $CONFIGPATH"/config.ini"

    sed -i "s/integration_server=.*/integration_server="$HOST"/g" $CONFIGPATH"/cosmogramme/config.php"
    sed -i "s/integration_user=.*/integration_user="$USERNAME"/g" $CONFIGPATH"/cosmogramme/config.php"
    sed -i "s/integration_pwd=.*/integration_pwd="$PASSWORD"/g" $CONFIGPATH"/cosmogramme/config.php"
    sed -i "s/integration_base=.*/integration_base="$DBNAME"/g" $CONFIGPATH"/cosmogramme/config.php"
    sed -i "s/pwd_master=.*/pwd_master=ifa"$PASSWORD"/g" $CONFIGPATH"/cosmogramme/config.php"
}

function upgradeDb() {
    local exec_dir=${1%/}
    local client_dir=${2%/}

    ## cd $client_dir is required to access console.php
    cd $client_dir
    php $exec_dir/php/set_patch_level.php

    if [[ `echo "$?"` != 0 ]]
    then
        echo "Error occurs while setting patch level"
        exit 1
    fi

    php scripts/upgrade_db.php

    cd $exec_dir
}
