<?php
require_once("config.php");
require_once($config["cmslib"]."modules.php");
require_once($config["cmslib"]."application.php");
require_once($config["cmslib"]."model.php");

define('DEFAULT_TAB',"");

class Session extends ModelObject
{
	var $uid;
	var $hash;
	var $host;
	var $tmses;
	var $tmstamp;
	var $sesdata;
	function getPK(){return array("uid","hash");}

	function __wakeup()
	{
	}
	function __sleep()
	{
		return array_keys(get_object_vars($this));
	}
}
class User extends ModelObject
{
	var $id;
	var $name;
	var $passwd;
	var $role;
	var $fullname;
	var $email;
	function toString(){return $this->fullname!==null?$this->fullname:$this->name;}
}
class Tense extends ModelObject {
	var $name;
	var $descr;
}
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
		$this->dao=new ObjectDB($db);
		$this->ses=null;
		$this->user=null;

		$reqtabs=array(
			"session"=>"uid int not null,hash varchar(80) not null,host varchar(63),tmses int,tmstamp int,".
				"sesdata text,unique(uid,hash)",
			"user"=>"id integer primary key,name varchar(63) not null,role int not null default 2,passwd varchar(32)not null default '',".
				"fullname varchar(255)not null default '',email varchar(255)not null default '',unique(name)",

			"person"=>"id INTEGER PRIMARY KEY,name VARCHAR,gender INTEGER,UNIQUE(name)",
			"word"=>"id INTEGER PRIMARY KEY,word VARCHAR,UNIQUE(word)",
			"conjugation"=>"id_word_infinitive INTEGER,id_tense INTEGER,id_person INTEGER,id_word INTEGER",
			"tense"=>"",
		);
		$tabs=$db->tables();
		if ($tabs===false) {
			$this->addval("error","DB:".$db->errmsg());
			return false;
		}

		while (list($t,$v)=each($reqtabs)) {
			if (in_array($t,$tabs)) continue;
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
				echo "no file: ".$sql;
			}
		}

		if ($db->tabcount("user")==0) {
			$r=$db->tabinsert("user",array("name"=>"admin","role"=>"0","passwd"=>md5("admin")));
			if ($r===false) $this->addval("error","DB ins:".$db->errmsg());
			$r=$db->tabinsert("user",array("name"=>"krzydyn","role"=>"1","passwd"=>md5("test")));
			if ($r===false) $this->addval("error","DB ins:".$db->errmsg());
		}
	}
	function getSession() {return $this->ses;}
	function getUser() {return $this->user;}

	function process(){
		global $config;

		$this->authenticate();
		parent::process();

		$tab=$this->getval("req.tab");
		$cont=$tab;
		while (!searchdir($config["templatedir"],$cont.".tpl")){
			//echo $cont.".tpl not found\n";
			if (($i=strrpos($cont,"/"))===false) {$cont=DEFAULT_TAB; break;}
			$cont=substr($cont,0,$i);
		}
		if (empty($cont)) $this->setval("content",null);
		else $this->setval("content",$cont);
	}
	function defaultAction(){
		$tab=$this->getval("req.tab");
		if (substr($tab,0,5)=="conf/") $this->listConf(substr($tab,5));
	}

	function listConf($t){
		if (!class_exists($t)) {
			echo "class '".$t."' not found\n";
			return ;
		}
		$obj=new $t();
		$this->setval("rec",$obj);
		$crit=new Criteria();
		$crit->setOrder($obj->defaultOrder());
		$fld=null;
		if ($t == "person") {
			$fld=array("group_concat(name)as name","group_concat(gender)as gender","number","conj_form");
			$crit->setGroup("conj_form");
		}
		$r=$this->dao->find($obj,$fld,$crit);
		if ($r===false) {
			$this->addval("error","DB find:".$this->dao->errmsg());
			return ;
		}
		for ($i=0; $i<sizeof($r); ++$i){
			$row=$r[$i]; reset($row);
			while (list($f,$v)=each($row)){
				if (strpos($f,"tm")!==false && preg_match("/^[1-9][0-9]{8,10}$/",$v))
					$row->{$f}=strftime("%Y-%m-%d %H:%M:%S",$v);
			}
		}
		$this->setval("result",$r);
	}
	function authenticate(){
		if (is_object($this->ses)) {
			logstr("ses is obj");
			return true;
		}
		$hash=$this->getval("req.hash");
		if (empty($hash)) {
			logstr("hash is empty");
			return false;
		}
		logstr("hash is $hash");

		$this->setval("req.hash");
		$crit=new Criteria("hash",$hash);
		$r=$this->dao->find(new Session(),null,$crit);
		if (sizeof($r)==0){
			setcookie("hash");
			if ($this->getval("req.act")=="logout") return false;
			$this->addval("error","Invalid session key /".sizeof($r));
			return false;
		}
		//hash is unique key, so now must sizeof($r)=1
		$ses=$r[0];
		$tm=time();
		if ($ses->tmstamp+3600<$tm){
			setcookie("hash");
			$this->dao->del($ses);
			if ($this->getval("req.act")=="logout") return false;
			$this->addval("error","Session expired");
			return false;
		}
		$this->dao->db->tabdelete("session","where tmses<".($tm-24*3600));

		$ses->tmstamp=$tm;
		$this->dao->update($ses); //update timestamp
		$this->ses=&$ses;
		setcookie("hash",$this->ses->hash);
		$this->setval("req.hash",$this->ses->hash);
		if ($ses->uid==0) return true; //no user for this session

		$crit->clear();
		$crit->addop("id",$ses->uid);
		$r=$this->dao->find(new User(),null,$crit);
		if (sizeof($r)!=1){
			$this->addval("error","Invalid user refference /".sizeof($r));
			setcookie("hash");return false;
		}
		$this->user=&$r[0];
		$this->setval("user",$this->user);
		return true;
	}
}

?>
