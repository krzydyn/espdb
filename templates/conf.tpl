<table class="multcol"><tr><td>
Left<br>
Panel
</td><td>
&nbsp;
</td><td>
<form action="javascript:aj()" method="get">
SQL:<br>
<table><tr>
<td><textarea name="sql" cols="50" rows="2">
<%val("req.sql")%>
</textarea></td>
<td>&nbsp;<input type="submit" value="send"/></td>
</tr></table>
</form>

<t:list property="sqlresult" id="i" value="row" enclose="table">
<tr><td><%$rowcnt+1%></td>
<%if(is_array($row))for($n=0,reset($row);list($f,$v)=each($row);++$n){%>
<td><%$v%></td>
<%}else{%>
<td><%$row%></td>
<%}%>
</tr>
</t:list>

<style>
td.tm{width:120px;}
</style>

<%if(val("rec")){%>
<table class="db db<%val("rec")->tabname()%>">
<tr class="head">
<th class="ord">#</th>
<% $row=val("rec");while(list($f,$v)=each($row))if($f!="id"&&substr($f,0,1)!="_"){%>
<th class="<%$f%>"><%val("txt.db.".$row->tabname().".".$f,$f)%></th>
<%}%>
</tr>
<t:list property="result" value="row">
<tr class="row row<%$rowcnt&1%>" onClick="if(!containsEvent($(this).down(),event))window.location='?act=edit<%$row->getClass()%>&amp;id=<%$row->getID()%>';">
<td class="ord numeric"><%$rowcnt+1%></td>
<%for($n=0,reset($row);list($f,$v)=each($row);++$n)if($f!="id"&&substr($f,0,1)!="_"){%>
<%if($f=="role")$v=val("txt.rolename.".$v)%>
<td class="<%$f%>"><%echo is_object($v)?$v->toString():$v%></td>
<%}%>
</tr>
</t:list>
</table>
<%}%>
</td></tr></table>
