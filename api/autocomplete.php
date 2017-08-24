<?php
require_once($config["cmslib"]."rest.php");
function langCodeShort($lang) {
	switch ($lang) {
		case "spa": return "es";
		case "pol": return "pl";
		case "eng": return "en";
	}
}
function api_autocomplete($lang_src,$phrase) {
	$short_src=langCodeShort($lang_src);

	$p=strtr($phrase,array("%"=>""));
	if (empty($p)) {
		echo json_encode(array());
		return ;
	}

	//1. check phrase in sqldb
	$db = DB::connectDefault();
	$q = "select word as text from word_".$short_src." src where src.word like ? order by src.word";
	//what is escape char for '%'?
	$r=$db->query($q,array("1"=>$phrase."%"));

	if ($r===false) {
		$this->addval("error","DB:".$db->errmsg());
		return ;
	}

	//2. if exists echo json_encode and return
	$tr = array();
	$n=0;
	while ($row=$r->fetch()) {
		$tr[]=$row;
		++$n;
	}
	echo json_encode(array("source"=>"esp-db","lang"=>$short_src,"ac"=>$tr));
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
