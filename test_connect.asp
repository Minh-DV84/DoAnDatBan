<!--#include file="includes/connect.asp"-->

<%
Response.Write "<h2>TEST KẾT NỐI CSDL</h2>"

If Not conn Is Nothing Then
    If conn.State = 1 Then
        Response.Write "<p style='color:green;'>✅ Kết nối SQL Server THÀNH CÔNG</p>"
    Else
        Response.Write "<p style='color:red;'>❌ Có object conn nhưng CHƯA mở</p>"
    End If
Else
    Response.Write "<p style='color:red;'>❌ Không tạo được object conn</p>"
End If
%>
