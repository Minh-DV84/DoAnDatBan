<%
<!--#include file="_auth.asp" -->

Response.CodePage = 65001
Response.Charset  = "utf-8"

Const ROOT = "/DoAnDatBan"

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
    <title>Admin Login - DoAnDatBan</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        body{
            margin:0;
            font-family: Arial, Helvetica, sans-serif;
            background:#f6f6f6;
            color:#333;
        }
        .wrap{
            max-width: 980px;
            margin: 0 auto;
            padding: 20px;
        }
        .topbar{
            display:flex;
            justify-content: space-between;
            align-items:center;
            margin-bottom: 18px;
        }
        .brand a{
            text-decoration:none;
            color:#111;
            font-weight:700;
            font-size: 20px;
        }
        .brand small{
            color:#666;
            font-weight: normal;
            margin-left: 8px;
        }
        .card{
            max-width: 420px;
            margin: 40px auto 0 auto;
            background:#fff;
            border:1px solid #eee;
            border-radius: 12px;
            padding: 18px;
            box-shadow: 0 10px 22px rgba(0,0,0,0.06);
        }
        h1{
            margin: 0 0 10px 0;
            font-size: 22px;
        }
        .desc{
            color:#666;
            font-size: 13px;
            margin-bottom: 14px;
        }
        .alert{
            background:#fff1f1;
            border:1px solid #ffd0d0;
            color:#8f1d1d;
            padding:10px 12px;
            border-radius: 10px;
            margin-bottom: 12px;
        }
        label{
            display:block;
            font-weight: 600;
            margin: 10px 0 6px 0;
        }
        input{
            width:100%;
            box-sizing: border-box;
            padding: 10px 12px;
            border:1px solid #ddd;
            border-radius: 10px;
            font-size: 14px;
            outline:none;
        }
        input:focus{ border-color:#999; }

        .actions{
            display:flex;
            gap:10px;
            align-items:center;
            margin-top: 14px;
        }
        .btn{
            display:inline-block;
            padding: 10px 14px;
            border-radius: 10px;
            border: 1px solid transparent;
            font-weight: 700;
            cursor:pointer;
            text-decoration:none;
            font-size: 14px;
        }
        .btn-primary{
            background:#e63946;
            color:#fff;
        }
        .btn-primary:hover{ background:#c92f3c; }
        .btn-secondary{
            background:#f2f2f2;
            color:#333;
            border-color:#e1e1e1;
        }
        .footer{
            text-align:center;
            color:#888;
            font-size: 13px;
            margin-top: 18px;
        }
    </style>
</head>

<body>
<div class="wrap">
    <div class="topbar">
        <div class="brand">
            <a href="<%=ROOT%>/index.asp">🍽 DoAnDatBan</a>
            <small>Admin</small>
        </div>
        <div>
            <a class="btn btn-secondary" href="<%=ROOT%>/index.asp">Về trang chủ</a>
        </div>
    </div>

    <div class="card">
        <h1>Đăng nhập quản trị</h1>
        <div class="desc">Chỉ dành cho quản trị viên.</div>

        <% If msg <> "" Then %>
            <div class="alert"><%= Server.HTMLEncode(msg) %></div>
        <% End If %>

        <form action="<%=ROOT%>/admin/login_submit.asp" method="post" autocomplete="off">
            <label>Tài khoản</label>
            <input type="text" name="username" value="<%= Server.HTMLEncode(u) %>" required>

            <label>Mật khẩu</label>
            <input type="password" name="password" value="" required>

            <div class="actions">
                <button class="btn btn-primary" type="submit">Đăng nhập</button>
                <a class="btn btn-secondary" href="<%=ROOT%>/datban.asp">Trang đặt bàn</a>
            </div>
        </form>

        <div class="footer">
            © <%=Year(Date())%> DoAnDatBan
        </div>
    </div>
</div>
</body>
</html>
