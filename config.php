<?php
date_default_timezone_set("Europe/Warsaw");
$config=array();
$config["appname"]="espanol";

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
$config["cmslib"]=strtr(dirname(__FILE__),"\\","/")."/../cms/lib/";
$config["cmsurl"]="/cms/";

$config["rootdir"]=strtr(dirname(__FILE__),"\\","/")."/"; //path to the site files
$config["rooturl"]=dirname($_SERVER["PHP_SELF"])."/"; //url to the site
$config["cachedir"]="cache/"; //relative to rootdir
$config["templatedir"]=array($config["rootdir"]."templates/");
$config["templateexpired"]="force"; //modtime

$config["fck"]="/cms/ckeditor/";//FCK install dir
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
