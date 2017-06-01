<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl">
<head>
  <meta http-equiv="Content-type" content="text/html;charset=<%val("charset")%>" />
  <title>KrzychoTeka</title>
  <link rel="stylesheet" href="style.css" type="text/css"/>  
  <script src="/kysoft/ajax.js"></script>
</head>
<body onload="loadParts()">
<h1>KrzychoTeka</h1>
<div class="loading" style="position:absolute;left:50%;width:50%;"><!--img src="../icony/loading2.gif"--></div>
<div class="content">
<%if(valExist("content")){%>
<div class="<%val2class("content")%>">
<%include(val("content").".tpl")%>
</div>
<%}%>
</div>
<br>
<t:list property="debug" value="li" enclose="div" class="debug"><li><%$li%></li></t:list>
<t:list property="error" value="li" enclose="div" class="error"><li><%$li%></li></t:list>

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
	}catch(e) { console.log('cant parse: '+tx); }
}

function loadParts() {
	ajax.async('get','part.php',onPartReady);
}
function saveOfflineExample() {
	localStorage.colorSetting = '#a4509b';
	localStorage['colorSetting'] = '#a4509b';
	localStorage.setItem('colorSetting', '#a4509b');
}
//setTimeout(loadParts,1);
</script>
</body></html>

