<%
Response.Buffer = True
Response.CodePage = 65001
Response.Charset  = "utf-8"
%>

<!--#include file="../includes/config.asp" -->
<!--#include file="_auth.asp" -->
<!--#include file="../includes/connect.asp" -->

<%
' =========================
' reservation_view.asp (fixed)
' =========================

Function IsNumericId(v)
    v = Trim(v & "")
    If v = "" Then IsNumericId = False : Exit Function
    IsNumericId = IsNumeric(v)
End Function

Function HasCol(dict, colLower)
    HasCol = False
    If Not dict Is Nothing Then
        If dict.Exists(LCase(colLower)) Then HasCol = True
    End If
End Function

Function HasTable(tableName)
    Dim r
    HasTable = False
    On Error Resume Next
    Set r = conn.Execute("SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='" & Replace(tableName,"'","''") & "';")
    If Err.Number = 0 Then
        If Not r.EOF Then HasTable = True
    End If
    Err.Clear
    On Error GoTo 0
    If Not r Is Nothing Then
        On Error Resume Next
        r.Close
        On Error GoTo 0
        Set r = Nothing
    End If
End Function

Sub SafeCloseRs(ByRef r)
    If Not (r Is Nothing) Then
        On Error Resume Next
        If r.State = 1 Then r.Close
        On Error GoTo 0
        Set r = Nothing
    End If
End Sub

' --- Input ---
Dim idStr, rid
idStr = Trim(Request.QueryString("id") & "")
If Not IsNumericId(idStr) Then
    Response.Redirect ROOT & "/admin/reservations.asp?err=bad_id"
    Response.End
End If
rid = CLng(idStr)

Dim ok, err, msg
ok = LCase(Trim(Request.QueryString("ok") & ""))
err = LCase(Trim(Request.QueryString("err") & ""))
msg = ""

If ok = "confirm" Then msg = "✅ Đã xác nhận đơn."
If ok = "cancel" Then msg = "✅ Đã hủy đơn."
If ok = "complete" Then msg = "✅ Đã hoàn tất đơn."
If err = "invalid_transition" Then msg = "⚠️ Không thể đổi trạng thái theo cách này (sai luồng)."

' --- Load columns of Reservations ---
Dim colsRes, rsCols, colName
Set colsRes = Server.CreateObject("Scripting.Dictionary")

On Error Resume Next
Set rsCols = conn.Execute( _
  "SELECT LOWER(COLUMN_NAME) AS c FROM INFORMATION_SCHEMA.COLUMNS " & _
  "WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Reservations';" _
)
If Err.Number <> 0 Then Err.Clear
On Error GoTo 0

If Not rsCols Is Nothing Then
    Do While Not rsCols.EOF
        colName = rsCols("c") & ""
        If colName <> "" Then
            If Not colsRes.Exists(colName) Then colsRes.Add colName, True
        End If
        rsCols.MoveNext
    Loop
    rsCols.Close : Set rsCols = Nothing
End If

' --- Determine if TimeSlots table exists ---
Dim hasTimeSlots
hasTimeSlots = HasTable("TimeSlots")

' --- Build SQL safely ---
Dim cmd, rs, sql
Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandType = 1 ' adCmdText

sql = ""
If hasTimeSlots Then
    sql = sql & "SELECT r.*, ts.SlotName "
    sql = sql & "FROM dbo.Reservations r "
    sql = sql & "LEFT JOIN dbo.TimeSlots ts ON r.SlotId = ts.SlotId "
Else
    sql = sql & "SELECT r.* "
    sql = sql & "FROM dbo.Reservations r "
End If
sql = sql & "WHERE r.ReservationId=?;"

cmd.CommandText = sql
cmd.Parameters.Append cmd.CreateParameter("@Id", 3, 1, , rid)

' --- Execute reservation query ---
On Error Resume Next
Set rs = cmd.Execute

Dim en, ed, e
en = Err.Number
ed = Err.Description & ""

