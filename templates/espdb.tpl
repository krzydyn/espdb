<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl">
<head>
  <meta http-equiv="Content-type" content="text/html;charset=<%val("charset")%>" />
  <meta name="viewport" content="width=device-width, initial-scale=1" /> 
  <title>KrzychoTeka</title>
  <link rel="stylesheet" href="css/style.css" type="text/css"/>  
  <script src="ajax.js"></script>
</head>
<body onload="loadParts()">
<h1>KrzychoTeka</h1>
<div class="content">
<div class="pl"><input id="pl" type="text" size="20" name="pl"></div>
<div class="es"><input id="es" type="text" size="20" name="es"></div>
<div class="en"><input id="en" type="text" size="20" name="es"></div>
<div class="buttons"><input type="button" value="add" onclick="javascript:addWords('pl','es','en')"></div>
<%if(valExist("content")){%>
<div class="<%val2class("content")%>">
</div>
<%}%>
</div>
<br>

<script type="text/javascript">
var ajax = new Ajax();
var onPartReady = function(rc,tx) {
	if (rc != 200) {
		console.log('ready rc='+rc);
		return ;
	}
	try{
		var parts = JSON.parse(tx);
		console.log(parts);
	}catch(e) { console.log('cannot parse: '+tx); }
}

function loadParts() {
}
function saveOfflineExample() {
	localStorage.colorSetting = '#a4509b';
	localStorage['colorSetting'] = '#a4509b';
	localStorage.setItem('colorSetting', '#a4509b');
}
function addWords() {
	var w='';
	var n=0;
	for (var i=0; i < arguments.length; ++i) {
		var v = $(arguments[i]).value;
		if (!v) continue;
		if (n>0) w+='&';
		w+=arguments[i]+'='+v;
		++n;
	}
	console.log('put '+w);
	ajax.async('put','addWords?'+w,onPartReady);
}
//setTimeout(loadParts,1);
</script>
</body></html>

