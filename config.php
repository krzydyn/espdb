<?php
date_default_timezone_set("Europe/Warsaw");
$config=array();
$config["appname"]="espanol";

ini_set('display_errors','On');
//ini_set('error_log','cache/error.log');
//
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
$config["dbtype"]="sqlite3";
$config["dbname"]="db/esp.sqlite";

$config["sitetitle"]="Espanol DB";
$config["lang"]="pl";

$config["uploaddir"]="";

?>
