<?
require_once("config.php");
require_once($config["cmslib"]."modules.php");

$req=Request::getInstance();
echo json_encode($req->getval());
?>