If en <> 0 Then
    Response.Write "<h3>Lỗi đọc đơn đặt bàn</h3>"
    Response.Write "<b>Err.Number:</b> " & en & "<br/>"
    Response.Write "<b>Err.Description:</b><pre>" & Server.HTMLEncode(ed) & "</pre>"

    Response.Write "<b>conn.Errors.Count:</b> " & conn.Errors.Count & "<br/>"
    If conn.Errors.Count > 0 Then
        Response.Write "<h4>Conn.Errors</h4>"
        For Each e In conn.Errors
            Response.Write "<pre>" & Server.HTMLEncode(e.Description & "") & "</pre>"
        Next
    End If

    Response.Write "<h4>SQL</h4>"
    Response.Write "<pre>" & Server.HTMLEncode(cmd.CommandText & "") & "</pre>"
    Response.End
End If

On Error GoTo 0

If rs Is Nothing Or rs.EOF Then
    SafeCloseRs rs
    If Not (conn Is Nothing) Then conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/admin/reservations.asp?err=not_found"
    Response.End
End If

' --- Read fields ---
Dim fullName, phone, email, guests, rdate, slotName, status, note
fullName = rs("FullName") & ""
phone    = rs("Phone") & ""
status   = rs("Status") & ""
guests   = rs("Guests") & ""
rdate    = rs("ReservationDate") & ""

slotName = "(không có)"
If hasTimeSlots Then
    On Error Resume Next
    slotName = rs("SlotName") & ""
    If Err.Number <> 0 Then
        Err.Clear
        slotName = "(không có)"
    End If
    On Error GoTo 0
End If

email = ""
If HasCol(colsRes, "email") Then email = rs("Email") & ""
note  = ""
If HasCol(colsRes, "note") Then note = rs("Note") & ""

Dim createdAt, updatedAt, confirmedAt, cancelledAt, completedAt
createdAt = "" : updatedAt = "" : confirmedAt = "" : cancelledAt = "" : completedAt = ""
If HasCol(colsRes, "createdat") Then createdAt = rs("CreatedAt") & ""
If HasCol(colsRes, "updatedat") Then updatedAt = rs("UpdatedAt") & ""
If HasCol(colsRes, "confirmedat") Then confirmedAt = rs("ConfirmedAt") & ""
If HasCol(colsRes, "cancelledat") Then cancelledAt = rs("CancelledAt") & ""
If HasCol(colsRes, "completedat") Then completedAt = rs("CompletedAt") & ""

Dim sourceIP, userAgent
sourceIP = "" : userAgent = ""
If HasCol(colsRes, "sourceip") Then sourceIP = rs("SourceIP") & ""
If HasCol(colsRes, "useragent") Then userAgent = rs("UserAgent") & ""

' status normalize
Dim stLower, badgeClass
stLower = LCase(Trim(status & ""))

badgeClass = "badge"
If stLower="pending" Then badgeClass = badgeClass & " b-pending"
If stLower="confirmed" Then badgeClass = badgeClass & " b-confirmed"
If stLower="cancelled" Then badgeClass = badgeClass & " b-cancelled"
If stLower="completed" Then badgeClass = badgeClass & " b-completed"

Dim canConfirm, canCancel, canComplete
canConfirm = (stLower="pending")
canCancel  = (stLower="pending" Or stLower="confirmed")
canComplete= (stLower="confirmed")

' Close rs (we already read data)
SafeCloseRs rs

' --- History (optional) ---
Dim rsHist, colsHist, hasHistTable
Set rsHist = Nothing
Set colsHist = Server.CreateObject("Scripting.Dictionary")
hasHistTable = HasTable("ReservationStatusHistory")

