<?php
require_once("config.php");
require_once($config["cmslib"]."modules.php");

$req=Request::getInstance();
$req->setval("cfg",null);
$req->setval("srv",null);
echo json_encode($req->getval());
?>
