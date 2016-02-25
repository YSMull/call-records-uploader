<?php

define('hostname', 'localhost');
define('user', 'root');
define('password', '*****');
define('databaseName', 'huanhuan');

$connect = mysqli_connect(hostname, user, password, databaseName);
//$connect = mysql_connect("")
/*if(!$connect) {
    die('haha ' . mysql_error());
} else {
    echo 'connect sucess!';
}*/


?>
