<%
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")

On Error Resume Next
conn.Open "Provider=SQLOLEDB;" & _
          "Data Source=DESKTOP-VBLEOPD;" & _
          "Initial Catalog=DoAnDatBan;" & _
          "User ID=sa;" & _
          "Password=1234;"

If Err.Number <> 0 Then
    Response.Write "Lỗi kết nối CSDL: " & Err.Description
    Response.End
End If
On Error GoTo 0
%>