If hasHistTable Then
    On Error Resume Next
    Set rsCols = conn.Execute( _
      "SELECT LOWER(COLUMN_NAME) AS c FROM INFORMATION_SCHEMA.COLUMNS " & _
      "WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='ReservationStatusHistory';" _
    )
    If Err.Number <> 0 Then Err.Clear
    On Error GoTo 0

    If Not rsCols Is Nothing Then
        Do While Not rsCols.EOF
            colName = rsCols("c") & ""
            If colName <> "" Then
                If Not colsHist.Exists(colName) Then colsHist.Add colName, True
            End If
            rsCols.MoveNext
        Loop
        rsCols.Close : Set rsCols = Nothing
    End If

    If HasCol(colsHist, "reservationid") Then
        Dim cmdHist, sqlHist
        Set cmdHist = Server.CreateObject("ADODB.Command")
        Set cmdHist.ActiveConnection = conn
        cmdHist.CommandType = 1

        sqlHist = "SELECT TOP 50 * FROM dbo.ReservationStatusHistory WHERE ReservationId=? "
        If HasCol(colsHist, "changedat") Then
            sqlHist = sqlHist & "ORDER BY ChangedAt DESC;"
        Else
            sqlHist = sqlHist & "ORDER BY (SELECT NULL);"
        End If

        cmdHist.CommandText = sqlHist
        cmdHist.Parameters.Append cmdHist.CreateParameter("@Rid", 3, 1, , rid)

        On Error Resume Next
        Set rsHist = cmdHist.Execute
        If Err.Number <> 0 Then
            Err.Clear
            Set rsHist = Nothing
        End If
        On Error GoTo 0
    End If
