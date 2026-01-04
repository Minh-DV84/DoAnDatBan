<!--#include file="../includes/config.asp" -->
<%
Response.Buffer = True

If Len(Trim(Session("AdminId") & "")) = 0 Then
    Response.Clear
    Response.Redirect ROOT & "/admin/login.asp?err=need_login"
    Response.End
End If
%>
