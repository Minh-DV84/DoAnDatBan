<%
Response.Buffer = True
Response.CodePage = 65001
Response.Charset  = "utf-8"

%>
<!--#include file="../includes/config.asp" -->
<!--#include file="_auth.asp" -->
<!--#include file="../includes/connect.asp" -->

<%
' ==========================================================
' admin/reservation_update.asp
' - action=confirm | cancel | complete
' - GET: ?id=123&action=confirm
' - Update Reservations + (optional) insert history
' ==========================================================

' --- Helpers ---
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

' --- Input ---
Dim idStr, action, rid
idStr = Trim(Request.QueryString("id") & "")
action = LCase(Trim(Request.QueryString("action") & ""))

If Not IsNumericId(idStr) Then
    Response.Redirect ROOT & "/admin/reservations.asp?err=bad_id"
    Response.End
End If
rid = CLng(idStr)

If action <> "confirm" And action <> "cancel" And action <> "complete" Then
    Response.Redirect ROOT & "/admin/reservations.asp?err=bad_action"
    Response.End
End If

' --- Read columns (Reservations + History) to avoid invalid column errors ---
Dim colsRes, colsHist, rsCols, colName
Set colsRes  = Server.CreateObject("Scripting.Dictionary")
Set colsHist = Server.CreateObject("Scripting.Dictionary")

' Reservations columns
On Error Resume Next
Set rsCols = conn.Execute( _
    "SELECT LOWER(COLUMN_NAME) AS c FROM INFORMATION_SCHEMA.COLUMNS " & _
    "WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Reservations';" _
)
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

' History columns (ReservationStatusHistory) - nếu bảng không tồn tại thì dict rỗng
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

' --- Fetch current reservation ---
Dim cmdGet, rsGet, curStatus
Set cmdGet = Server.CreateObject("ADODB.Command")
Set cmdGet.ActiveConnection = conn
cmdGet.CommandType = 1
cmdGet.CommandText = "SELECT ReservationId, Status FROM dbo.Reservations WHERE ReservationId=?;"
cmdGet.Parameters.Append cmdGet.CreateParameter("@Id", 3, 1, , rid)

On Error Resume Next
Set rsGet = cmdGet.Execute
If Err.Number <> 0 Then
    Dim errDesc0
    errDesc0 = Err.Description & ""
    On Error GoTo 0
    conn.Close : Set conn = Nothing
    Response.Write "<h3>Lỗi đọc đơn đặt bàn</h3>"
    Response.Write "<pre>" & Server.HTMLEncode(errDesc0) & "</pre>"
    Response.End
End If
On Error GoTo 0

If rsGet.EOF Then
    rsGet.Close : Set rsGet = Nothing
    conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/admin/reservations.asp?err=not_found"
    Response.End
End If

curStatus = LCase(Trim(rsGet("Status") & ""))
rsGet.Close : Set rsGet = Nothing
Set cmdGet = Nothing

' --- Validate transition ---
Dim newStatus, okTransition
okTransition = False

If action = "confirm" Then
    newStatus = "Confirmed"
    If curStatus = "pending" Then okTransition = True
End If

If action = "cancel" Then
    newStatus = "Cancelled"
    If curStatus = "pending" Or curStatus = "confirmed" Then okTransition = True
End If

If action = "complete" Then
    newStatus = "Completed"
    If curStatus = "confirmed" Then okTransition = True
End If

If Not okTransition Then
    conn.Close : Set conn = Nothing
    Response.Redirect ROOT & "/admin/reservation_view.asp?id=" & rid & "&err=invalid_transition"
    Response.End
End If

' --- Transaction ---
On Error Resume Next
conn.BeginTrans
If Err.Number <> 0 Then Err.Clear
On Error GoTo 0

' --- Build UPDATE Reservations safely (only columns that exist) ---
Dim setSql
setSql = "Status=?"

If HasCol(colsRes, "updatedat") Then
    setSql = setSql & ", UpdatedAt=GETDATE()"
End If

If action = "confirm" And HasCol(colsRes, "confirmedat") Then
    setSql = setSql & ", ConfirmedAt=GETDATE()"
End If

If action = "cancel" And HasCol(colsRes, "cancelledat") Then
    setSql = setSql & ", CancelledAt=GETDATE()"
End If

If action = "complete" And HasCol(colsRes, "completedat") Then
    setSql = setSql & ", CompletedAt=GETDATE()"
End If

Dim cmdUp
Set cmdUp = Server.CreateObject("ADODB.Command")
Set cmdUp.ActiveConnection = conn
cmdUp.CommandType = 1
cmdUp.CommandText = "UPDATE dbo.Reservations SET " & setSql & " WHERE ReservationId=?;"

