<!--#include file="includes/config.asp" -->
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
    reservationDate = CStr(DateAdd("d", 1, Date()))
End If
%>

<style>
  :root{
    --bg1:#0b1220;
    --bg2:#121b2f;
    --card:#ffffff;
    --text:#0f172a;
    --muted:#475569;
    --border: rgba(15,23,42,.14);
    --shadow: 0 22px 70px rgba(0,0,0,.28);
    --accent:#ffb703;
    --accent2:#fb8500;
  }

  /* Nền trang sáng hơn (giữ vibe tối) */
  body{
    background:
      radial-gradient(900px 420px at 20% 0%, rgba(255,183,3,.12), transparent 60%),
      radial-gradient(900px 520px at 85% 15%, rgba(56,189,248,.10), transparent 55%),
      linear-gradient(180deg, var(--bg2), var(--bg1));
  }

  .booking-wrap{
    max-width: 1080px;
    margin: 0 auto;
    padding: 26px 16px 64px;
  }

  .page-title{
    font-size: 30px;
    margin: 0 0 10px 0;
    color: rgba(255,255,255,.94);
    letter-spacing: -0.02em;
  }

  .page-sub{
    margin: 0 0 18px 0;
    color: rgba(255,255,255,.72);
    max-width: 70ch;
    line-height: 1.6;
  }

  .card{
    background: var(--card);
    border: 1px solid rgba(15,23,42,.10);
    border-radius: 18px;
    padding: 18px;
    box-shadow: var(--shadow);
    max-width: 720px;
  }

  .alert{
    padding:12px 14px;
    border-radius:12px;
    margin: 0 0 14px 0;
    border: 1px solid rgba(230,57,70,.28);
    background: rgba(230,57,70,.10);
    color:#991b1b;
    font-weight: 700;
  }

  .form-row{ margin-bottom: 12px; }
  .form-row label{
    display:block;
    font-weight:900;
    margin-bottom:6px;
    color: var(--text);
  }

  .form-row input, .form-row select, .form-row textarea{
    width:100%;
    padding:11px 12px;
    border:1px solid rgba(15,23,42,.14);
    border-radius:12px;
    outline:none;
    font-size: 14px;
    box-sizing: border-box;
    background: #fff;
    color: var(--text);
    transition: box-shadow .15s ease, border-color .15s ease;
  }

  .form-row input:focus, .form-row select:focus, .form-row textarea:focus{
    border-color: rgba(251,133,0,.55);
    box-shadow: 0 0 0 4px rgba(255,183,3,.18);
  }

  .hint{
    color: var(--muted);
    font-size: 12.5px;
    margin-top:6px;
  }

  .grid-2{
    display:grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }

  .actions{
    display:flex;
    gap:10px;
    align-items:center;
    margin-top: 10px;
    flex-wrap: wrap;
  }

  .btn{
    display:inline-flex;
    align-items:center;
    justify-content:center;
    padding:10px 14px;
    border-radius:12px;
    border:1px solid transparent;
    cursor:pointer;
    text-decoration:none;
    font-weight:900;
    font-size: 14px;
    transition: transform .15s ease, opacity .15s ease, box-shadow .15s ease;
  }

  .btn:hover{ transform: translateY(-1px); opacity:.96; }

  .btn-submit{
    background: linear-gradient(90deg, var(--accent), var(--accent2));
    color:#111;
    box-shadow: 0 10px 22px rgba(251,133,0,.25);
  }

  .btn-secondary{
    background:#f3f4f6;
    color:#111827;
    border-color:#e5e7eb;
  }

  @media (max-width: 720px){
    .grid-2{ grid-template-columns: 1fr; }
    .card{ max-width: 100%; }
  }
</style>

<div class="booking-wrap">
  <h1 class="page-title">Đặt bàn</h1>
  <p class="page-sub">Chọn ngày/giờ, số khách và ghi chú yêu cầu. Chúng tôi sẽ xác nhận sớm nhất.</p>

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
</div>

<%
conn.Close : Set conn = Nothing
%>

<!--#include file="includes/footer.asp" -->
