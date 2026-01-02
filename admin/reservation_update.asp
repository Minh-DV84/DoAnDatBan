<%
Response.CodePage = 65001
Response.Charset  = "utf-8"
%>
<!--#include file="../includes/config.asp" -->
<!--#include file="_auth.asp" -->
<!--#include file="../includes/connect.asp" -->

<%
Function AppendParam(url, key, val)
    If InStr(url, "?") > 0 Then
        AppendParam = url & "&" & key & "=" & Server.URLEncode(val)
    Else
        AppendParam = url & "?" & key & "=" & Server.URLEncode(val)
    End If
End Function

' ---- read inputs
Dim idStr, rid, action, back
idStr = Trim(Request.QueryString("id") & "")
action = LCase(Trim(Request.QueryString("action") & ""))
back = Trim(Request.QueryString("back") & "")

If idStr="" Or Not IsNumeric(idStr) Then
    conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/admin/reservations.asp?err=bad_id"
    Response.End
End If
rid = CLng(idStr)

If back = "" Then back = ROOT & "/admin/reservations.asp"

' tránh redirect ra ngoài site
If Left(back, Len(ROOT)) <> ROOT Then back = ROOT & "/admin/reservations.asp"

If action<>"confirm" And action<>"cancel" And action<>"complete" Then
    conn.Close : Set conn = Nothing
    Response.Redirect AppendParam(back, "err", "bad_action")
    Response.End
End If

' ---- load current status
Dim cmdGet, rsGet, curStatus, curLower
Set cmdGet = Server.CreateObject("ADODB.Command")
Set cmdGet.ActiveConnection = conn
cmdGet.CommandType = 1
cmdGet.CommandText = "SELECT ReservationId, Status FROM dbo.Reservations WHERE ReservationId = CAST(? AS BIGINT);"
cmdGet.Parameters.Append cmdGet.CreateParameter("@id", 20, 1, , rid) ' adBigInt

Set rsGet = cmdGet.Execute
If rsGet.EOF Then
    rsGet.Close : Set rsGet = Nothing
    conn.Close : Set conn = Nothing
    Response.Redirect AppendParam(back, "err", "not_found")
    Response.End
End If

curStatus = rsGet("Status") & ""
curLower  = LCase(Trim(curStatus))

rsGet.Close : Set rsGet = Nothing

' ---- validate transition
Dim newStatus
newStatus = ""

If action="confirm" Then
    If curLower <> "pending" Then
        conn.Close : Set conn = Nothing
        Response.Redirect AppendParam(back, "err", "invalid_transition")
        Response.End
    End If
    newStatus = "Confirmed"
End If

If action="cancel" Then
    If Not (curLower="pending" Or curLower="confirmed") Then
        conn.Close : Set conn = Nothing
        Response.Redirect AppendParam(back, "err", "invalid_transition")
        Response.End
    End If
    newStatus = "Cancelled"
End If

If action="complete" Then
    If curLower <> "confirmed" Then
        conn.Close : Set conn = Nothing
        Response.Redirect AppendParam(back, "err", "invalid_transition")
        Response.End
    End If
    newStatus = "Completed"
End If

' ---- detect optional columns to update timestamps safely
Dim cols, rsCols, c
Set cols = Server.CreateObject("Scripting.Dictionary")
Set rsCols = conn.Execute( _
  "SELECT LOWER(COLUMN_NAME) AS c " & _
  "FROM INFORMATION_SCHEMA.COLUMNS " & _
  "WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Reservations';" _
)
Do While Not rsCols.EOF
  c = rsCols("c") & ""
  If c<>"" Then If Not cols.Exists(c) Then cols.Add c, True
  rsCols.MoveNext
Loop
rsCols.Close : Set rsCols = Nothing

Dim sqlUpd
sqlUpd = "UPDATE dbo.Reservations SET Status = ?"

If cols.Exists("updatedat") Then
  sqlUpd = sqlUpd & ", UpdatedAt = SYSDATETIME()"
End If

If newStatus="Confirmed" And cols.Exists("confirmedat") Then
  sqlUpd = sqlUpd & ", ConfirmedAt = SYSDATETIME()"
End If

If newStatus="Cancelled" And cols.Exists("cancelledat") Then
  sqlUpd = sqlUpd & ", CancelledAt = SYSDATETIME()"
End If

If newStatus="Completed" And cols.Exists("completedat") Then
  sqlUpd = sqlUpd & ", CompletedAt = SYSDATETIME()"
End If

sqlUpd = sqlUpd & " WHERE ReservationId = CAST(? AS BIGINT);"

Dim cmdUpd
Set cmdUpd = Server.CreateObject("ADODB.Command")
Set cmdUpd.ActiveConnection = conn
cmdUpd.CommandType = 1
cmdUpd.CommandText = sqlUpd
cmdUpd.Parameters.Append cmdUpd.CreateParameter("@st", 202, 1, 20, newStatus)
cmdUpd.Parameters.Append cmdUpd.CreateParameter("@id", 20, 1, , rid)

On Error Resume Next
cmdUpd.Execute , , 129 ' adExecuteNoRecords
If Err.Number <> 0 Then
    On Error GoTo 0
    conn.Close : Set conn = Nothing
    Response.Redirect AppendParam(back, "err", "server")
    Response.End
End If
On Error GoTo 0

' (Tuỳ chọn) ghi ReservationStatusHistory nếu có bảng
Dim hasHist
hasHist = False
On Error Resume Next
Dim rsH
Set rsH = conn.Execute("SELECT TOP 1 1 AS X FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='ReservationStatusHistory';")
If Err.Number = 0 Then
    If Not rsH.EOF Then hasHist = True
End If
Err.Clear
On Error GoTo 0
If Not rsH Is Nothing Then rsH.Close : Set rsH = Nothing

If hasHist Then
    ' Insert đơn giản (nếu cột thiếu thì bạn có thể bỏ qua)
    On Error Resume Next
    conn.Execute "INSERT INTO dbo.ReservationStatusHistory(ReservationId, OldStatus, NewStatus, ChangedByAdminId, ChangedAt) " & _
                 "VALUES (" & rid & ", N'" & Replace(curStatus,"'","''") & "', N'" & Replace(newStatus,"'","''") & "', " & CLng(Session("AdminId")) & ", SYSDATETIME());"
    Err.Clear
    On Error GoTo 0
End If

conn.Close : Set conn = Nothing

Response.Redirect AppendParam(back, "ok", action)
Response.End
%>