End If
%>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <title>Admin - Chi tiết đơn #<%=rid%></title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#f6f6f6;color:#222}
    .wrap{max-width:1100px;margin:0 auto;padding:18px}
    .topbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
    .brand{font-weight:800;font-size:18px}
    .brand a{text-decoration:none;color:#111}
    .nav a{margin-left:10px;text-decoration:none;color:#333;padding:8px 10px;border-radius:10px;background:#eee}
    .nav a.primary{background:#e63946;color:#fff}
    .grid{display:grid;grid-template-columns:1.1fr .9fr;gap:14px}
    @media (max-width:900px){ .grid{grid-template-columns:1fr} }
    .card{background:#fff;border:1px solid #eee;border-radius:14px;box-shadow:0 10px 22px rgba(0,0,0,.06);padding:14px}
    .h{font-size:18px;font-weight:800;margin:0 0 8px 0}
    .msg{background:#f0f8ff;border:1px solid #d7ecff;border-radius:12px;padding:10px 12px;margin-bottom:12px}
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
    .mono{font-family:Consolas,monospace;font-size:12px;color:#444;white-space:pre-wrap;word-break:break-word}
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
      <span style="color:#666;font-size:13px;">Xin chào, <b><%=Server.HTMLEncode(Session("AdminFullName") & "")%></b></span>
      <a href="<%=ROOT%>/admin/reservations.asp">Danh sách</a>
      <a class="primary" href="<%=ROOT%>/admin/logout.asp">Đăng xuất</a>
    </div>
  </div>

  <% If Trim(msg & "") <> "" Then %>
    <div class="msg"><%=Server.HTMLEncode(msg)%></div>
  <% End If %>

  <div class="grid">
    <div class="card">
      <div class="h">Thông tin đơn</div>

      <div class="row">
        <div class="kv">
          <div class="k">Trạng thái</div>
          <div class="v"><span class="<%=badgeClass%>"><%=Server.HTMLEncode(status)%></span></div>
        </div>

        <div class="kv">
          <div class="k">Ngày / Giờ</div>
          <div class="v"><%=Server.HTMLEncode(rdate)%> — <%=Server.HTMLEncode(slotName)%></div>
        </div>

        <div class="kv">
          <div class="k">Số khách</div>
          <div class="v"><%=Server.HTMLEncode(guests)%></div>
        </div>
      </div>

      <hr style="border:0;border-top:1px solid #eee;margin:14px 0;">

      <div class="row">
        <div class="kv">
          <div class="k">Khách</div>
          <div class="v"><%=Server.HTMLEncode(fullName)%></div>
        </div>

        <div class="kv">
          <div class="k">SĐT</div>
          <div class="v"><%=Server.HTMLEncode(phone)%></div>
        </div>

        <div class="kv">
          <div class="k">Email</div>
          <div class="v"><%=Server.HTMLEncode(email)%></div>
        </div>
      </div>

      <div style="margin-top:12px;">
        <div class="k">Ghi chú</div>
        <div class="small"><%=Server.HTMLEncode(note)%></div>
      </div>

      <hr style="border:0;border-top:1px solid #eee;margin:14px 0;">

      <div class="actions">
        <% If canConfirm Then %>
          <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=confirm">Confirm</a>
        <% Else %>
          <a class="disabled" href="javascript:void(0)">Confirm</a>
        <% End If %>

        <% If canCancel Then %>
          <a class="gray" href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=cancel">Cancel</a>
        <% Else %>
          <a class="disabled" href="javascript:void(0)">Cancel</a>
        <% End If %>

        <% If canComplete Then %>
          <a href="<%=ROOT%>/admin/reservation_update.asp?id=<%=rid%>&action=complete">Complete</a>
        <% Else %>
          <a class="disabled" href="javascript:void(0)">Complete</a>
        <% End If %>
      </div>
    </div>

    <div class="card">
      <div class="h">Hệ thống</div>

      <table>
        <tr><th>CreatedAt</th><td><%=Server.HTMLEncode(createdAt)%></td></tr>
        <tr><th>UpdatedAt</th><td><%=Server.HTMLEncode(updatedAt)%></td></tr>
        <tr><th>ConfirmedAt</th><td><%=Server.HTMLEncode(confirmedAt)%></td></tr>
        <tr><th>CancelledAt</th><td><%=Server.HTMLEncode(cancelledAt)%></td></tr>
        <tr><th>CompletedAt</th><td><%=Server.HTMLEncode(completedAt)%></td></tr>
      </table>

      <div style="margin-top:12px;">
        <div class="k">SourceIP</div>
        <div class="mono"><%=Server.HTMLEncode(sourceIP)%></div>
      </div>

      <div style="margin-top:12px;">
        <div class="k">UserAgent</div>
        <div class="mono"><%=Server.HTMLEncode(userAgent)%></div>
      </div>
    </div>
  </div>

  <div class="card" style="margin-top:14px;">
    <div class="h">Lịch sử trạng thái</div>

    <%
    If rsHist Is Nothing Then
    %>
      <div class="small">Không có lịch sử hoặc bảng lịch sử chưa bật.</div>
    <%
    ElseIf rsHist.EOF Then
    %>
      <div class="small">Chưa có bản ghi lịch sử.</div>
    <%
    Else
    %>
      <table>
        <thead>
          <tr>
            <th>Thời gian</th>
            <th>Old → New</th>
            <th>AdminId</th>
            <th>Note</th>
          </tr>
        </thead>
        <tbody>
        <%
          Do While Not rsHist.EOF
            Dim hTime, hOld, hNew, hBy, hNote
            hTime = "" : hOld="" : hNew="" : hBy="" : hNote=""

            If HasCol(colsHist, "changedat") Then hTime = rsHist("ChangedAt") & ""
            If HasCol(colsHist, "oldstatus") Then hOld = rsHist("OldStatus") & ""
            If HasCol(colsHist, "newstatus") Then hNew = rsHist("NewStatus") & ""
            If HasCol(colsHist, "changedbyadminid") Then hBy = rsHist("ChangedByAdminId") & ""
            If HasCol(colsHist, "note") Then hNote = rsHist("Note") & ""
        %>
          <tr>
            <td><%=Server.HTMLEncode(hTime)%></td>
            <td><%=Server.HTMLEncode(hOld)%> → <%=Server.HTMLEncode(hNew)%></td>
            <td><%=Server.HTMLEncode(hBy)%></td>
            <td><%=Server.HTMLEncode(hNote)%></td>
          </tr>
        <%
            rsHist.MoveNext
          Loop
          rsHist.Close : Set rsHist = Nothing
        %>
        </tbody>
      </table>
    <%
    End If
    %>
  </div>

</div>
</body>
</html>

<%
' cleanup
If Not (conn Is Nothing) Then
    On Error Resume Next
    conn.Close
    On Error GoTo 0
    Set conn = Nothing
End If
%>
