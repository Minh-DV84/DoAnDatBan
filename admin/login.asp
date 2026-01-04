
<!--#include file="../includes/config.asp" -->
<%
Response.CodePage = 65001
Response.Charset  = "utf-8"


Dim err, msg
err = LCase(Trim(Request.QueryString("err") & ""))
msg = ""

Select Case err
    Case "required"
        msg = "Vui lòng nhập đầy đủ tài khoản và mật khẩu."
    Case "invalid"
        msg = "Sai tài khoản hoặc mật khẩu."
    Case "locked"
        msg = "Tài khoản đã bị khóa."
    Case "logout"
        msg = "Bạn đã đăng xuất."
    Case "need_login"
        msg = "Vui lòng đăng nhập để vào trang quản trị."
End Select

Dim u
u = Trim(Request.QueryString("u") & "")
%>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <title>Admin Login - Nhà hàng Lửa &amp; Lá</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <style>
    :root{
      --bg1:#0b1220;
      --bg2:#121b2f;
      --text:rgba(255,255,255,.92);
      --muted:rgba(255,255,255,.70);
      --border:rgba(255,255,255,.14);
      --shadow: 0 22px 70px rgba(0,0,0,.28);
      --accent:#ffb703;
      --accent2:#fb8500;
      --danger:#e63946;
      --radius:18px;
      --radius2:14px;
    }

    *{ box-sizing:border-box; }
    body{
      margin:0;
      font-family: Arial, Helvetica, sans-serif;
      color: var(--text);
      background:
        radial-gradient(900px 420px at 20% 0%, rgba(255,183,3,.12), transparent 60%),
        radial-gradient(900px 520px at 85% 15%, rgba(56,189,248,.10), transparent 55%),
        linear-gradient(180deg, var(--bg2), var(--bg1));
      min-height: 100vh;
    }

    .wrap{
      max-width: 1080px;
      margin: 0 auto;
      padding: 22px 16px 64px;
    }

    .topbar{
      display:flex;
      justify-content: space-between;
      align-items:center;
      gap: 12px;
      padding: 14px 14px;
      border-radius: var(--radius);
      border:1px solid var(--border);
      background: rgba(255,255,255,.06);
      box-shadow: 0 14px 40px rgba(0,0,0,.18);
    }

    .brand{
      display:flex;
      align-items:center;
      gap: 12px;
      min-width: 240px;
    }

    .mark{
      width:40px; height:40px;
      border-radius: 14px;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      background: rgba(255,183,3,.16);
      border: 1px solid rgba(255,183,3,.32);
      flex: 0 0 auto;
    }

    .brand a{
      text-decoration:none;
      color:#fff;
      font-weight: 900;
      font-size: 18px;
      letter-spacing: -.01em;
    }
    .brand small{
      display:block;
      color: var(--muted);
      font-weight: 600;
      margin-top: 2px;
      font-size: 12.5px;
    }

    .btn{
      display:inline-flex;
      align-items:center;
      justify-content:center;
      gap: 10px;
      padding: 10px 14px;
      border-radius: 999px;
      border: 1px solid var(--border);
      text-decoration:none;
      font-weight: 900;
      font-size: 14px;
      color: var(--text);
      background: rgba(255,255,255,.06);
      transition: transform .15s ease, opacity .15s ease, box-shadow .15s ease;
      cursor:pointer;
      white-space: nowrap;
    }
    .btn:hover{ transform: translateY(-1px); opacity:.96; }

    .btn-primary{
      background: linear-gradient(90deg, var(--accent), var(--accent2));
      color:#111;
      border-color: rgba(255,255,255,.16);
      box-shadow: 0 12px 28px rgba(251,133,0,.22);
    }

    .btn-ghost{
      background: rgba(255,255,255,.06);
      color: rgba(255,255,255,.88);
    }

    .card{
      max-width: 520px;
      margin: 22px auto 0 auto;
      border-radius: 22px;
      border: 1px solid var(--border);
      background:
        linear-gradient(180deg, rgba(255,255,255,.10), rgba(255,255,255,.06));
      box-shadow: var(--shadow);
      overflow:hidden;
    }

    .card-inner{
      padding: 18px;
    }

    .title{
      margin: 0;
      font-size: 24px;
      letter-spacing: -.02em;
      color:#fff;
    }
    .desc{
      margin: 8px 0 14px 0;
      color: var(--muted);
      font-size: 13.5px;
      line-height: 1.6;
    }

    .alert{
      background: rgba(230,57,70,.12);
      border:1px solid rgba(230,57,70,.30);
      color:#ffd5d5;
      padding:10px 12px;
      border-radius: 14px;
      margin-bottom: 12px;
      font-weight: 800;
    }

    label{
      display:block;
      font-weight: 900;
      margin: 10px 0 6px 0;
      color: rgba(255,255,255,.90);
    }

    input{
      width:100%;
      padding: 11px 12px;
      border: 1px solid rgba(255,255,255,.18);
      border-radius: 14px;
      font-size: 14px;
      outline:none;
      background: rgba(10,16,28,.55);
      color: rgba(255,255,255,.92);
      transition: box-shadow .15s ease, border-color .15s ease;
    }

    input::placeholder{ color: rgba(255,255,255,.55); }
    input:focus{
      border-color: rgba(251,133,0,.55);
      box-shadow: 0 0 0 4px rgba(255,183,3,.18);
    }

    .actions{
      display:flex;
      gap:10px;
      align-items:center;
      margin-top: 14px;
      flex-wrap: wrap;
    }

    .footer{
      text-align:center;
      color: rgba(255,255,255,.68);
      font-size: 13px;
      padding: 12px 0 16px;
      border-top: 1px solid rgba(255,255,255,.10);
    }

    @media (max-width: 640px){
      .topbar{ flex-wrap: wrap; justify-content: center; text-align:center; }
      .brand{ justify-content:center; }
      .card{ max-width: 100%; }
    }
  </style>
