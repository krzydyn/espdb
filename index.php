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
$r->addRoute("","/.*",function() {
	echo "default (can't handle)";
});

echo "<pre>";
//print_r(Request::getInstance()->getval("srv"));
$r->route(Request::getInstance()->getval("req.method"), Request::getInstance()->getval("uri"));
?>
