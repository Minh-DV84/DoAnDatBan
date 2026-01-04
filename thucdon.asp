<!--#include file="includes/config.asp" -->
<!--#include file="includes/connect.asp" -->
<!--#include file="includes/header.asp" -->

<style>
  :root{
    --bg: #0b1220;
    --card: rgba(255,255,255,.06);
    --text: rgba(255,255,255,.92);
    --muted: rgba(255,255,255,.72);
    --border: rgba(255,255,255,.14);
    --accent: #ffb703;
    --accent2: #fb8500;
    --radius: 18px;
    --radius2: 14px;
    --shadow: 0 18px 60px rgba(0,0,0,.35);
  }
  body{ background: var(--bg); }

  .menu-wrap{
    max-width: 1080px;
    margin: 0 auto;
    padding: 26px 16px 64px;
    color: var(--text);
  }

  .menu-hero{
    border-radius: var(--radius);
    border: 1px solid var(--border);
    box-shadow: var(--shadow);
    padding: 22px;
    background:
      linear-gradient(120deg, rgba(11,18,32,.92), rgba(11,18,32,.62)),
      url("<%=ROOT%>/images/hero-dish.jpg") center/cover no-repeat;
    overflow: hidden;
  }

  .menu-hero h1{
    margin: 0 0 8px;
    font-size: clamp(24px, 3vw, 36px);
    letter-spacing: -0.02em;
  }
  .menu-hero p{
    margin: 0 0 14px;
    max-width: 62ch;
    color: var(--muted);
    line-height: 1.6;
  }

  .btn{
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    padding: 12px 16px;
    border-radius: 999px;
    border: 1px solid var(--border);
    text-decoration: none;
    color: var(--text);
    font-weight: 800;
    transition: transform .15s ease, opacity .15s ease;
    background: rgba(255,255,255,.06);
  }
  .btn:hover{ transform: translateY(-1px); opacity: .95; }
  .btn-primary{
    background: linear-gradient(90deg, var(--accent), var(--accent2));
    color: #111;
    border-color: rgba(255,255,255,.18);
  }

  .section-title{
    margin: 18px 0 10px;
    font-size: 18px;
    letter-spacing: -0.01em;
  }

  .grid{
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
  }

  .item{
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: var(--radius2);
    overflow: hidden;
  }

  .item img{
    width: 100%;
    height: 160px;
    object-fit: cover;
    display: block;
  }

  .item .body{
    padding: 12px;
  }

  .row{
    display: flex;
    justify-content: space-between;
    gap: 12px;
    align-items: baseline;
  }

  .name{
    font-weight: 900;
    letter-spacing: -0.01em;
    margin: 0;
  }

  .price{
    font-weight: 900;
    color: var(--accent);
    white-space: nowrap;
  }

  .desc{
    margin: 6px 0 0;
    color: var(--muted);
    font-size: 13.8px;
    line-height: 1.55;
  }

  .category{
    margin-top: 18px;
    padding-top: 6px;
  }

  @media (max-width: 900px){
    .grid{ grid-template-columns: 1fr; }
  }
</style>

<div class="menu-wrap">

  <div class="menu-hero">
    <h1>Thực đơn</h1>
    <p>Danh sách món được lấy tự động từ cơ sở dữ liệu. Bạn có thể thêm/sửa món trong SQL để thay đổi nội dung.</p>
    <a class="btn btn-primary" href="<%=ROOT%>/datban.asp">👉 Đặt bàn ngay</a>
    <a class="btn" style="margin-left:10px" href="<%=ROOT%>/index.asp">⬅️ Về trang chủ</a>
  </div>

  <%
    ' ===== Helpers =====
    Function FormatVND(n)
        If IsNull(n) Or ("" & n) = "" Then
            FormatVND = "0đ"
        Else
            FormatVND = Replace(FormatNumber(CLng(n), 0), ",", ".") & "đ"
        End If
    End Function

    ' ===== Query Menu =====
    Dim sql, rs, currentCat
    currentCat = ""

    sql = "SELECT c.CategoryName, c.SortOrder AS CatOrder, " & _
          "i.ItemName, i.ItemDesc, i.Price, i.ImageUrl, i.SortOrder AS ItemOrder " & _
          "FROM MenuCategory c " & _
          "JOIN MenuItem i ON i.CategoryID = c.CategoryID " & _
          "WHERE c.IsActive = 1 AND i.IsActive = 1 " & _
          "ORDER BY c.SortOrder, c.CategoryName, i.SortOrder, i.ItemName"

    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.Open sql, conn, 1, 1  ' adOpenKeyset=1, adLockReadOnly=1

    If rs.EOF Then
  %>
      <div class="category">
        <div class="section-title">Chưa có dữ liệu</div>
        <p style="color: var(--muted); margin:0;">Bạn hãy chạy SQL seed để thêm món vào bảng MenuCategory/MenuItem.</p>
      </div>
  <%
    Else
      Do While Not rs.EOF

        If currentCat <> rs("CategoryName") Then
          ' đóng danh mục trước đó (nếu có)
          If currentCat <> "" Then
  %>
            </div>
          </div>
  <%
          End If

          currentCat = rs("CategoryName")
  %>
      <div class="category">
        <div class="section-title"><%=Server.HTMLEncode(currentCat)%></div>
        <div class="grid">
  <%
        End If

        Dim imgUrl
        imgUrl = rs("ImageUrl")
        If IsNull(imgUrl) Or Trim(imgUrl) = "" Then
            imgUrl = "/images/hero-dish.jpg"
        End If
  %>
          <div class="item">
            <img src="<%=ROOT%><%=imgUrl%>" alt="<%=Server.HTMLEncode(rs("ItemName"))%>" />
            <div class="body">
              <div class="row">
                <p class="name"><%=Server.HTMLEncode(rs("ItemName"))%></p>
                <div class="price"><%=FormatVND(rs("Price"))%></div>
              </div>
              <p class="desc"><%=Server.HTMLEncode("" & rs("ItemDesc"))%></p>
            </div>
          </div>
  <%
        rs.MoveNext
      Loop
  %>
        </div>
      </div>
  <%
    End If

    rs.Close
    Set rs = Nothing
  %>

</div>

<!--#include file="includes/footer.asp" -->
