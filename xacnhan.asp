
<!--#include file="includes/functions.asp" -->
<!--#include file="includes/connect.asp" -->
<!--#include file="includes/header.asp" -->

<%
' ==========================================================
' xacnhan.asp
' - Hiển thị thông tin đơn đặt bàn theo id
' ==========================================================

Dim id
id = GetInt("id", 0)

If id <= 0 Then
%>
    <h2>Không tìm thấy đơn đặt bàn</h2>
    <p>Mã đặt bàn không hợp lệ.</p>
    <p><a href="<%=ROOT%>/datban.asp">Quay lại đặt bàn</a></p>
<%
    conn.Close : Set conn = Nothing
%>
<!--#include file="includes/footer.asp" -->
<%
    Response.End
End If

Dim cmd, sql, rs
Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn

sql = ""
sql = sql & "SELECT r.ReservationId, r.FullName, r.Phone, r.Email, r.Guests, "
sql = sql & "       r.ReservationDate, r.Note, r.Status, r.CreatedAt, "
sql = sql & "       ts.SlotName "
sql = sql & "FROM dbo.Reservations r "
sql = sql & "INNER JOIN dbo.TimeSlots ts ON r.SlotId = ts.SlotId "
sql = sql & "WHERE r.ReservationId = ?;"

cmd.CommandText = sql
cmd.CommandType = 1 ' adCmdText
cmd.Parameters.Append cmd.CreateParameter("@Id", 3, 1, , CLng(id))

Set rs = cmd.Execute

If rs.EOF Then
%>
    <h2>Không tìm thấy đơn đặt bàn</h2>
    <p>Đơn đặt bàn không tồn tại hoặc đã bị xóa.</p>
    <p><a href="<%=ROOT%>/datban.asp">Quay lại đặt bàn</a></p>
<%
    rs.Close : Set rs = Nothing
    conn.Close : Set conn = Nothing
%>
<!--#include file="includes/footer.asp" -->
<%
    Response.End
End If

Dim fullName, phone, email, guests, rDate, slotName, note, status, createdAt
fullName = rs("FullName") & ""
phone    = rs("Phone") & ""
email    = rs("Email") & ""
guests   = rs("Guests")
rDate    = rs("ReservationDate")
slotName = rs("SlotName") & ""
note     = rs("Note") & ""
status   = rs("Status") & ""
createdAt= rs("CreatedAt")

rs.Close : Set rs = Nothing
conn.Close : Set conn = Nothing
%>

<style>
    .success-box{
        background:#ecfff2;
        border:1px solid #b7f0c7;
        padding:16px;
        border-radius:10px;
        margin: 0 0 16px 0;
    }
    .summary{
        background:#fff;
        border:1px solid #eee;
        border-radius:10px;
        padding:16px;
        box-shadow: 0 6px 16px rgba(0,0,0,0.06);
        max-width: 720px;
    }
    .row{
        display:flex;
        padding:8px 0;
        border-bottom:1px dashed #eee;
    }
    .row:last-child{ border-bottom:none; }
    .k{ width: 180px; color:#666; }
    .v{ flex:1; font-weight:600; }
    .actions{ margin-top:14px; display:flex; gap:10px; }
    .btn{
        display:inline-block;
        padding:10px 14px;
        border-radius:8px;
        text-decoration:none;
        font-weight:600;
        border:1px solid #e1e1e1;
        background:#f2f2f2;
        color:#333;
    }
    .btn-primary{
        background:#e63946;
        color:#fff;
        border-color:#e63946;
    }
</style>

<h1>Xác nhận đặt bàn</h1>

<div class="success-box">
    <div><strong>Đặt bàn thành công!</strong></div>
    <div>Mã đặt bàn của bạn: <strong>#<%= id %></strong></div>
    <div style="color:#2b6a3b; margin-top:6px; font-size:14px;">
        Trạng thái hiện tại: <strong><%= HtmlEncode(status) %></strong>
    </div>
</div>

<div class="summary">
    <div class="row">
        <div class="k">Họ và tên</div>
        <div class="v"><%= HtmlEncode(fullName) %></div>
    </div>
    <div class="row">
        <div class="k">Số điện thoại</div>
        <div class="v"><%= HtmlEncode(phone) %></div>
    </div>
    <div class="row">
        <div class="k">Email</div>
        <div class="v"><%= HtmlEncode(email) %></div>
    </div>
    <div class="row">
        <div class="k">Ngày đặt</div>
        <div class="v"><%= HtmlEncode(CStr(rDate)) %></div>
    </div>
    <div class="row">
        <div class="k">Khung giờ</div>
        <div class="v"><%= HtmlEncode(slotName) %></div>
    </div>
    <div class="row">
        <div class="k">Số khách</div>
        <div class="v"><%= guests %></div>
    </div>
    <div class="row">
        <div class="k">Ghi chú</div>
        <div class="v"><%= HtmlEncode(note) %></div>
    </div>

    <div class="actions">
        <a class="btn btn-primary" href="<%=ROOT%>/datban.asp">Đặt bàn mới</a>
        <a class="btn" href="<%=ROOT%>/index.asp">Về trang chủ</a>
    </div>
</div>

<!--#include file="includes/footer.asp" -->
