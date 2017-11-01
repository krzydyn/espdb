<?php
require_once($config["cmslib"]."rest.php");
function langCodeShort($lang) {
	switch ($lang) {
		case "spa": return "es";
		case "pol": return "pl";
		case "eng": return "en";
	}
}
function api_translate($lang_src,$lang_dst,$phrase) {
	$req=Request::getInstance();

	$short_src=langCodeShort($lang_src);
	$short_dst=langCodeShort($lang_dst);

	$p=strtr($phrase,array("%"=>""));
	if (empty($p)) {
		$req->setval("result",array("source"=>"esp-db","from"=>$short_src,"dest"=>$short_dst,"tr"=>array()));
		return ;
	}

	//1. check phrase in sqldb
	$db = DB::connectDefault();
	if ($lang_src == "spa") {
		$q = "select src.word as phrase,'".$short_dst."' as lang,dst.word as text from rel_es_".$short_dst." r"
			." join word_es src on r.id_es=src.id"
			." join word_".$short_dst." dst on r.id_".$short_dst."=dst.id"
			." where src.word like ? order by src.word,r.prio";
	}
	else {
		$q = "select src.word as phrase,'".$short_dst."' as lang,dst.word as text from rel_es_".$short_src." r"
			." join word_es dst on r.id_es=dst.id"
			." join word_".$short_src." src on r.id_".$short_src."=src.id"
			." where src.word like ? order by src.word,r.prio";
	}
	//what is escape char for '%'?
	$r=$db->query($q,array("1"=>$phrase."%"));

	if ($r===false) {
		$req->addval("error","DB:".$db->errmsg());
		return ;
	}

	$tr = array();
	$a = array();
	$p = "";
	$n=0;
	while ($row=$r->fetch()) {
		if (empty($p)) $p=$row["phrase"];
		if ($p != $row["phrase"]) {
			$tr[] = array("phrase"=>$p, "data"=>$a);
			$p=$row["phrase"];
			$a=array();
		}
		unset($row["phrase"]);
		$a[]=$row;
		++$n;
	}
	if (sizeof($a) > 0) {
		$tr[] = array("phrase"=>$p, "data"=>$a);
	}
	$db->close();

	//2. if exists set result and return
	if ($n > 0) {
		$req->setval("result",array("source"=>"esp-db","from"=>$short_src,"dest"=>$short_dst,"tr"=>$tr));
		return ;
	}

	//3. get translation from external
	$r=restApi("GET","https://glosbe.com/gapi/translate",array("from"=>$lang_src,"dest"=>$lang_dst,"phrase"=>$phrase,"format"=>"json"));

	//4. reformat
	$o = json_decode($r);
	//logstr("GLOSBE:".print_r($o,true));
	$tr = array();
	$a = array();
	foreach ($o->tuc as $item) {
		if (!property_exists($item,"phrase")) continue;
		$a[] = array("lang"=>$item->phrase->language, "text"=>$item->phrase->text);
	}
	if (sizeof($a) > 0) {
		$tr[] = array("phrase"=>$phrase, "data"=>$a);
		//5. save to sqldb
		addTranslation($short_src,$short_dst,$tr[0]);
	}
	$req->setval("result",array("source"=>"<a href=\"https://glosbe.com\">glosbe.com</a>","from"=>$short_src,"dest"=>$short_dst,"tr"=>$tr));
}

function getId($db,$w,$lang) {
	$r = $db->query("SELECT id FROM word_".$lang." WHERE word=?",array("1"=>$w));
	if ($row=$r->fetch()) {
		return $row["id"];
	}
	return 0;
}
function addWords($db,$words,$lang) {
	$ids=array();
	logstr("addWords $lang ".implode(",",$words));
	foreach ($words as $w) {
		$w=trim($w);
		$id=getId($db,$w,$lang);
		if (!$id) {
			$r=$db->query("INSERT INTO word_".$lang." (word) VALUES (?)",array("1"=>$w));
			if ($r===false) logstr($db->errmsg());
			$id=$db->insertid();
		}
		if ($id) $ids[]=$id;
	}
	logstr("ids=".implode(",",$ids));
	return $ids;
}
function checkRel($db,$lang_src,$id_s,$lang_dst,$id_d) {
	$r = $db->query("SELECT 1 FROM rel_".$lang_src."_".$lang_dst." WHERE id_".$lang_src."=? and id_".$lang_dst."=?",
				array("1"=>$id_s,"2"=>$id_d));
	return $r->fetch();
}
function createRel($db,$lang_src,$id_src,$lang_dst,$id_dst) {
	foreach ($id_src as $id_s) {
		$prio=1;
		foreach ($id_dst as $id_d) {
			if (checkRel($db,$lang_src,$id_s,$lang_dst,$id_d)) continue;
			$q = "INSERT INTO rel_".$lang_src."_".$lang_dst." (id_".$lang_src.", id_".$lang_dst.", prio) VALUES (?, ?, ?)";
			$db->query($q,array("1"=>$id_s,"2"=>$id_d, "3"=>$prio));
			++$prio;
		}
	}
}
function addTranslation($short_src,$short_dst,$tr) {
	logstr("addTranslation($short_src,$short_dst,...)");
	$db = DB::connectDefault();
	$a=array();
	foreach ($tr["data"] as $item) {
		if ($item["lang"]==$short_dst) $a[]=$item["text"];
	}
	$id_src=addWords($db,array($tr["phrase"]),$short_src);
	$id_dst=addWords($db,$a,$short_dst);
	if ($short_src == "es")
		createRel($db,$short_src,$id_src,$short_dst,$id_dst);
	else if ($short_dst == "es")
		createRel($db,$short_dst,$id_dst,$short_src,$id_src);
}

//external translation services:
//1. https://glosbe.com/a-api
//   https://glosbe.com/gapi/{function-name}[?[{function-parameter1}={value}[&{function-parameter2}={value}[&{function-parameter3}={value}...]]]]
//2. https://www.programmableweb.com/api/bing
//	 http://api.search.live.net/
//3. https://cloud.google.com/translate/docs/reference/rest
//   https://translation.googleapis.com
//4. https://tech.yandex.com/translate/
//5. http://pl.pons.com/specials/api (need registration)

?>
