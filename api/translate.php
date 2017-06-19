<?php
function api_translate($w) {
	echo json_encode(array($w, "OK"));
}

//external translation services:
//1. https://glosbe.com/a-api
//   https://glosbe.com/gapi/{function-name}[?[{function-parameter1}={value}[&{function-parameter2}={value}[&{function-parameter3}={value}...]]]]
//2. https://www.programmableweb.com/api/bing
//	 http://api.search.live.net/
//3. https://cloud.google.com/translate/docs/reference/rest
//   https://translation.googleapis.com
//4. https://tech.yandex.com/translate/
?>
