<?php
require_once("config.php");
require_once($config["cmslib"]."router.php");
require_once($config["cmslib"]."request.php"); //ob_start

$r = new Router();
//static content
$r->addRoute("GET","/favicon.ico",function() {//args[0] constain whole match
	$req=Request::getInstance();
	$f="../icony/flags-lg/sp-lgflag.gif";
	if (file_exists($f)) {
		header("Content-Type: ".make_content_type($f));
		readfile($f);
	}
	else {
		header($req->getval("srv.SERVER_PROTOCOL")." 404 Not Found", true, 404);
	}
});
$r->addRoute("GET","/.*(css|js|html)",function() {
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
$r->addRoute("GET","/icony/.*",function() {
	$req=Request::getInstance();
	$f="..".$req->getval("uri");
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

//rest api -> json
$r->addRoute("","/api/(\\w+).*",function() {
	global $config;
	$req=Request::getInstance();
	$args = func_get_args();
	$func = strtolower($args[1]);
	$f = "./api/".$func.".php";
	if (!file_exists($f)) {
		//header($req->getval("srv.SERVER_PROTOCOL")." 404 Not Found", true, 404);
		echo json_encode(array("error"=>"Method not exist"));
		return ;
	}
	require_once($f);

	$func = "api_".$func;
	if ($func=="api_translate") {
		$lang=$req->getval("req.lang");
		$dst="pol";
		if ($lang=="pl") {$lang="pol";$dst="spa";}
		else if ($lang=="en") {$lang="eng";$dst="spa";}
		else {$lang="spa";}
		$func($lang,$dst,$req->getval("req.phrase"));
	}
	else if ($func=="api_autocomplete") {
		$lang=$req->getval("req.lang");
		if ($lang=="pl") $lang="pol";
		else if ($lang=="en") $lang="eng";
		else $lang="spa";
		$func($lang,$req->getval("req.phrase"));
	}
	$c = ob_get_contents();
	ob_end_clean();
	if ($c) $req->addval("error",$c);
	$r = $req->getval("result");
	$c = $req->getval("error");
	if ($c) $r["error"]=$c;
	echo json_encode($r);
});

$r->addRoute("GET","/.*",function() {
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
