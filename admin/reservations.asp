<%
Response.CodePage = 65001
Response.Charset  = "utf-8"
%>
<!--#include file="_auth.asp" -->
<!--#include file="../includes/connect.asp" -->

<%
' -------------------------
' Filters
' -------------------------
Dim fDate, fStatus, fSlot
fDate   = Trim(Request.QueryString("d") & "")
fStatus = Trim(Request.QueryString("st") & "")
fSlot   = Trim(Request.QueryString("slot") & "")

Dim slotId : slotId = 0
If IsNumeric(fSlot) Then slotId = CLng(fSlot)

' Load TimeSlots for dropdown
Dim rsSlots
Set rsSlots = conn.Execute("SELECT SlotId, SlotName FROM dbo.TimeSlots ORDER BY SlotId ASC")

' Build list query
Dim sql, cmd, rs
sql = ""
sql = sql & "SELECT TOP 200 "
sql = sql & " r.ReservationId, r.FullName, r.Phone, r.Email, r.Guests, r.ReservationDate, r.SlotId, r.Status, r.CreatedAt, "
sql = sql & " ts.SlotName, a.AreaName, t.TableName, t.Capacity "
sql = sql & "FROM dbo.Reservations r "
sql = sql & "LEFT JOIN dbo.TimeSlots ts ON ts.SlotId = r.SlotId "
sql = sql & "LEFT JOIN dbo.ReservationTables rt ON rt.ReservationId = r.ReservationId "
sql = sql & "LEFT JOIN dbo.DiningTables t ON t.TableId = rt.TableId "
sql = sql & "LEFT JOIN dbo.Areas a ON a.AreaId = t.AreaId "
sql = sql & "WHERE 1=1 "

Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandType = 1 ' adCmdText

' Apply filters with parameters (?)
If fDate <> "" Then
    sql = sql & " AND CAST(r.ReservationDate AS date) = CONVERT(date, ?, 23) "
    cmd.Parameters.Append cmd.CreateParameter("@d", 202, 1, 10, fDate) ' yyyy-mm-dd
End If

If fStatus <> "" Then
    sql = sql & " AND r.Status = ? "
    cmd.Parameters.Append cmd.CreateParameter("@st", 202, 1, 20, fStatus)
End If

If slotId > 0 Then
    sql = sql & " AND r.SlotId = ? "
    cmd.Parameters.Append cmd.CreateParameter("@slot", 3, 1, , CLng(slotId))
End If

sql = sql & " ORDER BY r.ReservationDate DESC, r.SlotId ASC, r.ReservationId DESC;"

cmd.CommandText = sql
Set rs = cmd.Execute

Function HE(x): HE = Server.HTMLEncode(x & ""): End Function

Function BadgeClass(st)
    Dim s: s = LCase(Trim(st & ""))
    BadgeClass = "badge"
    If s="pending"   Then BadgeClass = "badge b-pending"
    If s="confirmed" Then BadgeClass = "badge b-confirmed"
    If s="cancelled" Then BadgeClass = "badge b-cancelled"
    If s="completed" Then BadgeClass = "badge b-completed"
End Function

Function CanConfirm(st): CanConfirm = (LCase(Trim(st&""))="pending"): End Function
Function CanCancel(st)
    Dim s: s=LCase(Trim(st&""))
    CanCancel = (s="pending" Or s="confirmed")
End Function
Function CanComplete(st): CanComplete = (LCase(Trim(st&""))="confirmed"): End Function

