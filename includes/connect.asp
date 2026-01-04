<%
On Error Resume Next

If (Not IsObject(conn)) Or (conn Is Nothing) Then
    Set conn = Server.CreateObject("ADODB.Connection")
End If

If (conn Is Nothing) Then
    Response.Write "<h3>Không tạo được ADODB.Connection</h3>"
    Response.End
End If

If conn.State <> 1 Then
    Dim cs
    cs = "Provider=MSOLEDBSQL;" & _
         "Data Source=localhost;" & _
         "Initial Catalog=DoAnDatBan;" & _
         "User ID=sa;" & _
         "Password=son11111;" & _
         "Encrypt=False;" & _
         "TrustServerCertificate=True;"

    Err.Clear
    conn.Open cs

    If conn.State <> 1 Then
        Response.Write "<h3>Lỗi kết nối CSDL</h3>"
        Response.Write "<b>Err.Number:</b> " & Err.Number & "<br/>"
        Response.Write "<pre>" & Server.HTMLEncode(Err.Description & "") & "</pre>"
        Response.End
    End If
End If

On Error GoTo 0
%>
