<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl">
<head>
  <meta http-equiv="Content-type" content="text/html;charset=<%val("charset")%>" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>KrzychoTeka</title>
  <link rel="stylesheet" href="<%val("cfg.rooturl")%>css/style.css" type="text/css"/>
  <script src="<%val("cfg.rooturl")%>ajax.js"></script>
</head>
<body onload="loadFromArgs()">
<h1>KrzychoTeka</h1>
<div class="content">
<div class="pack left">
	<div class="searchbar border-in">
	<form><!-- put inside form tag for auto-submit with Enter key -->
	<span class="label">Enter phrase in</span>
	<!-- https://stackoverflow.com/questions/2965971/how-to-add-a-images-in-select-list -->
	<select id="lang" name="lang">
		<option value="es" <%if(val("req.lang")=="es") echo "selected"%>>español</option>
		<option value="pl" <%if(val("req.lang")=="pl") echo "selected"%>>polski</option>
		<option value="en" <%if(val("req.lang")=="en") echo "selected"%>>english</option>
	</select>
	<br>
	<span class="es"><input id="phrase" type="text" size="15" name="phrase" value="<%val("req.phrase")%>"></span>
	<span class="button"><input type="submit" value="search" onclick="javascript:translateWord();return false;"></span>
	</form>
	</div>
	<div id="source" class="source right"></div>
	<div id="result" class="result"></div>
</div>
</div>
<br>

<script type="text/javascript">
var onTranslateReady = function(rc,tx) {
	if (rc != 200) {
		console.log('ready rc='+rc);
		return ;
	}
	var txt='';
	var dbsrc='';
	try{
		var r = JSON.parse(tx);
		console.log(r);
		dbsrc = 'source: '+r.source;
		var dst = r.dest;
		var tr = r.tr;
		if (tr.length==0) txt+='Phrase not found';
		else {
			txt+='<table>';
			for (var j=0; j < tr.length; ++j) {
				var cnt=1;
				if (tr.length > 1) txt+='<tr><th colspan="2">'+tr[j].phrase+'</th></tr>';
				var data = tr[j].data;
				for (var i=0; i < data.length; ++i) {
					if (data[i].lang==dst) {
						txt+='<tr><td class="right">'+cnt+'.&nbsp;</td><td>'+data[i].text+'</td></tr>';
						++cnt;
					}
				}
			}
			txt+='</table>';
		}
	}catch(e) {
		if (e instanceof SyntaxError) console.log(tx);
		console.log(e.stack);
	}
	$('source').innerHTML = dbsrc;
	$('result').innerHTML = txt;
}

var ajax = new Ajax();
function loadFromArgs() {
	translateWord();
}

function translateWord() {
	var lang=$('lang').value.trim().toLowerCase();
	var w=$('phrase').value.trim().toLowerCase();
	if (w) {
		document.title = 'KrzychoTeka - '+w;
		var u='phrase='+w+'&lang='+lang;
		ajax.async('get','<%val("cfg.rooturl")%>api/translate?'+u,onTranslateReady);
	}
	else {
		document.title = 'KrzychoTeka';
	}
	//history.pushState('', document.title, );
	history.replaceState('', document.title, '<%val("cfg.rooturl")%>'+lang+'/'+w);
}

function addWords() {
	var w='';
	var n=0;
	for (var i=0; i < arguments.length; ++i) {
		var v = $(arguments[i]).value;
		if (!v) continue;
		if (n>0) w+='&';
		w+=arguments[i]+'='+v.trim().toLowerCase();
		++n;
	}
	console.log('put '+w);
	ajax.async('put','<%val("cfg.rooturl")%>api/addwords?'+w,onAddWordReady);
}
</script>
</body></html>
