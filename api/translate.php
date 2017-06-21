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

	//1. check phrase in sqldb
	$db = DB::connectDefault();
	if ($lang_src == "spa") {
		$q = "select '".$short_dst."' as lang,dst.word as text from rel_es_".$short_dst." r"
			." join word_es src on r.id_es=src.id"
			." join word_".$short_dst." dst on r.id_".$short_dst."=dst.id"
			." where src.word=?";
	}
	else {
		$q = "select '".$short_dst."' as lang,dst.word as text from rel_es_".$short_src." r"
			." join word_es dst on r.id_es=dst.id"
			." join word_".$short_src." src on r.id_".$short_src."=src.id"
			." where src.word=?";
	}
	$r=$db->query($q,array("1"=>$phrase));

	//2. if exists echo json_encode and return
	if ($r===false) {
		logstr($db->qstr());
		logstr($db->errmsg());
		return ;
	}
	$a = array();
	while ($row=$r->fetch()) $a[]=$row;
	logstr($db->qstr()); logstr("items: ".sizeof($a));
	if (sizeof($a) > 0) {
		echo json_encode(array("source"=>"esp-db","from"=>$short_src,"dest"=>$short_dst,"phrase"=>$a));
		return ;
	}

	//3. get translation from external
	$r=apicall("GET","https://glosbe.com/gapi/translate",array("from"=>$lang_src,"dest"=>$lang_dst,"phrase"=>$phrase,"format"=>"json"));

	//4. reformat
	$o = json_decode($r);
	$a=array();
	foreach ($o->tuc as $item) {
		if (!property_exists($item,"phrase")) continue;
		$a[] = array("lang"=>$item->phrase->language, "text"=>$item->phrase->text);
	}
	echo json_encode(array("source"=>"glosbe.com","from"=>$short_src,"dest"=>$short_dst,"phrase"=>$a));

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
