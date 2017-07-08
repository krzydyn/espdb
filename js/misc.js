//comaptibility workarrounds
if (!Date.now) {
	Date.now = function() { return new Date().getTime(); }
}

function log(str) {
	var l = $('logarea');
	if (l) {
		l.innerHTML += str+'\n';
		$('clearlog').style.display='block';
	}
}
function clearlog(str='') {
	var l = $('logarea');
	if (l) l.innerHTML = str+'\n';
}

function isEmpty(str) { return !str; }
function isBlank(str) { return !str || /^\s*$/.test(str); }

String.prototype.isEmpty = function() { return this.length === 0; }
String.prototype.isBlank = function() { return /^\s*$/.test(this); }
//already supported
//String.prototype.startsWith = function(s) { return this.substring(0,s.length)==s; }

//TODO extract from id mutiple class names
function $(id) {
	if (id.startsWith(".")) return Array.prototype.slice.call(document.getElementsByClassName(id.substring(1)));
	return document.getElementById(id);
}

var synth = window.speechSynthesis;
synth.onvoiceschanged = updateVoiceList;
var voices = [];
function updateVoiceList() {
	voices = synth.getVoices();
}
function findSpeech(lang) {
	if (lang == 'en') lang='en.US';
	else if (lang == 'pl') lang='pl.PL';
	else {
		//lang='es-US';
		lang='es.ES';
	}
	var re = new RegExp('^'+lang+'$');
	for(var i = 0; i < voices.length ; i++) {
		//log('voice lang='+voices[i].lang);
		if (re.test(voices[i].lang)) {
			var speech = new SpeechSynthesisUtterance('');
			speech.voiceURL = voices[i].voiceURL;
			speech.lang = voices[i].lang;
			return speech;
		}
	}
	return false;
}
function sayit(lang, txt) {
	var speech = findSpeech(lang);
	if (speech) {
		speech.text = txt;
		speech.rate = 0.8;
		synth.speak(speech);
	}
}

function _toString(o,i,t){
    var str='';
    var ind='';
    if (o==null) return 'NULL';
    var tp=typeof o;
    if (i==0) str+=tp+':';
    for (var x=0; x<i; x++) ind+='  ';
    if (tp=='string') str+=o;
    else
    for (var p in o){
        try{
        var v=o[p];
        tp=typeof v;
        if (tp == 'function'){
            //if (t=='f') v=v.toString().gsub('\n','');
            continue;
        }else if (v==null) v='NULL';
        else if (i<1){
            if (tp=='object' && t=='f' && p.indexOf('parent')<0) v='{\n'+_toString(v,i+1,t)+ind+'}';
        }
        str+=ind+tp+':'+p+'='+v+'\n';
        }catch(e){str+='(*Exception* '+o+'.'+p+')'+e+'\n';}
    }
    return str;
}
function mytoString(o){
    var t='';
    if (arguments.length>1) t=arguments[1];
    return _toString(o,0,t);
}

