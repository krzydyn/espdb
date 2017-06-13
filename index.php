<?php
require_once("config.php");
require_once($config["cmslib"]."router.php");
require_once($config["cmslib"]."request.php");

$r = new Router();
$r->addRoute("GET","/.*css",function() {
	readfile("css".Request::getInstance()->getval("uri"));
});
$r->addRoute("GET","/.*js",function() {
	readfile("js".Request::getInstance()->getval("uri"));
});
$r->addRoute("GET","/index2.php",function() {
	echo "index2";
});
$r->addRoute("GET","/.*",function() {
	echo "/";
});
$r->addRoute("","",function() {
	echo "default (can't handle)";
});

echo "<pre>";
echo "root URI=".Request::getInstance()->getval("cfg.rooturl")."\n";
echo "absolute URI=".Request::getInstance()->getval("abs-uri")."\n";
echo "local URI=".Request::getInstance()->getval("uri")."\n";
print_r(Request::getInstance()->getval("req"));
//print_r(Request::getInstance()->getval("srv"));
$r->route(Request::getInstance()->getval("method"), Request::getInstance()->getval("uri"));
?>
