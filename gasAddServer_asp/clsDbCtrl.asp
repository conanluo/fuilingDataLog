<%
'==========================================================================
'文件名称：clsDbCtrl.asp
'功　　能：数据库操作类

'Dim a : a = CreatConn(0, "master", "localhost", "sa", "")    'MSSQL数据库
Dim a : a = CreatConn(1, "db\######.mdb", "", "", "")    'Access数据库
'Dim a : a = CreatConn(1, "E:\MyWeb\Data\%TestDB%.mdb", "", "", "mdbpassword")
Dim Conn
'OpenConn()    '在加载时就建立的默认连接对象Conn,默认使用数据库a
Sub OpenConn : Set Conn = Oc(a) : End Sub
Sub CloseConn : Co(Conn) : End Sub

Function Oc(ByVal Connstr)
    On Error Resume Next
    Dim objConn
    Set objConn = Server.CreateObject("ADODB.Connection")
    objConn.Open Connstr
    If Err.number <> 0 Then
        Response.Write("<div id=""DBError""> 数据库服务器端连接错误，请与网站管理员联系。 "&Err&" </div>")
        Response.Write("错误信息： " & Err.Description)
        objConn.Close
        Set objConn = Nothing
        Response.End
    End If
    Set Oc = objConn
End Function

Sub Co(obj)
    On Error Resume Next
    Set obj = Nothing
End Sub

Function CreatConn(ByVal dbType, ByVal strDB, ByVal strServer, ByVal strUid, ByVal strPwd)
    Dim TempStr
    Select Case dbType
        Case "0","MSSQL"
            TempStr = "driver={sql server};server="&strServer&";uid="&strUid&";pwd="&strPwd&";database="&strDB
        Case "1","ACCESS"
            Dim tDb : If Instr(strDB,":")>0 Then : tDb = strDB : Else : tDb = Server.MapPath(strDB) : End If
            TempStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source="&tDb&";Jet OLEDB:Database Password="&strPwd&";"
            'TempStr = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source="&tDb&";Jet OLEDB:Database Password="&strPwd&";"
        Case "3","MYSQL"
            TempStr = "Driver={mySQL};Server="&strServer&";Port=3306;Option=131072;Stmt=; Database="&strDB&";Uid="&strUid&";Pwd="&strPwd&";"
        Case "4","ORACLE"
            TempStr = "Driver={Microsoft ODBC for Oracle};Server="&strServer&";Uid="&strUid&";Pwd="&strPwd&";"
    End Select
    CreatConn = TempStr
End Function


