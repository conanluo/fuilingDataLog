<%@ codepage=65001%>
<!--#include file="clsDbCtrl.asp"-->
<%
dim action:action=request.QueryString("action") '1,update更新oilChange参数,2,show显示的模式,
dim isSuccess:isSuccess="true"
dim showType:showType=request.QueryString("showType") '汇总的形式:0是所有数据每年按月,1是指定年份每月,2是每年, 默认是2

'初始化数据连接
Dim db : Set db = New DbCtrl   'create object
db.dbConn = Oc(a)   'create connect


'初始化各个日期
dim sumYear:sumYear=request.QueryString("sumYear")
dim oilDate:oilDate=request.QueryString("oilDate")
dim oilMile:oilMile=request.QueryString("oilMile")



'初始化各个日期,如果没有传递值,取今天

if sumYear="" then
	sumYear=year(date())
end if
if oilDate="" then
	oilDate=date()
end if
if oilMile="" then
	oilMile=0
end if
if showType="" then  '默认是1(显示年份)
	showType=2
else
	showType=cint(showType)
end if


if action="" then
	action="show"
elseif action = "update" then'更新换油信息修改base表
	'response.Write("123<br>")
	
	dim baseTable:baseTable="Base"
	dim condition:condition="id=1"
	dim valueList:valueList=Array("oilChangeMile:"&oilMile,"oilChangeDate:"&oilDate)
	
	dim result
	
	result = db.UpdateRecord(baseTable,condition,valueList)
	
	if result = 0 then isSuccess="false" end if '如果失败isSuccess为false
end if



'response.Write(sumYear&"-"""&oilDate&"""-"&oilMile&"-"&showType&"<br>")

'sql的拼接元素
dim sql:sql="SELECT * from Base, "  '
dim table:table=" summaryByYear " '默认查找年份
dim opt:opt="" '条件,按照月份时候需要
dim orderBy:orderBy=" order by dYear desc"

'拼接sql语句
if showType<2 then '月份或全部
	table=" summaryByMonth "
	if showType=1 then '按照指定年份的月份查询
		opt=" where dYear="&sumYear&" "
	end if
	orderBy=orderBy&" , dMonth desc "
end if

sql=sql&table&opt&orderBy

'response.Write(sql&"<br>")



Dim rs : Set rs = db.GetRecordBySQL(sql)

Response.Write ( "{"&"""oilChangeMile"":""" & rs("oilChangeMile") &""","&"""oilChangeDate"":""" & rs("oilChangeDate") &""",")
Response.Write("""action"":{""type"":"""&action&""",""isSuccess"":"&isSuccess&",""showType"":"&showType&"},")
response.Write("""data"":[")
While Not rs.eof   
	Response.Write ( "{" )
	Response.Write("""year"":""" & rs("dyear") &""",")
    if showType<2 then
		Response.Write("""month"":""" & rs("dmonth") &""",")
	end if
	Response.Write("""mile"":""" & rs("mile") &""",")
	Response.Write("""gallon"":""" & rs("gallon") &""",")
	Response.Write("""mpg"":""" & rs("mpg") &""",")
	Response.Write("""total"":""" & rs("total") &""",")
	Response.Write("""mpd"":""" & rs("mpd") &""",")
	Response.Write("""avgPrice"":""" & rs("avgPrice") &"""")
	
	Response.Write("}")

	rs.movenext()   
	if not rs.eof then
		response.Write(",")
	end if
Wend
response.Write("]}")

db.C(rs)   'close rs
Co(db) : CloseConn() 'close object，close    connect
%>
