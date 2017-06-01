<?
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
	//$req->setval("error",$e->getMessage());
}
/*$req=Request::getInstance();
echo "<pre>";
print_r($req);
exit;

$srv=$req->getval("srv");
echo "qs=".$srv["QUERY_STRING"]."\n";
echo "req=".$srv["REQUEST_URI"]."\n";
 */

$t = new TemplateEngine();
$t->load("espdb.tpl");
?>
