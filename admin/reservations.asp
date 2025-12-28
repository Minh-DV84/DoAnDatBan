<%
Response.CodePage = 65001
Response.Charset  = "utf-8"
%>
<!--#include file="../includes/config.asp" -->
<!--#include file="_auth.asp" -->
<!--#include file="../includes/connect.asp" -->

<%
Dim q, status, d
q = Trim(Request.QueryString("q") & "")
status = Trim(Request.QueryString("status") & "")
d = Trim(Request.QueryString("date") & "") ' yyyy-mm-dd

' validate status (chỉ cho 4 giá trị)
Dim statusOk
statusOk = False
If status <> "" Then
    Select Case LCase(status)
        Case "pending", "confirmed", "cancelled", "completed"
            statusOk = True
        Case Else
            statusOk = False
    End Select
End If

' validate date dạng yyyy-mm-dd (check đơn giản)
Function IsYmdDate(s)
    s = Trim(s & "")
    If Len(s) <> 10 Then IsYmdDate = False : Exit Function
    If Mid(s,5,1) <> "-" Or Mid(s,8,1) <> "-" Then IsYmdDate = False : Exit Function
    If Not IsNumeric(Replace(s, "-", "")) Then IsYmdDate = False : Exit Function
    IsYmdDate = True
End Function

Dim cmd, rs, sql, whereSql
Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandType = 1 ' adCmdText

whereSql = " WHERE 1=1 "

' Filter q: tìm theo SĐT hoặc tên (LIKE)
If q <> "" Then
    whereSql = whereSql & " AND (r.Phone LIKE ? OR r.FullName LIKE ?) "
    cmd.Parameters.Append cmd.CreateParameter("@qPhone", 202, 1, 30, "%" & q & "%")
    cmd.Parameters.Append cmd.CreateParameter("@qName", 202, 1, 120, "%" & q & "%")
End If

' Filter status
If statusOk Then
    whereSql = whereSql & " AND r.Status = ? "
    ' Lưu status đúng dạng chữ cái đầu (tuỳ DB bạn lưu)
    ' Ở đây mình chuẩn hoá: Pending/Confirmed/Cancelled/Completed
    Dim stNorm
    Select Case LCase(status)
        Case "pending":   stNorm = "Pending"
        Case "confirmed": stNorm = "Confirmed"
        Case "cancelled": stNorm = "Cancelled"
        Case "completed": stNorm = "Completed"
    End Select
    cmd.Parameters.Append cmd.CreateParameter("@status", 202, 1, 20, stNorm)
End If

' Filter date
If d <> "" And IsYmdDate(d) Then
    whereSql = whereSql & " AND r.ReservationDate = CONVERT(date, ?, 23) "
    cmd.Parameters.Append cmd.CreateParameter("@date", 202, 1, 10, d)
End If

sql = ""
sql = sql & "SELECT TOP 200 "
sql = sql & "  r.ReservationId, r.FullName, r.Phone, r.Email, r.Guests, "
sql = sql & "  r.ReservationDate, r.SlotId, ts.SlotName, ts.SortOrder, "
sql = sql & "  r.Status, r.CreatedAt "
sql = sql & "FROM dbo.Reservations r "
sql = sql & "LEFT JOIN dbo.TimeSlots ts ON r.SlotId = ts.SlotId "
sql = sql & whereSql
sql = sql & "ORDER BY r.ReservationDate DESC, ISNULL(ts.SortOrder, 999), r.ReservationId DESC;"

cmd.CommandText = sql

On Error Resume Next
Set rs = cmd.Execute
If Err.Number <> 0 Then
    Dim errDesc
    errDesc = Err.Description & ""
    On Error GoTo 0
    conn.Close : Set conn = Nothing
    Response.Write "<h3>Lỗi truy vấn danh sách đơn</h3>"
    Response.Write "<pre>" & Server.HTMLEncode(errDesc) & "</pre>"
    Response.End
