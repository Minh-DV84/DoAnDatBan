<%
Response.CodePage = 65001
Response.Charset  = "utf-8"
%>
<!--#include file="../includes/config.asp" -->
<!--#include file="_auth.asp" -->
<!--#include file="../includes/connect.asp" -->

<%
Function HE(x): HE = Server.HTMLEncode(x & ""): End Function

Dim idStr, rid
idStr = Trim(Request.QueryString("id") & "")
If idStr="" Or Not IsNumeric(idStr) Then
    conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/admin/reservations.asp?err=bad_id"
    Response.End
End If
rid = CLng(idStr)

' Load detail
Dim sql, cmd, rs
sql = ""
sql = sql & "SELECT r.*, ts.SlotName, a.AreaName, t.TableName, t.Capacity "
sql = sql & "FROM dbo.Reservations r "
sql = sql & "LEFT JOIN dbo.TimeSlots ts ON ts.SlotId = r.SlotId "
sql = sql & "LEFT JOIN dbo.ReservationTables rt ON rt.ReservationId = r.ReservationId "
sql = sql & "LEFT JOIN dbo.DiningTables t ON t.TableId = rt.TableId "
sql = sql & "LEFT JOIN dbo.Areas a ON a.AreaId = t.AreaId "
sql = sql & "WHERE r.ReservationId = CAST(? AS BIGINT);"

Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandType = 1
cmd.CommandText = sql
cmd.Parameters.Append cmd.CreateParameter("@id", 20, 1, , rid) ' adBigInt

Set rs = cmd.Execute
If rs.EOF Then
    rs.Close : Set rs = Nothing
    conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/admin/reservations.asp?err=not_found"
    Response.End
End If

Dim stLower
stLower = LCase(Trim(rs("Status") & ""))

Dim canConfirm, canCancel, canComplete
canConfirm = (stLower="pending")
canCancel  = (stLower="pending" Or stLower="confirmed")
canComplete= (stLower="confirmed")

Function BadgeClass(st)
    Dim s: s = LCase(Trim(st & ""))
    BadgeClass = "badge"
    If s="pending"   Then BadgeClass = "badge b-pending"
    If s="confirmed" Then BadgeClass = "badge b-confirmed"
    If s="cancelled" Then BadgeClass = "badge b-cancelled"
    If s="completed" Then BadgeClass = "badge b-completed"
End Function

