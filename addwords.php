<?php
require_once("config.php");
require_once($config["cmslib"]."modules.php");

function addWords() {
	$a=Request::getInstance()->getval("req");
	$pl=@$a["pl"];
	$es=@$a["es"];
	$en=@$a["en"];
	logstr("addWords: pl=$pl es=$es en=$en");
	echo json_encode("OK");
}
?>