cmdUp.Parameters.Append cmdUp.CreateParameter("@Status", 202, 1, 20, newStatus)
cmdUp.Parameters.Append cmdUp.CreateParameter("@Id", 3, 1, , rid)

On Error Resume Next
cmdUp.Execute , , 129
If Err.Number <> 0 Then
    Dim errDesc1
    errDesc1 = Err.Description & ""
    Err.Clear
    conn.RollbackTrans
    conn.Close : Set conn = Nothing
    Response.Write "<h3>Lỗi cập nhật trạng thái</h3>"
    Response.Write "<pre>" & Server.HTMLEncode(errDesc1) & "</pre>"
    Response.End
End If
On Error GoTo 0

Set cmdUp = Nothing

' --- Insert history (nếu có bảng + cột cần thiết) ---
' Expect columns: ReservationId, OldStatus, NewStatus, ChangedByAdminId, ChangedAt, Note (tuỳ)
Dim canHist
canHist = (HasCol(colsHist, "reservationid") And HasCol(colsHist, "oldstatus") And HasCol(colsHist, "newstatus"))

If canHist Then
    Dim colsIns, valsIns, cmdHist
    colsIns = "ReservationId, OldStatus, NewStatus"
    valsIns = "?, ?, ?"

    If HasCol(colsHist, "changedbyadminid") Then
        colsIns = colsIns & ", ChangedByAdminId"
        valsIns = valsIns & ", ?"
    End If

    If HasCol(colsHist, "changedat") Then
        colsIns = colsIns & ", ChangedAt"
        valsIns = valsIns & ", GETDATE()"
    End If

    ' note optional (từ querystring hoặc form)
    Dim note
    note = Trim(Request.Form("note") & "")
    If note = "" Then note = Trim(Request.QueryString("note") & "")

    If HasCol(colsHist, "note") Then
        colsIns = colsIns & ", Note"
        valsIns = valsIns & ", ?"
    End If

    Set cmdHist = Server.CreateObject("ADODB.Command")
    Set cmdHist.ActiveConnection = conn
    cmdHist.CommandType = 1
    cmdHist.CommandText = "INSERT INTO dbo.ReservationStatusHistory (" & colsIns & ") VALUES (" & valsIns & ");"

    cmdHist.Parameters.Append cmdHist.CreateParameter("@ReservationId", 3, 1, , rid)
    cmdHist.Parameters.Append cmdHist.CreateParameter("@OldStatus", 202, 1, 20, curStatus)
    cmdHist.Parameters.Append cmdHist.CreateParameter("@NewStatus", 202, 1, 20, LCase(newStatus))

    If HasCol(colsHist, "changedbyadminid") Then
        cmdHist.Parameters.Append cmdHist.CreateParameter("@ChangedBy", 3, 1, , CLng(Session("AdminId")))
    End If

    If HasCol(colsHist, "note") Then
        If Trim(note & "") = "" Then
            cmdHist.Parameters.Append cmdHist.CreateParameter("@Note", 202, 1, 500, Null)
        Else
            cmdHist.Parameters.Append cmdHist.CreateParameter("@Note", 202, 1, 500, note)
        End If
    End If

    On Error Resume Next
    cmdHist.Execute , , 129
    If Err.Number <> 0 Then
        ' Nếu history fail thì rollback để dữ liệu đồng bộ
        Dim errDesc2
        errDesc2 = Err.Description & ""
        Err.Clear
        conn.RollbackTrans
        conn.Close : Set conn = Nothing
        Response.Write "<h3>Lỗi ghi lịch sử trạng thái</h3>"
        Response.Write "<pre>" & Server.HTMLEncode(errDesc2) & "</pre>"
        Response.End
    End If
    On Error GoTo 0

    Set cmdHist = Nothing
End If

' --- Commit ---
On Error Resume Next
conn.CommitTrans
If Err.Number <> 0 Then
    Dim errDesc3
    errDesc3 = Err.Description & ""
    Err.Clear
    conn.RollbackTrans
    conn.Close : Set conn = Nothing
    Response.Write "<h3>Lỗi Commit giao dịch</h3>"
    Response.Write "<pre>" & Server.HTMLEncode(errDesc3) & "</pre>"
    Response.End
End If
On Error GoTo 0

conn.Close : Set conn = Nothing

' Redirect back
Response.Clear
Response.Redirect ROOT & "/admin/reservation_view.asp?id=" & rid & "&ok=" & action
Response.End

%>