Class dbCtrl
    Private debug
    Private idbConn
    Private idbErr
    
    Private Sub Class_Initialize()
        debug = false                    '调试模式是否开启
        idbErr = "error:"
        If IsObject(Conn) Then
            Set idbConn = Conn
        End If
    End Sub
    
    Private Sub Class_Terminate()
        Set idbConn = Nothing
        If debug And idbErr<>"error:" Then Response.Write(idbErr)
    End Sub
    
    Public Property Let dbConn(pdbConn)
        If IsObject(pdbConn) Then
            Set idbConn = pdbConn
        Else
            Set idbConn = Conn
        End If
    End Property
    
    Public Property Get dbErr()
        dbErr = idbErr
    End Property
    
    Public Property Get Version
        Version = "ASP Database Ctrl V1.0 By ColdStone"
    End Property

    Public Function AutoID(ByVal TableName)
        On Error Resume Next
        Dim m_No,Sql, m_FirTempNo
        Set m_No=Server.CreateObject("adodb.recordset")
        Sql="SELECT * FROM ["&TableName&"]"
        m_No.Open Sql,idbConn,3,3
        If m_No.EOF Then
            AutoID=1
        Else
            Do While Not m_No.EOF
                m_FirTempNo=m_No.Fields(0).Value 
                m_No.MoveNext
                  If m_No.EOF Then 
                        AutoID=m_FirTempNo+1
                  End If
            Loop
        End If
        If Err.number <> 0 Then
            idbErr = idbErr & " 无效的查询条件！ <br />"
            If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
            Response.End()
            Exit Function
        End If
        m_No.close
        Set m_No = Nothing
    End Function

    Public Function GetRecord(ByVal TableName,ByVal FieldsList,ByVal Condition,ByVal OrderField,ByVal ShowN)
		if ShowN ="" then
			ShowN=0
		end if
        On Error Resume Next
        Dim rstRecordList
        Set rstRecordList=Server.CreateObject("adodb.recordset")
        With rstRecordList
            .ActiveConnection = idbConn
            .CursorType = 3
            .LockType = 3
            .Source = wGetRecord(TableName,FieldsList,Condition,OrderField,ShowN)
            .Open 
            If Err.number <> 0 Then
                idbErr = idbErr & " 无效的查询条件！ <br />"
                If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
                .Close
                Set rstRecordList = Nothing
                Response.End()
                Exit Function
            End If    
        End With
        Set GetRecord=rstRecordList
    End Function
    
    Public Function wGetRecord(ByVal TableName,ByVal FieldsList,ByVal Condition,ByVal OrderField,ByVal ShowN)
        Dim strSelect
        strSelect="select "
        If ShowN > 0 Then
            strSelect = strSelect & " top " & ShowN & " "
        End If
        If FieldsList<>"" Then
            strSelect = strSelect & FieldsList
        Else
            strSelect = strSelect & " * "
        End If
        strSelect = strSelect & " from [" & TableName & "]"
        If Condition <> "" Then
            strSelect = strSelect & " where " & ValueToSql(TableName,Condition,1)
        End If
        If OrderField <> "" Then
            strSelect = strSelect & " order by " & OrderField
        End If
        wGetRecord = strSelect
    End Function

    Public Function GetRecordBySQL(ByVal strSelect)
        On Error Resume Next
        Dim rstRecordList
        Set rstRecordList=Server.CreateObject("adodb.recordset")
            With rstRecordList
            .ActiveConnection =idbConn
            .CursorType = 3
            .LockType = 3
            .Source = strSelect
            .Open 
            If Err.number <> 0 Then
                idbErr = idbErr & " 无效的查询条件！ <br />"
                If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
                .Close
                Set rstRecordList = Nothing
                Response.End()
                Exit Function
            End If    
        End With
        Set GetRecordBySQL = rstRecordList
    End Function

    Public Function GetRecordDetail(ByVal TableName,ByVal Condition)
        On Error Resume Next
        Dim rstRecordDetail, strSelect
        Set rstRecordDetail=Server.CreateObject("adodb.recordset")
        With rstRecordDetail
            .ActiveConnection =idbConn
            strSelect = "select * from [" & TableName & "] where " & ValueToSql(TableName,Condition,1)
            .CursorType = 3
            .LockType = 3
            .Source = strSelect
            .Open 
            If Err.number <> 0 Then
                idbErr = idbErr & " 无效的查询条件！ <br />"
                If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
                .Close
                Set rstRecordDetail = Nothing
                Response.End()
                Exit Function
            End If
        End With
        Set GetRecordDetail=rstRecordDetail
    End Function

    Public Function AddRecord(ByVal TableName, ByVal ValueList)
        On Error Resume Next
        DoExecute(wAddRecord(TableName,ValueList))
        If Err.number <> 0 Then
            idbErr = idbErr & " 写入数据库出错！ <br />"
            If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
            'DoExecute "ROLLBACK TRAN Tran_Insert"    '如果存在添加事务（事务滚回）
            AddRecord = 0
            Exit Function
        End If
        AddRecord = AutoID(TableName)-1
    End Function
    
    Public Function wAddRecord(ByVal TableName, ByVal ValueList)
        Dim TempSQL, TempFiled, TempValue
        TempFiled = ValueToSql(TableName,ValueList,2)
        TempValue = ValueToSql(TableName,ValueList,3)
        TempSQL = "Insert Into [" & TableName & "] (" & TempFiled & ") Values (" & TempValue & ")"
        wAddRecord = TempSQL
    End Function

    Public Function UpdateRecord(ByVal TableName,ByVal Condition,ByVal ValueList)
        On Error Resume Next
		'response.write(wUpdateRecord(TableName,Condition,ValueList))
        DoExecute(wUpdateRecord(TableName,Condition,ValueList))
        If Err.number <> 0 Then
            idbErr = idbErr & " 更新数据库出错！ <br />"
            If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
            'DoExecute "ROLLBACK TRAN Tran_Update"    '如果存在添加事务（事务滚回）
            UpdateRecord = 0
            Exit Function
        End If
        UpdateRecord = 1
    End Function

    Public Function wUpdateRecord(ByVal TableName,ByVal Condition,ByVal ValueList)
        Dim TmpSQL
        TmpSQL = "Update ["&TableName&"] Set "
        TmpSQL = TmpSQL & ValueToSql(TableName,ValueList,0)
        TmpSQL = TmpSQL & " Where " & ValueToSql(TableName,Condition,1)
        wUpdateRecord = TmpSQL
    End Function

    Public Function DeleteRecord(ByVal TableName,ByVal IDFieldName,ByVal IDValues)
        On Error Resume Next
        Dim Sql
        Sql = "Delete From ["&TableName&"] Where ["&IDFieldName&"] In ("
        If IsArray(IDValues) Then
            Sql = Sql & "Select ["&IDFieldName&"] From ["&TableName&"] Where " & ValueToSql(TableName,IDValues,1)
        Else
            Sql = Sql & IDValues
        End If
        Sql = Sql & ")"
        DoExecute(Sql)
        If Err.number <> 0 Then
            idbErr = idbErr & " 删除数据出错！ <br />"
            If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
            'DoExecute "ROLLBACK TRAN Tran_Delete"    '如果存在添加事务（事务滚回）
            DeleteRecord = 0 
            Exit Function
        End If
        DeleteRecord = 1
    End Function
    
    Public Function wDeleteRecord(ByVal TableName,ByVal IDFieldName,ByVal IDValues)
        On Error Resume Next
        Dim Sql
        Sql = "Delete From ["&TableName&"] Where ["&IDFieldName&"] In ("
        If IsArray(IDValues) Then
            Sql = Sql & "Select ["&IDFieldName&"] From ["&TableName&"] Where " & ValueToSql(TableName,IDValues,1)
        Else
            Sql = Sql & IDValues
        End If
        Sql = Sql & ")"
        wDeleteRecord = Sql
    End Function 

    Public Function ReadTable(ByVal TableName,ByVal Condition,ByVal GetFieldNames)
        On Error Resume Next
        Dim rstGetValue,Sql,BaseCondition,arrTemp,arrStr,TempStr,i
        TempStr = "" : arrStr = ""
        '给出SQL条件语句
        BaseCondition = ValueToSql(TableName,Condition,1)
        '读取数据
        Set rstGetValue = Server.CreateObject("ADODB.Recordset")
        Sql = "Select "&GetFieldNames&" From ["&TableName&"] Where "&BaseCondition
        rstGetValue.Open Sql,idbConn,3,3
        If rstGetValue.RecordCount > 0 Then
            If Instr(GetFieldNames,",")>0 Then
                arrTemp = Split(GetFieldNames,",")
                For i = 0 To Ubound(arrTemp)
                    If i<>0 Then arrStr = arrStr &Chr(112)&Chr(112)&Chr(113)
                    arrStr = arrStr & rstGetValue.Fields(i).Value
                Next
                TempStr = Split(arrStr,Chr(112)&Chr(112)&Chr(113))
            Else
                TempStr = rstGetValue.Fields(0).Value
            End If
        End If
        If Err.number <> 0 Then
            idbErr = idbErr & " 获取数据出错！ <br />"
            If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
            rstGetValue.close()
            Set rstGetValue = Nothing
            Exit Function
        End If
        rstGetValue.close()
        Set rstGetValue = Nothing
        ReadTable = TempStr
    End Function

    Public Function C(ByVal ObjRs)
        ObjRs.close()
        Set ObjRs = Nothing
    End Function
    
    Private Function ValueToSql(ByVal TableName, ByVal ValueList, ByVal sType)
        Dim StrTemp
        StrTemp = ValueList
        If IsArray(ValueList) Then
            StrTemp = ""
            Dim rsTemp, CurrentField, CurrentValue, i
            Set rsTemp = Server.CreateObject("adodb.recordset")
            With rsTemp
                .ActiveConnection = idbConn
                .CursorType = 3
                .LockType = 3
                .Source ="select * from [" & TableName & "] where 1 = -1"
                .Open
                For i = 0 to Ubound(ValueList)
                    CurrentField = Left(ValueList(i),Instr(ValueList(i),":")-1)
                    CurrentValue = Mid(ValueList(i),Instr(ValueList(i),":")+1)
                    If i <> 0 Then
                        Select Case sType
                            Case 1
                                StrTemp = StrTemp & " And "
                            Case Else
                                StrTemp = StrTemp & ", "
                        End Select
                    End If
                    If sType = 2 Then
                        StrTemp = StrTemp & "[" & CurrentField & "]"
                    Else
                        Select Case .Fields(CurrentField).Type
							case 7
								If sType = 3 Then
									StrTemp = StrTemp & "#"&CurrentValue&"#"
								Else
									StrTemp = StrTemp & "[" & CurrentField & "] = #"&CurrentValue&"#"
								End If
                            Case 133,134,135,8,129,200,201,202,203
                                If sType = 3 Then
									StrTemp = StrTemp & "'"&CurrentValue&"'"
                                Else
									StrTemp = StrTemp & "[" & CurrentField & "] = '"&CurrentValue&"'"
								End If
                            Case 11
							'response.Write(.Fields(CurrentField).Type)
                                If UCase(cstr(Trim(CurrentValue)))="TRUE" Then
                                    If sType = 3 Then
                                        StrTemp = StrTemp & "1"
                                    Else
                                        StrTemp = StrTemp & "[" & CurrentField & "] = 1"
                                    End If
                                Else 
                                    If sType = 3 Then
                                        StrTemp = StrTemp & "0"
                                    Else
                                        StrTemp = StrTemp & "[" & CurrentField & "] = 0"
                                    End If
                                End If
                            Case Else
							'response.Write(.Fields(CurrentField).Type)
                                If sType = 3 Then
                                    StrTemp = StrTemp & CurrentValue
                                Else
                                    StrTemp = StrTemp & "[" & CurrentField & "] = " & CurrentValue
                                End If
                        End Select
                    End If
                Next
            End With
            If Err.number <> 0 Then
                idbErr = idbErr & " 生成SQL语句出错！ <br />"
                If debug Then idbErr = idbErr & " 错误信息： "& Err.Description
                rsTemp.close()
                Set rsTemp = Nothing
                Exit Function
            End If
            rsTemp.Close()
            Set rsTemp = Nothing
        End If
        ValueToSql = StrTemp
    End Function

    Private Function DoExecute(ByVal sql)
        Dim ExecuteCmd
        Set ExecuteCmd = Server.CreateObject("ADODB.Command")
        With ExecuteCmd
            .ActiveConnection = idbConn
            .CommandText = sql
            .Execute
        End With
        Set ExecuteCmd = Nothing
    End Function
End Class
%>