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
	logstr("api_translate(".$lang_src.",".$lang_dst.",".$phrase.")");

	$short_src=langCodeShort($lang_src);
	$short_dst=langCodeShort($lang_dst);

	$p=strtr($phrase,array("%"=>""));
	if (empty($p)) {
		echo json_encode(array("source"=>"esp-db","from"=>$short_src,"dest"=>$short_dst,"tr"=>array()));
		return ;
	}

	//1. check phrase in sqldb
	$db = DB::connectDefault();
	if ($lang_src == "spa") {
		$q = "select src.word as phrase,'".$short_dst."' as lang,dst.word as text from rel_es_".$short_dst." r"
			." join word_es src on r.id_es=src.id"
			." join word_".$short_dst." dst on r.id_".$short_dst."=dst.id"
			." where src.word like ? order by src.word";
	}
	else {
		$q = "select src.word as phrase,'".$short_dst."' as lang,dst.word as text from rel_es_".$short_src." r"
			." join word_es dst on r.id_es=dst.id"
			." join word_".$short_src." src on r.id_".$short_src."=src.id"
			." where src.word like ? order by src.word";
	}
	//what is escape char for '%'?
	$r=$db->query($q,array("1"=>$phrase."%"));

	//2. if exists echo json_encode and return
	if ($r===false) {
		logstr($db->qstr());
		logstr($db->errmsg());
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
	logstr($db->qstr()); logstr("items: ".$n);
	if ($n > 0) {
		echo json_encode(array("source"=>"esp-db","from"=>$short_src,"dest"=>$short_dst,"tr"=>$tr));
		return ;
	}

	//3. get translation from external
	$r=restApi("GET","https://glosbe.com/gapi/translate",array("from"=>$lang_src,"dest"=>$lang_dst,"phrase"=>$phrase,"format"=>"json"));
	logstr("GLOSBE(raw):".print_r($r,true));

	//4. reformat
	$o = json_decode($r);
	//logstr("GLOSBE:".print_r($o,true));
	$tr = array();
	$a = array();
	foreach ($o->tuc as $item) {
		if (!property_exists($item,"phrase")) continue;
		$a[] = array("lang"=>$item->phrase->language, "text"=>$item->phrase->text);
	}
	if (sizeof($a) > 0)
		$tr[] = array("phrase"=>$phrase, "data"=>$a);
	echo json_encode(array("source"=>"<a href=\"https://glosbe.com\">glosbe.com</a>","from"=>$short_src,"dest"=>$short_dst,"tr"=>$tr));

	//5. save to sqldb
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
