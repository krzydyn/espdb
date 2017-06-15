<?php
require_once("config.php");
require_once($config["cmslib"]."router.php");
require_once($config["cmslib"]."request.php");
/*echo "<pre>";
print_r(Request::getInstance()->getval(""));
echo "</pre>";
exit;*/

$r = new Router();
//static content
$r->addRoute("GET","/.*(css|js)",function() {
	$req=Request::getInstance();
	$f=".".$req->getval("uri");
	if (file_exists($f)) {
		header("Content-Type: ".make_content_type($f));
		readfile($f);
	}
	else {
		header($req->getval("srv.SERVER_PROTOCOL")." 404 Not Found", true, 404);
	}
});

$r->addRoute("GET","/ajax\\.js",function() {
	$f="../ajax.js";
	header("Content-Type: ".make_content_type($f));
	readfile($f);
});

//valid php scripts
$r->addRoute("","/addWords.*",function() {
	global $config;
	require_once("./addwords.php");
	addWords();
});

$r->addRoute("GET","/",function() {
global $config;
require_once("espdb.php");
try{
	$a = new EspDB();
	$a->initialize();
	$a->process();
	unset($a);
}
catch(Exception $e)
{
	echo "Exception: ".$e->getMessage().";";
}
$t = new TemplateEngine();
$t->load("espdb.tpl");
});

$r->addRoute("","",function() {
	$req=Request::getInstance();
	header($req->getval("srv.SERVER_PROTOCOL")." 404 Not Found", true, 404);
});

$r->route(Request::getInstance()->getval("method"), Request::getInstance()->getval("uri"));
?>
