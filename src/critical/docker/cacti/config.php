<?php
$database_type     = 'mysql';
$database_default  = getenv('MYSQL_DATABASE');
$database_hostname = getenv('MYSQL_HOST');
$database_username = getenv('MYSQL_USER');
$database_password = getenv('MYSQL_PASSWORD');
$database_port     = '3306';
$database_retries  = 5;
$database_ssl      = false;
$database_ssl_key  = '';
$url_path = '/';
$cacti_session_name = 'Cacti';
$cacti_db_session = false;
?>
