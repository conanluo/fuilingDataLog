<%
'
'set conn=Server.CREATEOBJECT("ADODB.CONNECTION") 
'DBPath = Server.MapPath("../db/######.mdb") 
'conn.Open "driver={Microsoft Access Driver (*.mdb)};dbq=" & DBPath 

set conn=Server.CreateObject("ADODB.Connection") 
DBPath = Server.MapPath("db/######.mdb")
conn.Open "provider=microsoft.jet.oledb.4.0;data source="&DBPath
%>