End If
On Error GoTo 0
%>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <title>Admin - Danh sách đặt bàn</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#f6f6f6;color:#222}
    .wrap{max-width:1100px;margin:0 auto;padding:18px}
    .topbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
    .brand{font-weight:800;font-size:18px}
    .brand a{text-decoration:none;color:#111}
    .nav a{margin-left:10px;text-decoration:none;color:#333;padding:8px 10px;border-radius:10px;background:#eee}
    .nav a.primary{background:#e63946;color:#fff}
    .card{background:#fff;border:1px solid #eee;border-radius:14px;box-shadow:0 10px 22px rgba(0,0,0,.06);padding:14px}
    .filters{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:12px}
    .filters input,.filters select{padding:10px 12px;border:1px solid #ddd;border-radius:10px;font-size:14px}
    .filters button{padding:10px 14px;border:0;border-radius:10px;background:#111;color:#fff;font-weight:700;cursor:pointer}
    table{width:100%;border-collapse:collapse}
    th,td{padding:10px;border-bottom:1px solid #eee;text-align:left;font-size:14px;vertical-align:top}
    th{background:#fafafa;font-size:13px;color:#555}
    .badge{display:inline-block;padding:4px 10px;border-radius:999px;font-size:12px;background:#eee}
    .b-pending{background:#fff2cc}
    .b-confirmed{background:#d9f2e6}
    .b-cancelled{background:#ffe1e1}
    .b-completed{background:#e6ecff}
    .actions a{display:inline-block;margin-right:6px;text-decoration:none;padding:6px 10px;border-radius:10px;background:#eee;color:#111;font-size:13px}
  </style>
</head>

<body>
<div class="wrap">
  <div class="topbar">
    <div class="brand"><a href="<%=ROOT%>/index.asp">🍽 DoAnDatBan</a> / Quản trị</div>
    <div class="nav">
      <span style="color:#666;font-size:13px;">Xin chào, <b><%=Server.HTMLEncode(Session("AdminFullName") & "")%></b></span>
      <a href="<%=ROOT%>/datban.asp">Trang đặt bàn</a>
      <a class="primary" href="<%=ROOT%>/admin/logout.asp">Đăng xuất</a>
    </div>
  </div>

  <div class="card">
    <form class="filters" method="get" action="reservations.asp">
      <input type="text" name="q" placeholder="Tìm SĐT hoặc tên..." value="<%=Server.HTMLEncode(q)%>">
      <input type="date" name="date" value="<%=Server.HTMLEncode(d)%>">
      <select name="status">
        <option value="">-- Tất cả trạng thái --</option>
        <option value="pending"   <% If LCase(status)="pending" Then Response.Write("selected") %>>Pending</option>
        <option value="confirmed" <% If LCase(status)="confirmed" Then Response.Write("selected") %>>Confirmed</option>
        <option value="cancelled" <% If LCase(status)="cancelled" Then Response.Write("selected") %>>Cancelled</option>
        <option value="completed" <% If LCase(status)="completed" Then Response.Write("selected") %>>Completed</option>
      </select>
      <button type="submit">Lọc</button>
    </form>

    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Khách</th>
          <th>Liên hệ</th>
          <th>Ngày / Giờ</th>
          <th>Số khách</th>
          <th>Trạng thái</th>
          <th>Tạo lúc</th>
          <th>Thao tác</th>
        </tr>
      </thead>
      <tbody>
      <%
      If rs.EOF Then
      %>
        <tr><td colspan="8" style="color:#666;">Không có dữ liệu phù hợp bộ lọc.</td></tr>
      <%
      Else
        Do While Not rs.EOF
          Dim st, badgeClass
          st = LCase(rs("Status") & "")
          badgeClass = "badge"
          If st="pending" Then badgeClass = badgeClass & " b-pending"
          If st="confirmed" Then badgeClass = badgeClass & " b-confirmed"
          If st="cancelled" Then badgeClass = badgeClass & " b-cancelled"
          If st="completed" Then badgeClass = badgeClass & " b-completed"
      %>
        <tr>
          <td><%=rs("ReservationId")%></td>
          <td><%=Server.HTMLEncode(rs("FullName") & "")%></td>
          <td>
            <div><b>SĐT:</b> <%=Server.HTMLEncode(rs("Phone") & "")%></div>
            <div><b>Email:</b> <%=Server.HTMLEncode(rs("Email") & "")%></div>
          </td>
          <td>
            <div><b><%=rs("ReservationDate")%></b></div>
            <div><%=Server.HTMLEncode(rs("SlotName") & "")%></div>
          </td>
          <td><%=rs("Guests")%></td>
          <td><span class="<%=badgeClass%>"><%=Server.HTMLEncode(rs("Status") & "")%></span></td>
          <td><%=rs("CreatedAt")%></td>
          <td class="actions">
            <a href="<%=ROOT%>/admin/reservation_view.asp?id=<%=rs("ReservationId")%>">Xem</a>
            <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rs("ReservationId")%>&action=confirm">Confirm</a>
            <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rs("ReservationId")%>&action=cancel">Cancel</a>
            <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rs("ReservationId")%>&action=complete">Complete</a>
          </td>
        </tr>
      <%
          rs.MoveNext
        Loop
      End If

      rs.Close : Set rs = Nothing
      conn.Close : Set conn = Nothing
      %>
      </tbody>
    </table>
  </div>
</div>
</body>
</html>
