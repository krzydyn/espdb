<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl">
<head>
  <title><%val("cfg.sitetitle")%></title>
  <meta http-equiv="Content-type" content="text/html;charset=<%val("charset")%>" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="<%val("cfg.rooturl")%>css/style.css" type="text/css"/>
  <link rel="stylesheet" href="<%val("cfg.rooturl")%>css/espdb.css" type="text/css"/>
  <script async src="<%val("cfg.rooturl")%>ajax.js"></script>
  <script async src="<%val("cfg.rooturl")%>js/storage.js"></script>
  <script async src="<%val("cfg.rooturl")%>js/misc.js"></script>
</head>
<body onload="onBodyLoad()" >
<h1><%val("cfg.title")%></h1>
<div class="content">
<div class="pack left">
	<div class="searchbox border-in">
	<form><!-- put inside form tag for auto-submit with Enter key -->
		<span class="label">Enter phrase in</span>
		<!-- https://stackoverflow.com/questions/2965971/how-to-add-a-images-in-select-list -->
		<select id="lang" name="lang">
			<option value="es" <%if(val("req.lang")=="es") echo "selected"%>>español</option>
			<option value="pl" <%if(val("req.lang")=="pl") echo "selected"%>>polski</option>
			<option value="en" <%if(val("req.lang")=="en") echo "selected"%>>english</option>
		</select>
		<br>
		<span id="search-complete">
			<input id="phrase" type="text" size="15" name="phrase" value="<%val("req.phrase")%>" placeholder="Start typing here" autocomplete="off">
			<div id="loading" class="loading"><img width="30px" src="<%val("cfg.rooturl")%>icony/loading_small.gif"></div>
			<div class="autocomplete"></div>
		</span>
		<span class="button"><input type="submit" value="search" onclick="javascript:translateWord();return false;"></span>
	</form>
	</div>
	<div id="source" class="source right"></div>
	<a id="clearlog" href="javascript:clearlog();" style="display:none;">clear log</a>
	<div id="searching" class="abs center nodisp"><img width="20px" src="<%val("cfg.rooturl")%>icony/loading.gif"></div>
	<div id="result" class="result"></div>
	<div id="errors" class="log"></div>
</div>
</div>
<br>

<script type="text/javascript">
var ajax = null;
var body = document.getElementsByTagName('body')[0];
body.addEventListener('load', onBodyLoad, false);

function onBodyLoad() {
	//https://javascript.info/focus-blur
	//delay focusout to allow click event on autocomplete brefore display=none
	$('search-complete').addEventListener('focusout',()=>setTimeout(function() {
		log('focusout');
		$('.autocomplete')[0].style.display='none';
	},500));
	ajax = new Ajax();
	setupPhraseInput();
	translateWord();
}

//history changing event handler
window.onpopstate = function(ev) {
	var state = ev.state;
	$('lang').value = state.lang;
	$('phrase').value = state.phrase;
	translateWord();
}

function setupPhraseInput(ph) {
	var ph=$('phrase');
	ph.addEventListener('focus',()=>updateAutocomplete());
	ph.addEventListener('input',()=>updateAutocomplete());
	ph.onkeydown = function(ev) {
		ev = ev || window.event;
		var key = ev.keyCode || ev.witch;
		//log('key: '+key);
		switch(key) {
			case 38: // arrow-up
			case 40: // arrow-dn
				return false;
			case 27: // esc
				$('.autocomplete')[0].style.display='none'
				return false;
		}
	}
}

