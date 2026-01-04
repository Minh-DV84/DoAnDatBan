<%
Response.Buffer = True
Response.CodePage = 65001
Response.Charset  = "utf-8"
Const ROOT = "/DoAnDatBan"
%>

<!--#include file="../includes/connect.asp" -->

<%
If UCase(Request.ServerVariables("REQUEST_METHOD")) <> "POST" Then
    Response.Redirect ROOT & "/admin/login.asp?err=need_login"
    Response.End
End If

Dim username, password
username = Trim(Request.Form("username") & "")
password = Trim(Request.Form("password") & "")

If username = "" Or password = "" Then
    Response.Redirect ROOT & "/admin/login.asp?err=required&u=" & Server.URLEncode(username)
    Response.End
End If

Dim cmd, rs, sql
Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandType = 1 ' adCmdText

' Dùng đúng schema: PasswordHash + PasswordSalt (SHA2_256)
sql = ""
sql = sql & "SELECT TOP 1 AdminId, Username, DisplayName "
sql = sql & "FROM dbo.AdminUsers "
sql = sql & "WHERE Username=? AND IsActive=1 "
sql = sql & "AND PasswordHash = CONVERT(NVARCHAR(200), HASHBYTES('SHA2_256', ? + CAST(PasswordSalt AS NVARCHAR(200))), 2);"

cmd.CommandText = sql
cmd.Parameters.Append cmd.CreateParameter("@u", 202, 1, 50, username)
cmd.Parameters.Append cmd.CreateParameter("@p", 202, 1, 200, password)

On Error Resume Next
Set rs = cmd.Execute
If Err.Number <> 0 Then
    Response.Write "<h3>Lỗi đăng nhập</h3>"
    Response.Write "<pre>" & Server.HTMLEncode(Err.Description & "") & "</pre>"
    Response.End
End If
On Error GoTo 0

If rs.EOF Then
    rs.Close : Set rs = Nothing
    conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/admin/login.asp?err=invalid&u=" & Server.URLEncode(username)
    Response.End
End If

Session.Timeout = 60
Session("AdminId") = rs("AdminId")
Session("AdminUsername") = rs("Username") & ""
Session("AdminFullName") = rs("DisplayName") & ""

rs.Close : Set rs = Nothing
conn.Close : Set conn = Nothing

Response.Redirect ROOT & "/admin/reservations.asp"
Response.End
%>
