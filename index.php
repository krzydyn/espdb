<?php
require_once("config.php");
require_once($config["lib"]."php/router.php");
require_once($config["lib"]."php/request.php"); //ob_start

$r = new Router();
//static content
$r->addRoute("GET","/favicon.ico",function() {//args[0] constain whole match
	$req=Request::getInstance();
	$f="./icony/flags-lg/sp-lgflag.gif";
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
	$f=".".$req->getval("uri");
	header("Content-Type: ".make_content_type($f));
	readfile($f);
});

//rest api -> json
$r->addRoute("","/api/(\\w+).*",function() {
	global $config;
	$req=Request::getInstance();
	$args = func_get_args();
	//logstr("args = ".print_r($args, true));
	if (sizeof($args) > 1) {
		$func = strtolower($args[1]);
	}
	else {
		logstr("err: no args");
		$func = "-";
	}
	$f = "./api/".$func.".php";
	if (!file_exists($f)) {
		//header($req->getval("srv.SERVER_PROTOCOL")." 404 Not Found", true, 404);
		echo json_encode(array("error"=>"Method not exist"));
		return ;
	}
	require_once($f);

	logstr("api: ".$func);
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
		logstr("autocomplete: lang=".$lang." phrase=".$req->getval("req.phrase"));
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
	$a = new EspDB();
	$a->initialize();
	$a->process();
	unset($a);
	$t = new TemplateEngine();
	$t->load("espdb.tpl");
});

$r->addRoute("","",function() {
	$req=Request::getInstance();
	header($req->getval("srv.SERVER_PROTOCOL")." 404 Not Found", true, 404);
});

logstr("processing uri ".Request::getInstance()->getval("uri"));
$r->route(Request::getInstance()->getval("method"), Request::getInstance()->getval("uri"));
?>
