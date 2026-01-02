<%
Response.CodePage = 65001
Response.Charset  = "utf-8"
%>
<!--#include file="../includes/config.asp" -->
<!--#include file="_auth.asp" -->
<!--#include file="../includes/connect.asp" -->
<%
If UCase(Request.ServerVariables("REQUEST_METHOD")) <> "POST" Then
  conn.Close : Set conn = Nothing
  Response.Redirect ROOT & "/admin/tables.asp"
  Response.End
End If

Dim id, code, name, cap, areaId, active, notes
id = 0
If IsNumeric(Request.Form("TableId") & "") Then id = CLng(Request.Form("TableId"))

code = Trim(Request.Form("TableCode") & "")
If code = "" Then
  conn.Close : Set conn = Nothing
  Response.Redirect ROOT & "/admin/tables.asp?msg=" & Server.URLEncode("Thiếu TableCode (mã bàn)")
  Response.End
End If

name = Trim(Request.Form("TableName") & "")
If name = "" Then name = Null ' vì TableName cho phép NULL

cap = 0
If IsNumeric(Request.Form("Capacity") & "") Then cap = CLng(Request.Form("Capacity"))
If cap <= 0 Then
  conn.Close : Set conn = Nothing
  Response.Redirect ROOT & "/admin/tables.asp?msg=" & Server.URLEncode("Capacity không hợp lệ")
  Response.End
End If

' AreaId nullable -> cho phép rỗng, nếu muốn bắt buộc thì check <=0 như trước
areaId = Null
If IsNumeric(Request.Form("AreaId") & "") Then
  If CLng(Request.Form("AreaId")) > 0 Then areaId = CLng(Request.Form("AreaId"))
End If

active = 1
If Trim(Request.Form("IsActive") & "") = "0" Then active = 0

notes = Trim(Request.Form("Notes") & "")
If notes = "" Then notes = Null

Dim cmd, sql
Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandType = 1

If id > 0 Then
  sql = "UPDATE dbo.DiningTables " & _
        "SET TableCode=?, TableName=?, Capacity=?, AreaId=?, IsActive=?, Notes=? " & _
        "WHERE TableId=?;"

  cmd.CommandText = sql
  cmd.Parameters.Append cmd.CreateParameter("@code", 202, 1, 50, code)
  cmd.Parameters.Append cmd.CreateParameter("@name", 202, 1, 100, name)
  cmd.Parameters.Append cmd.CreateParameter("@cap", 3, 1, , cap)
  cmd.Parameters.Append cmd.CreateParameter("@area", 3, 1, , areaId)
  cmd.Parameters.Append cmd.CreateParameter("@act", 11, 1, , active)
  cmd.Parameters.Append cmd.CreateParameter("@notes", 202, 1, 255, notes)
  cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , id)

Else
  ' CreatedAt NOT NULL => set SYSDATETIME()
  sql = "INSERT dbo.DiningTables(TableCode, TableName, Capacity, AreaId, IsActive, Notes, CreatedAt) " & _
        "VALUES (?, ?, ?, ?, ?, ?, SYSDATETIME());"

  cmd.CommandText = sql
  cmd.Parameters.Append cmd.CreateParameter("@code", 202, 1, 50, code)
  cmd.Parameters.Append cmd.CreateParameter("@name", 202, 1, 100, name)
  cmd.Parameters.Append cmd.CreateParameter("@cap", 3, 1, , cap)
  cmd.Parameters.Append cmd.CreateParameter("@area", 3, 1, , areaId)
  cmd.Parameters.Append cmd.CreateParameter("@act", 11, 1, , active)
  cmd.Parameters.Append cmd.CreateParameter("@notes", 202, 1, 255, notes)
End If

On Error Resume Next
cmd.Execute , , 129
If Err.Number <> 0 Then
  Dim ed: ed = Err.Description & ""
  On Error GoTo 0
  conn.Close : Set conn = Nothing
  Response.Redirect ROOT & "/admin/tables.asp?msg=" & Server.URLEncode("Lỗi lưu bàn: " & ed)
  Response.End
End If
On Error GoTo 0

conn.Close : Set conn = Nothing
Response.Redirect ROOT & "/admin/tables.asp?msg=" & Server.URLEncode("Đã lưu bàn")
Response.End
%>
