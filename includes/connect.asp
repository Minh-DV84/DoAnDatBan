<%
On Error Resume Next

' Tạo conn nếu chưa có hoặc đang Nothing
If (Not IsObject(conn)) Or (conn Is Nothing) Then
    Set conn = Server.CreateObject("ADODB.Connection")
End If

If (conn Is Nothing) Then
    Response.Write "<h3>Không tạo được ADODB.Connection</h3>"
    Response.End
End If

' Nếu đã mở rồi thì thôi
If conn.State <> 1 Then
    Dim cs
    cs = "Provider=SQLOLEDB;" & _
         "Data Source=DESKTOP-VBLEOPD;" & _
         "Initial Catalog=DoAnDatBan;" & _
         "User ID=sa;" & _
         "Password=1234;"

    ' Clear lỗi cũ trước khi open
    Err.Clear
    conn.Open cs

    ' CHỈ kiểm tra State (tránh lỗi ảo do Err dính)
    If conn.State <> 1 Then
        Response.Write "<h3>Lỗi kết nối CSDL</h3>"
        Response.Write "<b>Err.Number:</b> " & Err.Number & "<br/>"
        Response.Write "<pre>" & Server.HTMLEncode(Err.Description & "") & "</pre>"
        Response.End
    End If
End If

On Error GoTo 0
%>
