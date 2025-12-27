<%
Response.CodePage = 65001
Response.Charset  = "utf-8"

' ROOT đặt ngay đây vì submit không include header
Const ROOT = "/DoAnDatBan"
%>

<!--#include file="includes/functions.asp" -->
<!--#include file="includes/connect.asp" -->

<%
' ==========================================================
' datban_submit.asp
' - Nhận POST từ datban.asp
' - Validate
' - Check duplicate (Pending/Confirmed)
' - Insert dbo.Reservations (Status=Pending)
' - Redirect sang xacnhan.asp?id=...
' ==========================================================

If UCase(Request.ServerVariables("REQUEST_METHOD")) <> "POST" Then
    Response.Redirect ROOT & "/datban.asp"
    Response.End
End If

Dim fullName, phone, email, reservationDate, slotId, guests, note
fullName        = GetStr("fullname")
phone           = GetStr("phone")
email           = GetStr("email")
reservationDate = GetStr("reservation_date")  ' yyyy-mm-dd
slotId          = GetInt("slot_id", 0)
guests          = GetInt("guests", 0)
note            = GetStr("note")

' ===== Validate bắt buộc =====
If fullName = "" Or phone = "" Or reservationDate = "" Or slotId <= 0 Or guests <= 0 Then
    Response.Redirect ROOT & "/datban.asp?err=missing_fields"
    Response.End
End If

If Not IsValidPhone(phone) Then
    Response.Redirect ROOT & "/datban.asp?err=invalid_phone"
    Response.End
End If

If Trim(email & "") <> "" Then
    If Not IsValidEmail(email) Then
        Response.Redirect ROOT & "/datban.asp?err=invalid_email"
        Response.End
    End If
End If

If Not IsFutureOrToday(reservationDate) Then
    Response.Redirect ROOT & "/datban.asp?err=invalid_date"
    Response.End
End If

If guests < 1 Or guests > 50 Then
    Response.Redirect ROOT & "/datban.asp?err=invalid"
    Response.End
End If


' ===== CHECK DUPLICATE TRƯỚC KHI INSERT =====
Dim cmdCheck, rsCheck, sqlCheck
Set cmdCheck = Server.CreateObject("ADODB.Command")
Set cmdCheck.ActiveConnection = conn
cmdCheck.CommandType = 1

sqlCheck = "SELECT COUNT(*) AS Cnt " & _
           "FROM dbo.Reservations " & _
           "WHERE Phone=? " & _
           "  AND ReservationDate = CONVERT(date, ?, 23) " & _
           "  AND SlotId=? " & _
           "  AND Status IN (N'Pending', N'Confirmed');"

cmdCheck.CommandText = sqlCheck
cmdCheck.Parameters.Append cmdCheck.CreateParameter("@Phone", 202, 1, 20, phone)
cmdCheck.Parameters.Append cmdCheck.CreateParameter("@ReservationDate", 202, 1, 10, reservationDate)
cmdCheck.Parameters.Append cmdCheck.CreateParameter("@SlotId", 3, 1, , CLng(slotId))

Set rsCheck = cmdCheck.Execute

If rsCheck("Cnt") > 0 Then
    rsCheck.Close : Set rsCheck = Nothing
    Set cmdCheck = Nothing
    conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/datban.asp?err=duplicate"
    Response.End
End If

rsCheck.Close : Set rsCheck = Nothing
Set cmdCheck = Nothing


' ===== INSERT RESERVATION (1 lần duy nhất) =====
Dim emailVal, noteVal
If Trim(email & "") = "" Then emailVal = Null Else emailVal = email End If
If Trim(note & "") = "" Then noteVal = Null Else noteVal = note End If

Dim cmd, sqlInsert
Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandType = 1

sqlInsert = ""
sqlInsert = sqlInsert & "INSERT INTO dbo.Reservations "
sqlInsert = sqlInsert & "(FullName, Email, Phone, Guests, ReservationDate, SlotId, Note, Status, SourceIP, UserAgent) "
sqlInsert = sqlInsert & "VALUES (?, ?, ?, ?, CONVERT(date, ?, 23), ?, ?, N'Pending', ?, ?);"

cmd.CommandText = sqlInsert

cmd.Parameters.Append cmd.CreateParameter("@FullName", 202, 1, 100, fullName)
cmd.Parameters.Append cmd.CreateParameter("@Email", 202, 1, 254, emailVal)
cmd.Parameters.Append cmd.CreateParameter("@Phone", 202, 1, 20, phone)
cmd.Parameters.Append cmd.CreateParameter("@Guests", 3, 1, , CLng(guests))
cmd.Parameters.Append cmd.CreateParameter("@ReservationDate", 202, 1, 10, reservationDate)
cmd.Parameters.Append cmd.CreateParameter("@SlotId", 3, 1, , CLng(slotId))
cmd.Parameters.Append cmd.CreateParameter("@Note", 202, 1, 500, noteVal)
cmd.Parameters.Append cmd.CreateParameter("@SourceIP", 202, 1, 45, Request.ServerVariables("REMOTE_ADDR"))
cmd.Parameters.Append cmd.CreateParameter("@UserAgent", 202, 1, 300, Left(Request.ServerVariables("HTTP_USER_AGENT") & "", 300))

On Error Resume Next
cmd.Execute , , 129   ' adExecuteNoRecords

If Err.Number <> 0 Then
    Dim errText
    errText = LCase(Err.Description & "")
    On Error GoTo 0

    conn.Close : Set conn = Nothing

    If InStr(errText, "duplicate") > 0 Or InStr(errText, "unique") > 0 Then
        Response.Redirect ROOT & "/datban.asp?err=duplicate"
    Else
        Response.Redirect ROOT & "/datban.asp?err=server"
    End If
    Response.End
End If
On Error GoTo 0


' ===== LẤY ID VỪA TẠO (cách chắc chắn theo unique combo) =====
Dim cmdGet, rsGet, newId
Set cmdGet = Server.CreateObject("ADODB.Command")
Set cmdGet.ActiveConnection = conn
cmdGet.CommandType = 1

cmdGet.CommandText = "SELECT TOP 1 ReservationId " & _
                     "FROM dbo.Reservations " & _
                     "WHERE Phone=? AND ReservationDate=CONVERT(date, ?, 23) AND SlotId=? " & _
                     "ORDER BY ReservationId DESC;"

cmdGet.Parameters.Append cmdGet.CreateParameter("@Phone", 202, 1, 20, phone)
cmdGet.Parameters.Append cmdGet.CreateParameter("@ReservationDate", 202, 1, 10, reservationDate)
cmdGet.Parameters.Append cmdGet.CreateParameter("@SlotId", 3, 1, , CLng(slotId))

Set rsGet = cmdGet.Execute

newId = 0
If Not rsGet.EOF Then newId = CLng(rsGet("ReservationId"))

rsGet.Close : Set rsGet = Nothing
Set cmdGet = Nothing

conn.Close : Set conn = Nothing

If newId > 0 Then
    Response.Redirect ROOT & "/xacnhan.asp?id=" & newId
Else
    Response.Redirect ROOT & "/datban.asp?err=server"
End If
%>
