<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl">
<head>
  <meta http-equiv="Content-type" content="text/html;charset=<%val("charset")%>" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>KrzychoTeka</title>
  <link rel="stylesheet" href="<%val("cfg.rooturl")%>css/style.css" type="text/css"/>
  <link rel="stylesheet" href="<%val("cfg.rooturl")%>css/espdb.css" type="text/css"/>
  <script src="<%val("cfg.rooturl")%>ajax.js"></script>
  <script src="<%val("cfg.rooturl")%>js/storage.js"></script>
  <script src="<%val("cfg.rooturl")%>js/misc.js"></script>
</head>
<body onload="translateWord()">
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
		<span class="es">
			<input id="phrase" type="text" size="15" name="phrase" value="<%val("req.phrase")%>" placeholder="Start typing here" autocomplete="off">
			<div id="loading_small" class="autocomplete-loading"><img src="<%val("cfg.rooturl")%>../icony/loading_small.gif"></div>
			<div class="autocomplete"></div>
		</span>
		<span class="button"><input type="submit" value="search" onclick="javascript:translateWord();return false;"></span>
	</form>
	</div>
	<div id="source" class="source right"></div>
	<a id="clearlog" href="javascript:clearlog();" style="display:none;">clear log</a>
	<div id="loading" class="abs center nodisp"><img src="<%val("cfg.rooturl")%>../icony/loading.gif"></div>
	<div id="result" class="result"></div>
	<div id="logarea" class="log"></div>
</div>
</div>
<br>

<script type="text/javascript">
window.onpopstate = function(ev) {
	console.log(ev);
	var state = ev.state;
	$('lang').value = state.lang;
	$('phrase').value = state.phrase;
	translateWord();
}

var ph=$('phrase');
/*ph.onblur = function() {
	console.log('onblur');
	var ac = $('.autocomplete');
	if (ac.length==0) return ;
	ac[0].style.display='none';
}
ph.onkeypress = function() {
	console.log('onkeypress');
}
ph.onkeyup = function() {
	console.log('onkeyup');
}
ph.onkeydown = function() {
	console.log('onkeydown');
}*/
ph.onfocus = function() {
	console.log('onfocus');
	updateAutocomplete();
}
ph.oninput = function() {
	console.log('oninput');
	updateAutocomplete();
}

var onTranslateReady = function(rc,tx) {
	if (rc != 200 && rc != 0) {
		console.log('ready rc='+rc);
		return ;
	}
	var txt='';
	var dbsrc='';
	try{
		var r = JSON.parse(tx);
		//console.log(r);
		if (rc == 0) r.source='esp-storage';
		dbsrc = 'source: '+r.source;
		var tr = r.tr;
		if (tr.length==0) {
			if (r.dest) txt+='Phrase not found';
		}
		else {
			var dst = r.dest;
			var prw = tr.length > 1 || tr[0].phrase!=$('phrase').value;
			txt+='<table>';
			for (var j=0; j < tr.length; ++j) {
				var cnt=1;
				if (prw) {
					var href = 'javascript:translateWord(\''+r.from+'\',\''+tr[j].phrase+'\')';
					txt+='<tr><th colspan="2"><a href="'+href+'">'+tr[j].phrase+'</a></th></tr>';
				}
				var data = tr[j].data;
				var canspeak = findSpeech(dst);
				for (var i=0; i < data.length; ++i) {
					if (data[i].lang==dst) {
						var href = 'javascript:translateWord(\''+data[i].lang+'\',\''+data[i].text+'\')';
						txt+='<tr><td class="right">'+cnt+'.&nbsp;</td><td>';
						txt+='<a href="'+href+'">'+data[i].text+'</a>'
						if (canspeak) {
							href = 'javascript:sayit(\''+data[i].lang+'\',\''+data[i].text+'\')';
							txt+=' &nbsp; <a href="'+href+'"><img height="21px" src="../icony/speaker6.png" align="top"></a>'
						}
						txt+='</td></tr>';
						++cnt;
					}
				}
			}
			txt+='</table>';
		}
		if (rc==200) {
			r.source='esp-storage';
			saveLocal(r.from+'/'+$('phrase').value,JSON.stringify(r));
		}
	}catch(e) {
		console.log(e.stack);
		if (e instanceof SyntaxError) console.log('JSON='+tx);
	}
	$('source').innerHTML = dbsrc;
	$('result').innerHTML = txt;
	$('loading').style.display='none';
}
function setPhrase(s) {
	$('phrase').value=s;
	$('.autocomplete')[0].style.display='none';
}
var onAutoCompleteReady = function(rc,tx) {
	$('loading_small').style.display='none';
	if ($('.autocomplete').length==0) return ;
	if (rc != 200) {
		console.log('ready rc='+rc+':'+tx);
		return ;
	}
	var txt = '<ul>';
	try{
		var r = JSON.parse(tx);
		//console.log(r);
		var ac = r.ac;
		for (var j=0; j < ac.length; ++j) {
			txt += '<li onclick="setPhrase(this.innerHTML);">'+ac[j].text+'</li>';
		}
		if (ac.length==0) txt='not found';
		else txt += '</ul>';
	}catch(e) {
		console.log(e.stack);
		if (e instanceof SyntaxError) console.log('JSON='+tx);
		txt='SyntaxError';
	}
	var ac = $('.autocomplete');
	ac[0].style.display='block';
	ac[0].style.width=$('phrase').getBoundingClientRect().width+'px';
	ac[0].innerHTML = txt;
}

var ajax = new Ajax();

function updateAutocomplete() {
	var lang=$('lang').value.trim().toLowerCase();
	var phrase=$('phrase').value.trim().toLowerCase();
	if (phrase.length==0) {
		$('.autocomplete')[0].style.display='none';
		return ;
	}
	$('loading_small').style.display='inline-block';
	var w = encodeURIComponent(phrase); //escape %,&,=,sp
	var u='lang='+lang+'&phrase='+w;
	ajax.async('get','<%val("cfg.rooturl")%>api/autocomplete?'+u,onAutoCompleteReady);
}
function translateWord() {
	$('.autocomplete')[0].style.display='none';
	var lang=$('lang').value.trim().toLowerCase();
	var phrase=$('phrase').value.trim().toLowerCase();
	if (arguments.length>0) {
		lang = arguments[0];
		$('lang').value = lang;
	}
	if (arguments.length>1) {
		phrase = arguments[1];
		$('phrase').value = phrase;
	}
	var state = {lang:lang, phrase:phrase};
	var u = null;
	var tx = readLocal(lang+'/'+phrase);
	if (tx) {
		document.title = 'KrzychoTeka - '+phrase;
		onTranslateReady(0,tx);
		var w = encodeURIComponent(phrase); //escape %,&,=
		u='<%val("cfg.rooturl")%>'+lang+'/'+w;
	}
	else if (phrase) {
		$('loading').style.display='block';
		document.title = 'KrzychoTeka - '+phrase;
		var w = encodeURIComponent(phrase); //escape %,&,=
		u='lang='+lang+'&phrase='+w;
		ajax.async('get','<%val("cfg.rooturl")%>api/translate?'+u,onTranslateReady);
		u='<%val("cfg.rooturl")%>'+lang+'/'+w;
	}
	else {
		document.title = 'KrzychoTeka';
		onTranslateReady(0,'{"source":"", "tr":[]}');
		u='<%val("cfg.rooturl")%>';
	}
	//title arg is ignored
	if (arguments.length>0) history.pushState(state, '', u);
	else history.replaceState(state, '', u);
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
