<?php
date_default_timezone_set("Europe/Warsaw");
$config=array();
$config["appname"]="espanol";

$_SERVER["HTTP_HOST"]="localhost";

if ($_SERVER["HTTP_HOST"]=="localhost"){
	error_reporting(E_ALL);
	ini_set('display_errors','On');
}
else {
	error_reporting(E_ALL&~E_NOTICE);
	ini_set('display_errors','Off');
	ini_set('error_log','cache/error.log');
}

// paths setup
$config["rootdir"]=strtr(dirname(__FILE__),"\\","/")."/"; //path to the site files
$config["lib"]=$config["rootdir"]."wwwlib/";

$config["cachedir"]="cache/"; //relative to rootdir
$config["templatedir"]=array($config["rootdir"]."templates/");
$config["templateexpired"]="force"; //modtime

$config["fck"]="/wwwlib/ckeditor/";//FCK install dir
$config["fckfiledir"]="upload"; //relative to rootdir
$config["fckconfig"]="FCKconfig.js"; //relative to rooturl

// db setup
$config["debug"]["query"]="y";
//$config["dbtype"]="sqlite3";
//$config["dbname"]="db/espdb.db";
$config["dbtype"]="pdo";
$config["dbname"]="sqlite:db/espdb.db";

$config["title"]="KrzychoTeka";
$config["lang"]="pl";

$config["uploaddir"]="";

?>