' Build back url to return after update
Dim backUrl
backUrl = ROOT & "/admin/reservations.asp"
If Trim(Request.QueryString & "") <> "" Then backUrl = backUrl & "?" & Request.QueryString
Dim backEnc: backEnc = Server.URLEncode(backUrl)
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
    .filters{display:flex;gap:10px;flex-wrap:wrap;align-items:end}
    .f{display:flex;flex-direction:column;gap:6px}
    label{font-size:12px;color:#666}
    input,select{padding:10px 12px;border:1px solid #ddd;border-radius:10px;min-width:160px}
    button{padding:10px 12px;border:0;border-radius:10px;background:#111;color:#fff;font-weight:700;cursor:pointer}
    table{width:100%;border-collapse:collapse;margin-top:12px}
    th,td{padding:10px;border-bottom:1px solid #eee;text-align:left;font-size:14px;vertical-align:top}
    th{background:#fafafa;font-size:13px;color:#555}
    .badge{display:inline-block;padding:4px 10px;border-radius:999px;font-size:12px;background:#eee}
    .b-pending{background:#fff2cc}
    .b-confirmed{background:#d9f2e6}
    .b-cancelled{background:#ffe1e1}
    .b-completed{background:#e6ecff}
    .acts a{display:inline-block;margin-right:8px;text-decoration:none;padding:6px 10px;border-radius:10px;background:#111;color:#fff;font-weight:700;font-size:12px}
    .acts a.gray{background:#888}
    .acts a.disabled{background:#ddd;color:#666;pointer-events:none}
    .muted{color:#777;font-size:12px}
  </style>
</head>
<body>
<div class="wrap">
  <div class="topbar">
    <div class="brand">
      <a href="<%=ROOT%>/index.asp">Nhà hàng Lửa & Lá</a> / Admin / <b>Đơn đặt bàn</b>
    </div>

    <div class="nav">
      <span class="muted">Xin chào, <b><%=HE(Session("AdminFullName"))%></b></span>
      <a href="<%=ROOT%>/admin/areas.asp">Khu</a>
      <a href="<%=ROOT%>/admin/tables.asp">Bàn</a>
      <a href="<%=ROOT%>/admin/reservations.asp">Đơn</a>
      <a class="primary" href="<%=ROOT%>/admin/logout.asp">Đăng xuất</a>
    </div>
  </div>


  <div class="card">
    <h2 style="margin:0 0 10px 0;">Danh sách đơn đặt bàn</h2>

    <form method="get" action="<%=ROOT%>/admin/reservations.asp" class="filters">
      <div class="f">
        <label>Ngày (yyyy-mm-dd)</label>
        <input name="d" value="<%=HE(fDate)%>" placeholder="2026-01-02" />
      </div>

      <div class="f">
        <label>Trạng thái</label>
        <select name="st">
          <option value="" <% If fStatus="" Then Response.Write "selected" %> >Tất cả</option>
          <option value="Pending"   <% If LCase(fStatus)="pending" Then Response.Write "selected" %> >Pending</option>
          <option value="Confirmed" <% If LCase(fStatus)="confirmed" Then Response.Write "selected" %> >Confirmed</option>
          <option value="Cancelled" <% If LCase(fStatus)="cancelled" Then Response.Write "selected" %> >Cancelled</option>
          <option value="Completed" <% If LCase(fStatus)="completed" Then Response.Write "selected" %> >Completed</option>
        </select>
      </div>

      <div class="f">
        <label>Khung giờ</label>
        <select name="slot">
          <option value="0" <% If slotId=0 Then Response.Write "selected" %> >Tất cả</option>
          <%
          Do While Not rsSlots.EOF
            Dim sid, sname
            sid = CLng(rsSlots("SlotId"))
            sname = rsSlots("SlotName") & ""
          %>
            <option value="<%=sid%>" <% If slotId=sid Then Response.Write "selected" %> ><%=HE(sname)%></option>
          <%
            rsSlots.MoveNext
          Loop
          rsSlots.Close : Set rsSlots = Nothing
          %>
        </select>
      </div>

      <div class="f">
        <button type="submit">Lọc</button>
      </div>
    </form>

    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Khách</th>
          <th>Ngày / Giờ</th>
          <th>SĐT</th>
          <th>Số khách</th>
          <th>Khu / Bàn</th>
          <th>Trạng thái</th>
          <th>Thao tác</th>
        </tr>
      </thead>
      <tbody>
      <%
      If rs.EOF Then
      %>
        <tr><td colspan="8" class="muted">Không có dữ liệu.</td></tr>
      <%
      Else
        Do While Not rs.EOF
          Dim rid, st, areaName, tableName, cap, slotName, rdate
          rid = CLng(rs("ReservationId"))
          st  = rs("Status") & ""
          areaName = rs("AreaName") & ""
          tableName = rs("TableName") & ""
          cap = rs("Capacity") & ""
          slotName = rs("SlotName") & ""
          rdate = rs("ReservationDate") & ""

          Dim viewUrl
          viewUrl = ROOT & "/admin/reservation_view.asp?id=" & rid
      %>
        <tr>
          <td><b><%=rid%></b></td>
          <td>
            <div><%=HE(rs("FullName"))%></div>
            <div class="muted"><%=HE(rs("Email"))%></div>
          </td>
          <td><%=HE(rdate)%><br><span class="muted"><%=HE(slotName)%></span></td>
          <td><%=HE(rs("Phone"))%></td>
          <td><%=HE(rs("Guests"))%></td>
          <td>
            <div><b><%=HE(areaName)%></b></div>
            <div class="muted"><%=HE(tableName)%> (Cap: <%=HE(cap)%>)</div>
          </td>
          <td><span class="<%=BadgeClass(st)%>"><%=HE(st)%></span></td>
          <td class="acts">
            <a href="<%=viewUrl%>">Xem</a>

            <% If CanConfirm(st) Then %>
              <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=confirm&back=<%=backEnc%>">Confirm</a>
            <% Else %>
              <a class="disabled" href="javascript:void(0)">Confirm</a>
            <% End If %>

            <% If CanCancel(st) Then %>
              <a class="gray" href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=cancel&back=<%=backEnc%>">Cancel</a>
            <% Else %>
              <a class="disabled" href="javascript:void(0)">Cancel</a>
            <% End If %>

            <% If CanComplete(st) Then %>
              <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=complete&back=<%=backEnc%>">Complete</a>
            <% Else %>
              <a class="disabled" href="javascript:void(0)">Complete</a>
            <% End If %>
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

    <div class="muted" style="margin-top:10px;">Hiển thị tối đa 200 dòng (mới nhất).</div>
  </div>
</div>
</body>
</html>