Dim backUrl, backEnc
backUrl = ROOT & "/admin/reservation_view.asp?id=" & rid
backEnc = Server.URLEncode(backUrl)
%>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <title>Admin - Đơn #<%=rid%></title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#f6f6f6;color:#222}
    .wrap{max-width:1100px;margin:0 auto;padding:18px}
    .topbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
    .brand{font-weight:800;font-size:18px}
    .brand a{text-decoration:none;color:#111}
    .nav a{margin-left:10px;text-decoration:none;color:#333;padding:8px 10px;border-radius:10px;background:#eee}
    .nav a.primary{background:#e63946;color:#fff}
    .grid{display:grid;grid-template-columns:1.2fr .8fr;gap:14px}
    @media (max-width:900px){ .grid{grid-template-columns:1fr} }
    .card{background:#fff;border:1px solid #eee;border-radius:14px;box-shadow:0 10px 22px rgba(0,0,0,.06);padding:14px}
    .h{font-size:18px;font-weight:800;margin:0 0 10px 0}
    .row{display:flex;gap:14px;flex-wrap:wrap}
    .kv{min-width:220px}
    .k{color:#666;font-size:12px;margin-bottom:4px}
    .v{font-weight:700}
    .badge{display:inline-block;padding:4px 10px;border-radius:999px;font-size:12px;background:#eee}
    .b-pending{background:#fff2cc}
    .b-confirmed{background:#d9f2e6}
    .b-cancelled{background:#ffe1e1}
    .b-completed{background:#e6ecff}
    .actions a{display:inline-block;margin-right:8px;text-decoration:none;padding:8px 12px;border-radius:10px;background:#111;color:#fff;font-weight:700;font-size:13px}
    .actions a.gray{background:#888}
    .actions a.disabled{background:#ddd;color:#666;pointer-events:none}
    table{width:100%;border-collapse:collapse}
    th,td{padding:10px;border-bottom:1px solid #eee;text-align:left;font-size:14px;vertical-align:top}
    th{background:#fafafa;font-size:13px;color:#555}
    .small{color:#666;font-size:13px}
  </style>
</head>
<body>
<div class="wrap">
  <div class="topbar">
    <div class="brand">
      <a href="<%=ROOT%>/index.asp">🍽 DoAnDatBan</a> /
      <a href="<%=ROOT%>/admin/reservations.asp" style="text-decoration:none;color:#111;">Đơn đặt bàn</a> /
      #<%=rid%>
    </div>
    <div class="nav">
      <span class="small">Xin chào, <b><%=HE(Session("AdminFullName"))%></b></span>
      <a href="<%=ROOT%>/admin/reservations.asp">Danh sách</a>
      <a class="primary" href="<%=ROOT%>/admin/logout.asp">Đăng xuất</a>
    </div>
  </div>

  <div class="grid">
    <div class="card">
      <div class="h">Thông tin đơn</div>

      <div class="row">
        <div class="kv">
          <div class="k">Trạng thái</div>
          <div class="v"><span class="<%=BadgeClass(rs("Status"))%>"><%=HE(rs("Status"))%></span></div>
        </div>
        <div class="kv">
          <div class="k">Ngày / Giờ</div>
          <div class="v"><%=HE(rs("ReservationDate"))%> — <%=HE(rs("SlotName"))%></div>
        </div>
        <div class="kv">
          <div class="k">Số khách</div>
          <div class="v"><%=HE(rs("Guests"))%></div>
        </div>
      </div>

      <hr style="border:0;border-top:1px solid #eee;margin:14px 0;">

      <div class="row">
        <div class="kv">
          <div class="k">Khách</div>
          <div class="v"><%=HE(rs("FullName"))%></div>
        </div>
        <div class="kv">
          <div class="k">SĐT</div>
          <div class="v"><%=HE(rs("Phone"))%></div>
        </div>
        <div class="kv">
          <div class="k">Email</div>
          <div class="v"><%=HE(rs("Email"))%></div>
        </div>
      </div>

      <div style="margin-top:12px;">
        <div class="k">Ghi chú</div>
        <div class="small"><%=HE(rs("Note"))%></div>
      </div>

      <hr style="border:0;border-top:1px solid #eee;margin:14px 0;">

      <div class="row">
        <div class="kv">
          <div class="k">Khu</div>
          <div class="v"><%=HE(rs("AreaName"))%></div>
        </div>
        <div class="kv">
          <div class="k">Bàn</div>
          <div class="v"><%=HE(rs("TableName"))%> (Cap: <%=HE(rs("Capacity"))%>)</div>
        </div>
      </div>

      <hr style="border:0;border-top:1px solid #eee;margin:14px 0;">

      <div class="actions">
        <% If canConfirm Then %>
          <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=confirm&back=<%=backEnc%>">Confirm</a>
        <% Else %>
          <a class="disabled" href="javascript:void(0)">Confirm</a>
        <% End If %>

        <% If canCancel Then %>
          <a class="gray" href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=cancel&back=<%=backEnc%>">Cancel</a>
        <% Else %>
          <a class="disabled" href="javascript:void(0)">Cancel</a>
        <% End If %>

        <% If canComplete Then %>
          <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=complete&back=<%=backEnc%>">Complete</a>
        <% Else %>
          <a class="disabled" href="javascript:void(0)">Complete</a>
        <% End If %>
      </div>
    </div>

    <div class="card">
      <div class="h">Hệ thống</div>
      <table>
        <tr><th>CreatedAt</th><td><%=HE(rs("CreatedAt"))%></td></tr>
        <tr><th>UpdatedAt</th><td><%=HE(rs("UpdatedAt"))%></td></tr>
        <tr><th>SourceIP</th><td><%=HE(rs("SourceIP"))%></td></tr>
      </table>
      <div style="margin-top:10px;" class="small"><b>UserAgent</b><br><%=HE(rs("UserAgent"))%></div>
    </div>
  </div>

</div>
</body>
</html>

<%
rs.Close : Set rs = Nothing
conn.Close : Set conn = Nothing
%>
