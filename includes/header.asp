<%
Response.CodePage = 65001
Response.Charset = "utf-8"
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <title>Đặt bàn nhà hàng</title>

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #0b1220;
            color: #eaeaea;
        }

        .container {
            max-width: 1100px;
            margin: auto;
            padding: 0 15px;
        }

        /* ===== HEADER ===== */
        .site-header {
            background: #1f1f1f;
            color: #fff;
            border-bottom: 1px solid rgba(255,255,255,.08);
        }

        .site-header .container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            height: 72px;
            gap: 16px;
        }

        .logo a {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            color: #fff;
            font-size: 20px;
            font-weight: 900;
            text-decoration: none;
            letter-spacing: -0.01em;
        }

        .brand-mark{
            width: 40px;
            height: 40px;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: rgba(255,183,3,.12);
            border: 1px solid rgba(255,183,3,.25);
        }
        .brand-mark svg{
            width: 22px;
            height: 22px;
        }

        .brand-sub{
            display:block;
            font-size: 12px;
            font-weight: 600;
            color: rgba(255,255,255,.65);
            margin-top: 2px;
            letter-spacing: 0;
        }

        .main-nav{
            display:flex;
            align-items:center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .main-nav a {
            color: rgba(255,255,255,.82);
            text-decoration: none;
            font-size: 15px;
            font-weight: 700;
            padding: 8px 10px;
            border-radius: 10px;
            transition: background .15s ease, transform .15s ease, opacity .15s ease;
        }

        .main-nav a:hover {
            background: rgba(255,255,255,.06);
            opacity: 1;
            transform: translateY(-1px);
        }

        .btn-primary {
            background: linear-gradient(90deg,#ffb703,#fb8500);
            color: #111 !important;
            padding: 10px 14px !important;
            border-radius: 10px;
            font-weight: 900 !important;
            border: 1px solid rgba(255,255,255,.12);
        }

        .btn-primary:hover {
            background: linear-gradient(90deg,#ffd166,#fb8500);
            text-decoration: none;
        }

        /* ===== MAIN ===== */
        main {
            background: transparent;
            min-height: 70vh;
            padding: 25px 0;
        }

        /* Mobile */
        @media (max-width: 720px){
            .site-header .container{ height: auto; padding: 12px 15px; }
            .main-nav{ gap: 10px; }
            .main-nav a{ padding: 8px 9px; }
        }
    </style>
</head>
<body>

<header class="site-header">
    <div class="container">
        <div class="logo">
            <a href="<%=ROOT%>/index.asp">
                <span class="brand-mark" aria-hidden="true">
                    <!-- Icon cloche (nhà hàng) -->
                    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M8 6c0-2.2 1.8-4 4-4s4 1.8 4 4" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
                        <path d="M6 11a6 6 0 1 1 12 0" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
                        <path d="M4 13h16" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
                        <path d="M5 16h14" stroke="#ffb703" stroke-width="2" stroke-linecap="round" opacity=".9"/>
                        <path d="M7 19h10" stroke="#ffb703" stroke-width="2" stroke-linecap="round" opacity=".75"/>
                    </svg>
                </span>

                <span>
                    Nhà hàng Lửa &amp; Lá
                    <span class="brand-sub">Đặt bàn trực tuyến</span>
                </span>
            </a>
        </div>

        <nav class="main-nav">
            <a href="<%=ROOT%>/index.asp">Giới thiệu</a>
            <a href="<%=ROOT%>/thucdon.asp">Thực đơn</a>
            <a href="<%=ROOT%>/datban.asp" class="btn-primary">Đặt bàn</a>
    <% If Len(Trim(Session("AdminId") & "")) > 0 Then %>
  <a href="<%=ROOT%>/admin/reservations.asp">Admin</a>
<% End If %>

        </nav>
    </div>
</header>

<main>
    <div class="container">
