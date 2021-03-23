<?php
define("PATH_TEMP",  "./temp/") ;
define('SMTP_HOST', 'localhost');

// plage d'ouverture pour les bots
define('BOT_ALLOWED_START_HOUR', 22);
define('BOT_ALLOWED_END_HOUR', 8);

//memcached
define('MEMCACHED_ENABLE', true);
define('MEMCACHED_HOST', 'MEMCACHEHOST');
define('MEMCACHED_PORT', '11211');

define('IMAGE_MAGIC_PATH', '/usr/bin/convert');
define('FORBIDEN_URLS', serialize(['opac3.pergame.net', 'web.afi-sa.net']));

define('MAX_SEARCH_RESULTS', '200000');

define('STATUS_REPORT_TAGS', 'stable;AFI');
ini_set('xdebug.remote_port', 'XDEBUGPORT');
ini_set('xdebug.remote_host', 'DOCKERHOST');
