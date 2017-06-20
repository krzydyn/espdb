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
	<span class="label">Enter in</span>
	<select id="lang" name="lang">
		<option value="es"><img src="<%val("cfg.rooturl")%>icony/flags-lg/es-lgflag.gif">español</option>
		<option value="pl"><img src="<%val("cfg.rooturl")%>icony/flags-lg/pl-lgflag.gif">polski</option>
		<option value="en"><img src="<%val("cfg.rooturl")%>icony/flags-lg/en-lgflag.gif">english</option>
	</select>
	<br>
	<span class="es"><input id="phrase" type="text" size="20" name="word" value="<%val("req.word")%>"></span>
	<span class="button"><input type="submit" value="search" onclick="javascript:translateWord();return false;"></span>
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
		var dst = t.dest;
		var tuc = t['tuc'];
		if (tuc.length==0) txt+='Phrase not found';
		else {
			var cnt=1;
			txt+='<table>';
			for (var i=0; i < tuc.length; ++i) {
				if (tuc[i].phrase && tuc[i].phrase.language==dst) {
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
	translateWord();
}

function translateWord() {
	var lang=$('lang').value;
	var w=$('phrase').value.trim().toLowerCase();
	if (w) {
		document.title = 'KrzychoTeka - '+w;
		var u='word='+w+'&lang='+lang;
		ajax.async('get','<%val("cfg.rooturl")%>api/translate?'+u,onTranslateReady);
	}
	else {
		document.title = 'KrzychoTeka';
	}
	//history.pushState('', document.title, '<%val("cfg.rooturl")%>'+w);
	history.replaceState('', document.title, '<%val("cfg.rooturl")%>'+w);
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

