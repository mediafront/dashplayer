<?php
require_once("DashPlaylist.php");
$playlist = new DashPlaylist( (isset($_GET['playlist']) ? $_GET['playlist'] : 'default') );
$playlist->show();   
?>