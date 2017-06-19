<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl">
<head>
  <meta http-equiv="Content-type" content="text/html;charset=<%val("charset")%>" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>KrzychoTeka</title>
  <link rel="stylesheet" href="<%val("cfg.rooturl")%>css/style.css" type="text/css"/>
  <script src="<%val("cfg.rooturl")%>ajax.js"></script>
</head>
<body onload="loadParts()">
<h1>KrzychoTeka</h1>
<div class="content">
<div class="search">
	<span class="es"><input id="word_es" type="text" size="20" name="es" value="<%val("req.word_es")%>"></span>
	<span class="buttons"><input type="button" value="search" onclick="javascript:translateWord('word_es')"></span>
</div>
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
var onTranslateReady = function(rc,tx) {
	if (rc != 200) {
		console.log('ready rc='+rc);
		return ;
	}
	try{
		var t = JSON.parse(tx);
		console.log(t);
	}catch(e) { console.log('cannot parse: '+tx); }
}
var onAddWordReady = function(rc,tx) {
}

function loadParts() {
}

function saveOfflineExample() {
	localStorage.colorSetting = '#a4509b';
	localStorage['colorSetting'] = '#a4509b';
	localStorage.setItem('colorSetting', '#a4509b');
}

function translateWord() {
	var w='';
	var n=0;
	var u=''
	for (var i=0; i < arguments.length; ++i) {
		var v = $(arguments[i]).value;
		if (!v) continue;
		if (n>0) {w+='&';u+=',';}
		u+=v;
		w+=arguments[i]+'='+v;
		++n;
	}
	//history.pushState('', 'KrzychoTeka: '+u, '<%val("cfg.rooturl")%>'+u);
	history.replaceState('', 'KrzychoTeka: '+u, '<%val("cfg.rooturl")%>'+u);
	ajax.async('get','<%val("cfg.rooturl")%>api/translate?'+w,onTranslateReady);
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
	ajax.async('put','<%val("cfg.rooturl")%>api/addwords?'+w,onAddWordReady);
}

</script>
</body></html>

