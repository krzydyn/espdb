<?
require_once("config.php");
require_once($config["cmslib"]."router.php");

$r = new Router();
$r->addRoute("","",hnd_1);

echo "<pre>";
print_r($_SERVER);

function hnd_1() {
}
?>
