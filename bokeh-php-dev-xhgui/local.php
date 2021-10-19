<?php
define('MEMCACHED_ENABLE', true);
define('MEMCACHED_HOST', 'MEMCACHEHOST');
define('MEMCACHED_PORT', '11211');

ini_set('xdebug.remote_port', 'XDEBUGPORT');
ini_set('xdebug.remote_host', 'DOCKERHOST');

if (function_exists('tideways_xhprof_enable')) {
  define('XHGUI_CONFIG_DIR', '/home/webmaster/www/xhgui/config/');
  require_once '/home/webmaster/www/xhgui/vendor/perftools/xhgui-collector/external/header.php';
}
?>
