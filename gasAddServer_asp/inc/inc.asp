
<%
var conn=Server.CreateObject("ADODB.Connection")
DBPath=Server.MapPath("db/######.mdb")
conn.Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source="+DBPath)

%>

<%
function addDB(obj,tableName){
	var sql="insert into "+tableName+"(";
	var keys=""
	var vals=""
	var k=0;
	for(var key in obj){
		keys+=(key+",");
		vals+=("'"+obj[key]+"',");
	}
	sql=sql+keys.substring(0,keys.length-1)+") values("+vals.substring(0,vals.length-1)+")"
	conn.Execute(sql);
	//return sql
}

%>