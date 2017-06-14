<?php
require_once("config.php");
require_once($config["cmslib"]."router.php");
require_once($config["cmslib"]."request.php");

$r = new Router();
$r->addRoute("GET","/.*css",function() {
	$req=Request::getInstance();
	$f=".".$req->getval("uri");
	if (file_exists($f))
		readfile($f);
	else {
		header($req->getval("srv.SERVER_PROTOCOL")." 404 Not Found", true, 404);
	}
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

$r->route(Request::getInstance()->getval("method"), Request::getInstance()->getval("uri"));

echo "<pre>";
print_r(Request::getInstance()->getval("req"));
echo "root URI=".Request::getInstance()->getval("cfg.rooturl")."\n";
echo "absolute URI=".Request::getInstance()->getval("abs-uri")."\n";
echo "local URI=".Request::getInstance()->getval("uri")."\n";
?>
