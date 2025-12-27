<%
Response.CodePage = 65001
Response.Charset = "utf-8"
%>

<%
Dim ROOT
ROOT = "/DoAnDatBan"
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
            background: #f7f7f7;
            color: #333;
        }

        .container {
            max-width: 1100px;
            margin: auto;
            padding: 0 15px;
        }

        /* ===== HEADER ===== */
        .site-header {
            background: #222;
            color: #fff;
        }

        .site-header .container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            height: 64px;
        }

        .logo a {
            color: #fff;
            font-size: 22px;
            font-weight: bold;
            text-decoration: none;
        }

        .main-nav a {
            color: #ddd;
            text-decoration: none;
            margin-left: 20px;
            font-size: 15px;
        }

        .main-nav a:hover {
            color: #fff;
            text-decoration: underline;
        }

        .btn-primary {
            background: #e63946;
            color: #fff !important;
            padding: 8px 14px;
            border-radius: 4px;
        }

        .btn-primary:hover {
            background: #c92f3c;
            text-decoration: none;
        }

        /* ===== MAIN ===== */
        main {
            background: #fff;
            min-height: 70vh;
            padding: 25px 0;
        }
    </style>
</head>
<body>

<header class="site-header">
    <div class="container">
        <div class="logo">
            <a href="<%=ROOT%>/index.asp">🍽 DoAnDatBan</a>
        </div>

        <nav class="main-nav">
            <a href="<%=ROOT%>/index.asp">Trang chủ</a>
            <a href="<%=ROOT%>/datban.asp" class="btn-primary">Đặt bàn</a>
            <a href="<%=ROOT%>/admin/login.asp">Admin</a>
        </nav>
    </div>
</header>

<main>
    <div class="container">
