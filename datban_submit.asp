<%
Response.CodePage = 65001
Response.Charset  = "utf-8"

%>
<!--#include file="includes/config.asp" -->
<!--#include file="includes/header.asp" -->
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


' ===== GỌI SP: tạo đơn + gán bàn (Rule 1) =====
Function ToDateISO(s)
    Dim p
    s = Trim(s & "")
    p = Split(s, "-")
    ' yyyy-mm-dd
    ToDateISO = DateSerial(CInt(p(0)), CInt(p(1)), CInt(p(2)))
End Function

Dim cmdSP, rsSP, resultCode, newId
Set cmdSP = Server.CreateObject("ADODB.Command")
Set cmdSP.ActiveConnection = conn
cmdSP.CommandType = 4 ' adCmdStoredProc
cmdSP.CommandText = "dbo.sp_CreateReservationAndAssignTable"

' Null hóa Email/Note
Dim emailVal, noteVal
If Trim(email & "") = "" Then emailVal = Null Else emailVal = email End If
If Trim(note & "") = "" Then noteVal = Null Else noteVal = note End If

cmdSP.Parameters.Append cmdSP.CreateParameter("@FullName", 202, 1, 100, fullName)
cmdSP.Parameters.Append cmdSP.CreateParameter("@Phone",    202, 1, 20,  phone)
cmdSP.Parameters.Append cmdSP.CreateParameter("@Email",    202, 1, 254, emailVal)
cmdSP.Parameters.Append cmdSP.CreateParameter("@Guests",   3,   1, , CLng(guests))

' DATE (an toàn theo yyyy-mm-dd)
cmdSP.Parameters.Append cmdSP.CreateParameter("@ReservationDate", 133, 1, , ToDateISO(reservationDate))

cmdSP.Parameters.Append cmdSP.CreateParameter("@SlotId",   3,   1, , CLng(slotId))
cmdSP.Parameters.Append cmdSP.CreateParameter("@Note",     202, 1, 500, noteVal)
cmdSP.Parameters.Append cmdSP.CreateParameter("@SourceIP", 202, 1, 45,  Request.ServerVariables("REMOTE_ADDR"))
cmdSP.Parameters.Append cmdSP.CreateParameter("@UserAgent",202, 1, 300, Left(Request.ServerVariables("HTTP_USER_AGENT") & "", 300))

On Error Resume Next
Set rsSP = cmdSP.Execute
If Err.Number <> 0 Then
    On Error GoTo 0
    conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/datban.asp?err=server"
    Response.End
End If
On Error GoTo 0

resultCode = -1
newId = 0
If Not rsSP Is Nothing Then
    If Not rsSP.EOF Then
        resultCode = CLng(rsSP("ResultCode"))
        If Not IsNull(rsSP("ReservationId")) Then newId = CLng(rsSP("ReservationId"))
    End If
    rsSP.Close : Set rsSP = Nothing
End If

conn.Close : Set conn = Nothing

Select Case resultCode
    Case 0
        ' Có bàn => qua xác nhận bình thường
        Response.Redirect ROOT & "/xacnhan.asp?id=" & newId

    Case 1
        ' Hết bàn phù hợp:
        ' ✅ Nếu SP của bạn có tạo đơn và trả ReservationId => qua xác nhận để hiện "sẽ liên hệ lại sau"
        ' ❗ Nếu newId = 0 (SP không tạo đơn) thì quay về datban báo lỗi như cũ
        If newId > 0 Then
            Response.Redirect ROOT & "/xacnhan.asp?id=" & newId
        Else
            Response.Redirect ROOT & "/datban.asp?err=capacity_full"
        End If

    Case 2
        ' Quá sức chứa:
        ' ✅ SP của bạn (bản đã sửa) có tạo đơn nhưng không gán bàn => qua xác nhận để hiện "sẽ liên hệ lại sau"
        If newId > 0 Then
            Response.Redirect ROOT & "/xacnhan.asp?id=" & newId
        Else
            Response.Redirect ROOT & "/datban.asp?err=too_large"
        End If

    Case Else
        Response.Redirect ROOT & "/datban.asp?err=server"
End Select
Response.End
%>