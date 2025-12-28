<%
Response.Buffer = True


If IsEmpty(Session("AdminId")) Or (Trim(Session("AdminId") & "") = "") Then
    Response.Clear
    Response.Redirect ROOT & "/admin/login.asp?err=need_login"
    Response.End
End If
%>