function translateResponse(obj) {
	var dbsrc = '';
	if (obj.source) dbsrc='source: '+obj.source;
	if (obj.tr === undefined)
		throw new Error(obj.error);

	var tr = obj.tr;
	var txt='';
	if (tr.length==0) {
		txt+='Phrase not found';
	}
	else {
		var dst = obj.dest;
		var prw = tr.length > 1 || tr[0].phrase!=$('phrase').value;
		txt+='<table>';
		for (var j=0; j < tr.length; ++j) {
			var cnt=1;
			if (prw) {
				var href = 'javascript:translateWord(\''+obj.from+'\',\''+tr[j].phrase+'\')';
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
						txt+=' &nbsp; <a href="'+href+'"><img height="21px" src="<%val("cfg.rooturl")%>icony/speaker6.png" align="top"></a>'
					}
					txt+='</td></tr>';
					++cnt;
				}
			}
		}
		txt+='</table>';
	}
	$('source').innerHTML = dbsrc;
	$('result').innerHTML = txt;
}
var onTranslateReady = function(rc,tx) {
	$('searching').style.display='none';
	if (rc != 200) {
		log('Transalte rc='+rc);
		$('source').innerHTML = tx+' '+rc;;
		$('result').innerHTML = '';
		return ;
	}
	try{
		var obj = JSON.parse(tx);
		//log(obj);
		translateResponse(obj);
		obj.source='esp-storage';
		if (obj.tr.length > 0)
			saveLocal(obj.from+'/'+$('phrase').value,obj);
	}catch(e) {
		log(e.stack);
		if (e instanceof SyntaxError) log('JSON='+tx);
		txt = e.toString();
		$('source').innerHTML = 'error';
		$('errors').innerHTML = txt;
	}
}
function setPhrase(s) {
	log('setPhrase '+s);
	$('phrase').value=s;
	$('.autocomplete')[0].style.display='none';
	translateWord();
}
var onAutoCompleteReady = function(rc,tx) {
	if ($('.autocomplete').length==0) {
		return ;
	}
	if (rc != 200) {
		log('ready rc='+rc+':'+tx);
		return ;
	}
	var txt = '<ul>';
	var errtxt = '';
	try{
		var r = JSON.parse(tx);
		log('autocompl'+tx);
		if (r.ac) {
			var ac = r.ac;
			for (var j=0; j < ac.length; ++j) {
				txt += '<li onclick="setPhrase(this.innerHTML);">'+ac[j].text+'</li>';
			}
			if (ac.length==0) txt='not found';
			else txt += '</ul>';
		}
		if (r.error) errtxt = r.error;
	}catch(e) {
		log(e.stack);
		if (e instanceof SyntaxError) log('JSON='+tx);
		errtxt='SyntaxError';
	}
	var ac = $('.autocomplete');
	ac[0].style.display='block';
	ac[0].style.width=$('phrase').getBoundingClientRect().width+'px';
	ac[0].innerHTML = txt;
	var err = $('errors');
	if (err) {
		if (errtxt) err.innerHTML = errtxt;
		else err.innerHTML='';
	}
}


function updateAutocomplete() {
	var lang=$('lang').value.trim().toLowerCase();
	var phrase=$('phrase').value.trim().toLowerCase();
	if (phrase.length==0) {
		$('.autocomplete')[0].style.display='none';
		return ;
	}
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
	if (phrase.isEmpty()) return ;
	var state = {lang:lang, phrase:phrase};
	var u = null;
	var obj = readLocal(lang+'/'+phrase);
	if (obj) {
		document.title = 'KrzychoTeka - '+phrase;
		obj.source = 'esp-storage';
		translateResponse(obj);
		var w = encodeURIComponent(phrase); //escape %,&,=
		u='<%val("cfg.rooturl")%>'+lang+'/'+w;
	}
	else if (phrase) {
		$('searching').style.display='block';
		document.title = 'KrzychoTeka - '+phrase;
		var w = encodeURIComponent(phrase); //escape %,&,=
		u='lang='+lang+'&phrase='+w;
		ajax.async('get','<%val("cfg.rooturl")%>api/translate?'+u,onTranslateReady);
		u='<%val("cfg.rooturl")%>'+lang+'/'+w;
	}
	else {
		document.title = 'KrzychoTeka';
		translateResponse(JSON.parse('{"tr":[]}'));
		u='<%val("cfg.rooturl")%>';
	}
	//title arg is ignored
	if (arguments.length>0) history.pushState(state, '', u);
	else history.replaceState(state, '', u);
}
</script>
</body></html>
