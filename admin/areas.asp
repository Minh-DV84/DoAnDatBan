<%
Response.CodePage = 65001
Response.Charset  = "utf-8"
%>
<!--#include file="../includes/config.asp" -->
<!--#include file="_auth.asp" -->
<!--#include file="../includes/connect.asp" -->
<%
Function HE(x): HE = Server.HTMLEncode(x & ""): End Function

Dim editId, isEdit
editId = 0 : isEdit = False
If IsNumeric(Request.QueryString("id") & "") Then
  editId = CLng(Request.QueryString("id"))
  If editId > 0 Then isEdit = True
End If

' Load list areas
Dim rsList
Set rsList = conn.Execute("SELECT AreaId, AreaName, Priority, IsActive FROM dbo.Areas ORDER BY Priority ASC, AreaId ASC")

' Load edit row if needed
Dim aName, aPriority, aActive
aName = "" : aPriority = 1 : aActive = 1

If isEdit Then
  Dim cmdE, rsE
  Set cmdE = Server.CreateObject("ADODB.Command")
  Set cmdE.ActiveConnection = conn
  cmdE.CommandType = 1
  cmdE.CommandText = "SELECT TOP 1 AreaId, AreaName, Priority, IsActive FROM dbo.Areas WHERE AreaId=?;"
  cmdE.Parameters.Append cmdE.CreateParameter("@id", 3, 1, , editId)
  Set rsE = cmdE.Execute
  If Not rsE.EOF Then
    aName = rsE("AreaName") & ""
    aPriority = CLng(rsE("Priority"))
    aActive = IIf(rsE("IsActive")=True, 1, 0)
  End If
  rsE.Close : Set rsE = Nothing
  Set cmdE = Nothing
End If

Dim msg
msg = Trim(Request.QueryString("msg") & "")
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="utf-8">
<title>Admin - Quản lý Khu</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#f6f6f6}
  .wrap{max-width:1100px;margin:0 auto;padding:18px}
  .top{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px}
  a{color:#111}
  .card{background:#fff;border:1px solid #eee;border-radius:14px;box-shadow:0 10px 22px rgba(0,0,0,.06);padding:14px}
  table{width:100%;border-collapse:collapse}
  th,td{padding:10px;border-bottom:1px solid #eee;text-align:left}
  th{background:#fafafa;font-size:13px;color:#555}
  input,select{padding:10px 12px;border:1px solid #ddd;border-radius:10px;width:100%}
  .grid{display:grid;grid-template-columns:1.2fr .8fr;gap:14px}
  @media(max-width:900px){.grid{grid-template-columns:1fr}}
  .btn{display:inline-block;padding:10px 12px;border-radius:10px;background:#111;color:#fff;text-decoration:none;font-weight:700}
  .btn.gray{background:#888}
  .msg{background:#f0f8ff;border:1px solid #d7ecff;border-radius:12px;padding:10px 12px;margin-bottom:12px}
  .muted{color:#777;font-size:12px}
</style>
</head>
<body>
<div class="wrap">
  <div class="top">
    <div><b>🍽 DoAnDatBan</b> / Admin / <a href="<%=ROOT%>/admin/reservations.asp">Đơn</a> / <b>Khu</b></div>
    <div>
      <a class="btn gray" href="<%=ROOT%>/admin/tables.asp">Quản lý Bàn</a>
      <a class="btn" href="<%=ROOT%>/admin/logout.asp">Đăng xuất</a>
    </div>
  </div>

  <% If msg<>"" Then %>
    <div class="msg"><%=HE(msg)%></div>
  <% End If %>

  <div class="grid">
    <div class="card">
      <h3 style="margin:0 0 10px 0;">Danh sách Khu</h3>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Tên khu</th>
            <th>Ưu tiên</th>
            <th>Active</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
        <%
          If rsList.EOF Then
        %>
          <tr><td colspan="5" class="muted">Chưa có khu.</td></tr>
        <%
          Else
            Do While Not rsList.EOF
              Dim id, nm, pr, ac
              id = CLng(rsList("AreaId"))
              nm = rsList("AreaName") & ""
              pr = rsList("Priority")
              ac = rsList("IsActive")
        %>
          <tr>
            <td><%=id%></td>
            <td><%=HE(nm)%></td>
            <td><%=HE(pr)%></td>
            <td><%=IIf(ac=True,"1","0")%></td>
            <td>
              <a class="btn gray" href="<%=ROOT%>/admin/areas.asp?id=<%=id%>">Sửa</a>
            </td>
          </tr>
        <%
              rsList.MoveNext
            Loop
          End If
          rsList.Close : Set rsList = Nothing
        %>
        </tbody>
      </table>
      <div class="muted" style="margin-top:8px;">Priority nhỏ hơn sẽ được ưu tiên khi auto-assign bàn.</div>
    </div>

    <div class="card">
      <h3 style="margin:0 0 10px 0;"><%=IIf(isEdit,"Sửa Khu","Thêm Khu")%></h3>

      <form method="post" action="<%=ROOT%>/admin/area_save.asp">
        <input type="hidden" name="AreaId" value="<%=editId%>">

        <div class="muted">Tên khu</div>
        <input name="AreaName" value="<%=HE(aName)%>" placeholder="Khu A" required>

        <div style="height:10px"></div>

        <div class="muted">Ưu tiên (nhỏ ưu tiên trước)</div>
        <input name="Priority" type="number" value="<%=HE(aPriority)%>" min="1" max="99" required>

        <div style="height:10px"></div>

        <div class="muted">Active</div>
        <select name="IsActive">
          <option value="1" <% If aActive=1 Then Response.Write "selected" %> >1</option>
          <option value="0" <% If aActive=0 Then Response.Write "selected" %> >0</option>
        </select>

        <div style="height:12px"></div>
        <button class="btn" type="submit">Lưu</button>
        <a class="btn gray" href="<%=ROOT%>/admin/areas.asp">Reset</a>
      </form>
    </div>
  </div>
</div>
</body>
</html>

<%
conn.Close : Set conn = Nothing

' VBScript không có IIf, tự định nghĩa nhanh ở cuối file
Function IIf(cond, t, f)
  If cond Then IIf=t Else IIf=f End If
End Function
%>
