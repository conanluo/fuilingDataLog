<%@ codepage=65001%>
<!--#include file="clsDbCtrl.asp"-->
<%
dim data:data=Request.QueryString("data")
dim action:action=Request.QueryString("action")
dim datas:datas=split(data&"",",")
Dim db,tableName,condition,valueList,id
dim isSuccess:isSuccess="true"
dim showType:showType=request.QueryString("showType") '汇总的形式:0是所有数据每年按月,1是指定年份每月,2是每年, 默认是2

if ubound(datas)=5 and action = "add" then
	myear=datas(0)
	mmonth=datas(1)
	mday=datas(2)
	mile=datas(3)
	price=datas(4)
	gallon=datas(5)
	total=CSng(price)*CSng(gallon)
	
	newData=mmonth&","&mday&","&mile&","&price&","&gallon
	
	sql=""
	
	
	
	response.Write "add"
	insertData="'"&myear&"/"&mmonth&"/"&mday&"', "&mile&", "&price&", "&gallon
	
	Set db = New DbCtrl   'create object
	db.dbConn = Oc(a)   'create connect
	dim ex : ex = db.AddRecord("tData",_
								Array("ndate:" & myear&"/"&mmonth&"/"&mday , _ 
									  "mile:"&mile,_
									  "price:"&price,_
									  "gallon:"&gallon))
	sql=ex
	if sql=0 then 
		sql="add data error : "&ex
	end if
	Co(db)
	
	
	
	
 	response.write("{""success"":"""& sql &"""}")
elseif action = "json" then
	dim selectYear : selectYear=year(date())
	
	Set db = New DbCtrl   'create object
	db.dbConn = Oc(a)   'create connect
	
	dim checkYear:checkYear=Request.QueryString("year")
	if checkYear="" then checkYear=year(date()) end if' 获取查询年份,如为空则查询今年'
	set rs=db.getRecord("vData","","DYear="&checkYear,"nDate DESC","")
	
	dim rJson : rJson="{""list"":["  '建立json头
	While Not rs.eof 
		'Response.Write ("Name is:" & rs(1) & " Age is:" & rs(2) & "	") 
		rJson=rJson &  _
		"{"& _
			"""id"":" & rs("id")&"," &_
			"""date"":{" &  _
				"""year"":"&rs("DYear")&"," & _	
				"""month"":"&rs("DMonth")&"," & _	
				"""day"":"&rs("DDay") & _	
			"},"&_
			"""mile"":"&rs("mile")&"," & _
			"""price"":"&rs("price")&"," & _
			"""gallon"":"&rs("gallon")&"," & _
			"""total"":"&rs("total") & _
		"}"
		
		rs.movenext() 
		if not rs.eof then rJson=rJson & "," end if '不是最后一个结果,加个逗号
	Wend 	
	rJson=rJson&"]}"  '结束json 尾
	db.C(rs)
	Co(db)
	
	Response.AddHeader "Content-Type", "application/json;charset=UTF-8"
	Response.Charset = "UTF-8"
	response.write(rJson)

elseif action ="update" then '更新数据
	tableName=Request.QueryString("table")
	condition=split(Request.QueryString("condition"),",")
	valueList=split(Request.QueryString("value"),",")
	dim output:output="Update success"
	if tableName="" then tableName="tData" end if
	
	Set db = New DbCtrl   'create object
	db.dbConn = Oc(a)   'create connect
	if Request.QueryString("condition")<>"" and Request.QueryString("value")<>"" then
		dim exUpdate
		exUpdate=db.UpdateRecord(tableName,condition,valueList)
		
		dim re:re=exUpdate
		if re=0 then output="update error:"&re end if
		response.Write db.wUpdateRecord(tableName,condition,valueList)
	else
	
		response.Write "update failed"
	end if
	Co(db)
elseif action = "del" then '删除数据
	id=Request.QueryString("id")
	if id<>"" then
		Set db = New DbCtrl   'create object
		db.dbConn = Oc(a)   'create connect
		dim exDel:exDel=db.DeleteRecord("tData","ID",id)
		
		if exDel=1 then
			response.Write("deleted")
		else
			response.write("delete record fail")
		end if
		Co(db)
		
	else
		response.write("error:缺少id的值 ")
	end if 
elseif action = "showSummary" or action = "updateOilChange" then


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
	elseif action = "updateOilChange" then'更新换油信息修改base表
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
else
	response.write("{""error"":""dataError""}")
end if
%>