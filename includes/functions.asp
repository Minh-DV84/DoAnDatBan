<%
' ==================================================
' functions.asp
' Các hàm dùng chung – hạ tầng cơ bản
' Không chứa logic nghiệp vụ
' ==================================================

' ---------- LẤY REQUEST AN TOÀN ----------
Function GetStr(name)
    Dim v
    v = Trim(Request(name) & "")
    GetStr = v
End Function

Function GetInt(name, defaultVal)
    Dim v
    v = Trim(Request(name) & "")
    If IsNumeric(v) Then
        GetInt = CLng(v)
    Else
        GetInt = defaultVal
    End If
End Function

' ---------- ESCAPE HTML (CHỐNG XSS) ----------
Function HtmlEncode(v)
    HtmlEncode = Server.HTMLEncode(v & "")
End Function

' ---------- KIỂM TRA NGÀY HỢP LỆ ----------
Function IsValidDateStr(dateStr)
    On Error Resume Next
    Dim d
    d = CDate(dateStr)
    If Err.Number <> 0 Then
        IsValidDateStr = False
        Err.Clear
    Else
        IsValidDateStr = True
    End If
    On Error GoTo 0
End Function

' ---------- KIỂM TRA NGÀY KHÔNG Ở QUÁ KHỨ ----------
Function IsFutureOrToday(dateStr)
    If Not IsValidDateStr(dateStr) Then
        IsFutureOrToday = False
        Exit Function
    End If

    Dim d
    d = CDate(dateStr)

    If DateDiff("d", Date(), d) < 0 Then
        IsFutureOrToday = False
    Else
        IsFutureOrToday = True
    End If
End Function

' ---------- KIỂM TRA EMAIL CƠ BẢN ----------
Function IsValidEmail(email)
    email = Trim(email & "")
    If email = "" Then
        IsValidEmail = False
        Exit Function
    End If

    If InStr(email, "@") > 1 And InStrRev(email, ".") > InStr(email, "@") Then
        IsValidEmail = True
    Else
        IsValidEmail = False
    End If
End Function

' ---------- KIỂM TRA SỐ ĐIỆN THOẠI CƠ BẢN ----------
Function IsValidPhone(phone)
    phone = Trim(phone & "")
    phone = Replace(phone, " ", "")
    phone = Replace(phone, "-", "")

    If IsNumeric(phone) And Len(phone) >= 9 And Len(phone) <= 12 Then
        IsValidPhone = True
    Else
        IsValidPhone = False
    End If
End Function

%>
