
<!--#include file="includes/functions.asp" -->
<!--#include file="includes/connect.asp" -->
<!--#include file="includes/header.asp" -->

<%
' ===== đọc lỗi từ querystring =====
Dim errCode, errMsg
errCode = LCase(GetStr("err"))
errMsg = ""

Select Case errCode
    Case "missing_fields"
        errMsg = "Vui lòng nhập đầy đủ thông tin bắt buộc."
    Case "invalid"
        errMsg = "Thông tin chưa hợp lệ. Vui lòng kiểm tra lại."
    Case "invalid_date"
        errMsg = "Ngày đặt bàn không hợp lệ (không được ở quá khứ)."
    Case "invalid_phone"
        errMsg = "Số điện thoại không hợp lệ. Vui lòng nhập 9–12 chữ số."
    Case "invalid_email"
        errMsg = "Email không hợp lệ."
    Case "duplicate"
        errMsg = "SĐT của bạn đã đặt khung giờ này rồi. Vui lòng chọn khung giờ khác."
    Case "server"
        errMsg = "Hệ thống đang bận. Vui lòng thử lại sau."
End Select

' ===== giữ lại dữ liệu đã nhập (nếu có) =====
Dim fullName, email, phone, reservationDate, slotId, guests, note
fullName        = GetStr("fullname")
email           = GetStr("email")
phone           = GetStr("phone")
reservationDate = GetStr("reservation_date")
slotId          = GetInt("slot_id", 0)
guests          = GetInt("guests", 2)
note            = GetStr("note")

If reservationDate = "" Then
    ' mặc định: ngày mai
    reservationDate = CStr(DateAdd("d", 1, Date()))
End If
%>

<style>
    .page-title{
        font-size: 26px;
        margin: 0 0 16px 0;
    }
    .card{
        background:#fff;
        border:1px solid #eee;
        border-radius:10px;
        padding:18px;
        box-shadow: 0 6px 16px rgba(0,0,0,0.06);
        max-width: 620px;
    }
    .alert{
        padding:12px 14px;
        border-radius:8px;
        margin: 0 0 14px 0;
        border: 1px solid #ffd0d0;
        background:#fff1f1;
        color:#9b1c1c;
    }
    .form-row{ margin-bottom: 12px; }
    .form-row label{
        display:block;
        font-weight:600;
        margin-bottom:6px;
    }
    .form-row input, .form-row select, .form-row textarea{
        width:100%;
        padding:10px 12px;
        border:1px solid #ddd;
        border-radius:8px;
        outline:none;
        font-size: 14px;
        box-sizing: border-box;
    }
    .form-row input:focus, .form-row select:focus, .form-row textarea:focus{
        border-color:#999;
    }
    .hint{
        color:#666;
        font-size: 12px;
        margin-top:6px;
    }
    .actions{
        display:flex;
        gap:10px;
        align-items:center;
        margin-top: 10px;
    }
    .btn{
        display:inline-block;
        padding:10px 14px;
        border-radius:8px;
        border:1px solid transparent;
        cursor:pointer;
        text-decoration:none;
        font-weight:600;
        font-size: 14px;
    }
    .btn-submit{
        background:#e63946;
        color:#fff;
    }
    .btn-submit:hover{ background:#c92f3c; }
    .btn-secondary{
        background:#f2f2f2;
        color:#333;
        border-color:#e1e1e1;
    }
    .grid-2{
        display:grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
    }
    @media (max-width: 640px){
        .grid-2{ grid-template-columns: 1fr; }
    }
</style>

<h1 class="page-title">Đặt bàn</h1>

<div class="card">
    <% If errMsg <> "" Then %>
        <div class="alert"><%= HtmlEncode(errMsg) %></div>
    <% End If %>

    <form action="<%=ROOT%>/datban_submit.asp" method="post" autocomplete="on">
        <div class="form-row">
            <label>Họ và tên <span style="color:#e63946">*</span></label>
            <input type="text" name="fullname" value="<%= HtmlEncode(fullName) %>" required>
        </div>

        <div class="grid-2">
            <div class="form-row">
                <label>Số điện thoại <span style="color:#e63946">*</span></label>
                <input type="text" name="phone" value="<%= HtmlEncode(phone) %>" required>
                <div class="hint">Nhập 9–12 chữ số (có thể bỏ dấu cách/dấu gạch).</div>
            </div>

            <div class="form-row">
                <label>Email (nhận xác nhận)</label>
                <input type="email" name="email" value="<%= HtmlEncode(email) %>">
            </div>
        </div>

        <div class="grid-2">
            <div class="form-row">
                <label>Ngày đặt <span style="color:#e63946">*</span></label>
                <input type="date" name="reservation_date" value="<%= HtmlEncode(reservationDate) %>" required>
            </div>

            <div class="form-row">
                <label>Số khách <span style="color:#e63946">*</span></label>
                <input type="number" name="guests" min="1" max="50" value="<%= guests %>" required>
            </div>
        </div>

        <div class="form-row">
            <label>Khung giờ <span style="color:#e63946">*</span></label>
            <select name="slot_id" required>
                <option value="0">-- Chọn khung giờ --</option>
                <%
                    Dim rs, sql
                    Set rs = Server.CreateObject("ADODB.Recordset")

                    sql = "SELECT SlotId, SlotName FROM TimeSlots WHERE IsActive=1 ORDER BY SortOrder, StartTime"
                    rs.Open sql, conn, 1, 1

                    Do While Not rs.EOF
                        Dim sId, sName, sel
                        sId = CLng(rs("SlotId"))
                        sName = rs("SlotName") & ""
                        sel = ""
                        If slotId = sId Then sel = " selected"
                        Response.Write "<option value=""" & sId & """" & sel & ">" & HtmlEncode(sName) & "</option>"
                        rs.MoveNext
                    Loop

                    rs.Close : Set rs = Nothing
                %>
            </select>
        </div>

        <div class="form-row">
            <label>Ghi chú</label>
            <textarea name="note" rows="4"><%= HtmlEncode(note) %></textarea>
        </div>

        <div class="actions">
            <button type="submit" class="btn btn-submit">Xác nhận đặt bàn</button>
            <a class="btn btn-secondary" href="<%=ROOT%>/index.asp">Về trang chủ</a>
        </div>
    </form>
</div>

<%
' đóng kết nối DB
conn.Close : Set conn = Nothing
%>

<!--#include file="includes/footer.asp" -->