</head>

<body>
  <div class="wrap">

    <div class="topbar">
      <div class="brand">
        <span class="mark" aria-hidden="true">
          <!-- cloche icon -->
          <svg viewBox="0 0 24 24" width="22" height="22" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M8 6c0-2.2 1.8-4 4-4s4 1.8 4 4" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
            <path d="M6 11a6 6 0 1 1 12 0" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
            <path d="M4 13h16" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
            <path d="M5 16h14" stroke="#ffb703" stroke-width="2" stroke-linecap="round" opacity=".9"/>
            <path d="M7 19h10" stroke="#ffb703" stroke-width="2" stroke-linecap="round" opacity=".75"/>
          </svg>
        </span>
        <div>
          <a href="<%=ROOT%>/index.asp">Nhà hàng Lửa &amp; Lá</a>
          <small>Quản trị hệ thống</small>
        </div>
      </div>

      <div style="display:flex; gap:10px; flex-wrap:wrap;">
        <a class="btn btn-primary" href="<%=ROOT%>/datban.asp">👉 Trang đặt bàn</a>
      </div>
    </div>

    <div class="card">
      <div class="card-inner">
        <h1 class="title">Đăng nhập Admin</h1>
        <div class="desc">Chỉ dành cho quản trị viên. Vui lòng nhập đúng tài khoản và mật khẩu.</div>

        <% If msg <> "" Then %>
          <div class="alert"><%= Server.HTMLEncode(msg) %></div>
        <% End If %>

        <form action="<%=ROOT%>/admin/login_submit.asp" method="post" autocomplete="off">
          <label>Tài khoản</label>
          <input type="text" name="username" value="<%= Server.HTMLEncode(u) %>" required placeholder="Nhập tài khoản">

          <label>Mật khẩu</label>
          <input type="password" name="password" value="" required placeholder="Nhập mật khẩu">

          <div class="actions">
            <button class="btn btn-primary" type="submit">Đăng nhập</button>
          </div>
        </form>
      </div>

      <div class="footer">
        © <%=Year(Date())%> Nhà hàng Lửa &amp; Lá • Powered by DoAnDatBan
      </div>
    </div>

  </div>
</body>
</html>