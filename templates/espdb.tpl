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
	<span class="label">Enter in spanish:</span><br>
	<span class="es"><input id="word_es" type="text" size="20" name="es" value="<%val("req.word_es")%>"></span>
	<span class="button"><input type="submit" value="search" onclick="javascript:translateWord('word_es');return false;"></span>
	</form>
	</div><br>
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
	try{
		var t = JSON.parse(tx);
		console.log(t);
		var tuc = t['tuc'];
		if (tuc.length==0) txt+='Phrase not found';
		else {
			var cnt=1;
			txt+='<table>';
			for (var i=0; i < tuc.length; ++i) {
				if (tuc[i].phrase && tuc[i].phrase.language=='pl') {
					txt+='<tr><td class="right">'+cnt+'.&nbsp;</td><td>'+tuc[i].phrase.text+'</td></tr>';
					++cnt;
				}
				/*if (tuc[i].meanings) {
					var m = tuc[i].meanings;
					//txt+='<div class="meanings">';
					for (var j=0; j < m.length; ++j) {
						if (m[j].language=='pl') {
							txt+=cnt+'. '+m[j].text + '<br>';
							++cnt;
						}
					}
					//txt+='</div>';
				}*/
			}
			txt+='</table>';
		}
	}catch(e) {
		console.log(e.stack);
	}
	$('result').innerHTML = txt;
}

var ajax = new Ajax();
function loadFromArgs() {
	translateWord('word_es');
}

function translateWord() {
	var w='';
	var n=0;
	var u=''
	for (var i=0; i < arguments.length; ++i) {
		var v = $(arguments[i]).value;
		if (!v) continue;
		if (n>0) {w+='&';u+=',';}
		v=v.trim().toLowerCase();
		u+=v;
		w+=arguments[i]+'='+v;
		++n;
	}
	if (u) {
		document.title = 'KrzychoTeka - '+u;
		ajax.async('get','<%val("cfg.rooturl")%>api/translate?'+w,onTranslateReady);
	}
	else {
		document.title = 'KrzychoTeka';
	}
	//history.pushState('', document.title, '<%val("cfg.rooturl")%>'+u);
	history.replaceState('', document.title, '<%val("cfg.rooturl")%>'+u);
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

