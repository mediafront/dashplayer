<?php
/**
 * Returns the Base URL of this script.
 *
 * @return - The base URL of the location of this script.
 */   
function dash_base_url() 
{
   $url = ''; 
   $url .= ( (isset($_SERVER['HTTPS']) && ($_SERVER['HTTPS'] != '')) ? "https://" : "http://"); 
   $url .= $_SERVER['HTTP_HOST']; 
   $path = ( (isset($_SERVER['REQUEST_URI']) && ($_SERVER['REQUEST_URI'] != '')) ? $_SERVER['REQUEST_URI'] : $_SERVER['PHP_SELF']); 
   $url .= pathinfo($path, PATHINFO_DIRNAME); 
   $url = rtrim($url, '/');
   $url = rtrim($url, '\\');
   $url = preg_replace("/\?".preg_quote($_SERVER['QUERY_STRING'])."/", "", $url); //remove query string if found in url
   return $url;
}
?>