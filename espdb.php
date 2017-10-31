<?php
require_once("config.php");
require_once($config["cmslib"]."modules.php");
require_once($config["cmslib"]."application.php");
require_once($config["cmslib"]."model.php");

define('DEFAULT_TAB',"");

class Word extends ModelObject {
	var $id;
	var $word;
	var $descr;
}
class Person extends ModelObject {
	var $name;
	var $gender;
	var $number;
	var $conj_form;
	function defaultOrder(){return "conj_form";}
}
class EspDB extends Application {
	function initialize() {
		$db=DB::connectDefault();

		$reqtabs=array(
			"person"=>"",
			"word"=>"",
			"conjugation"=>"",
			"tense"=>"",
		);
		$tabs=$db->tables();
		if ($tabs===false) {
			$this->addval("error","DB:".$db->errmsg());
			return false;
		}

		while (list($t,$v)=each($reqtabs)) {
			if (in_array($t,$tabs)) continue; // if tables exists do nothing
			$sql = "sql/".$t.".sql";
			if (file_exists($sql)) {
				$r=$db->script(file_get_contents($sql));
				if ($r===false) {$this->addval("error","DB script($t):".$db->errmsg());}
			}
			else if (!empty($v)) {
				$r=$db->tabcreate($t,$v);
				if ($r===false) {$this->addval("error","DB create($t):".$db->errmsg());}
			}
			else {
				$this->addval("error","no file: ".$sql);
			}
		}
	}

	function process(){
		$uri = $this->getval("uri");
		if (preg_match("/^\\/(\\w+)\\/([^\\/]+)$/", $uri, $match)) {
			$this->setval("req.lang", $match[1]);
			$this->setval("req.phrase", urldecode($match[2]));
		}
		parent::process();
	}

	function defaultAction(){
	}
}

?>
