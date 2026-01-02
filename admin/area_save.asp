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
  Response.Redirect ROOT & "/admin/areas.asp"
  Response.End
End If

Dim id, name, pr, active
id = 0
If IsNumeric(Request.Form("AreaId") & "") Then id = CLng(Request.Form("AreaId"))

name = Trim(Request.Form("AreaName") & "")
If name = "" Then
  conn.Close : Set conn = Nothing
  Response.Redirect ROOT & "/admin/areas.asp?msg=" & Server.URLEncode("Thiếu tên khu")
  Response.End
End If

pr = 1
If IsNumeric(Request.Form("Priority") & "") Then pr = CLng(Request.Form("Priority"))
active = 1
If Trim(Request.Form("IsActive") & "") = "0" Then active = 0

Dim cmd, sql
Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandType = 1

If id > 0 Then
  sql = "UPDATE dbo.Areas SET AreaName=?, Priority=?, IsActive=? WHERE AreaId=?;"
  cmd.CommandText = sql
  cmd.Parameters.Append cmd.CreateParameter("@n", 202, 1, 100, name)
  cmd.Parameters.Append cmd.CreateParameter("@p", 3, 1, , pr)
  cmd.Parameters.Append cmd.CreateParameter("@a", 11, 1, , active) ' adBoolean
  cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , id)
Else
  sql = "INSERT dbo.Areas(AreaName, Priority, IsActive) VALUES(?, ?, ?);"
  cmd.CommandText = sql
  cmd.Parameters.Append cmd.CreateParameter("@n", 202, 1, 100, name)
  cmd.Parameters.Append cmd.CreateParameter("@p", 3, 1, , pr)
  cmd.Parameters.Append cmd.CreateParameter("@a", 11, 1, , active)
End If

On Error Resume Next
cmd.Execute , , 129
If Err.Number <> 0 Then
  Dim ed: ed = Err.Description & ""
  On Error GoTo 0
  conn.Close : Set conn = Nothing
  Response.Redirect ROOT & "/admin/areas.asp?msg=" & Server.URLEncode("Lỗi lưu khu: " & ed)
  Response.End
End If
On Error GoTo 0

conn.Close : Set conn = Nothing
Response.Redirect ROOT & "/admin/areas.asp?msg=" & Server.URLEncode("Đã lưu khu")
Response.End
%>
