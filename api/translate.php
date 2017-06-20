<?php
require_once($config["cmslib"]."rest.php");
function api_translate($lang_src,$lang_dst,$phrase) {
	//echo json_encode(array($w, "OK"));
	logstr("api_translate(".$lang_src.",".$lang_dst.",".$phrase.")");
	$r=apicall("GET","https://glosbe.com/gapi/translate",array("from"=>$lang_src,"dest"=>$lang_dst,"phrase"=>$phrase,"format"=>"json"));
	echo $r;
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
