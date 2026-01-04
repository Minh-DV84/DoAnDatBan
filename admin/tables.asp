<%
Response.CodePage = 65001
Response.Charset  = "utf-8"
%>
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

' Load areas for dropdown
Dim rsAreas
Set rsAreas = conn.Execute("SELECT AreaId, AreaName FROM dbo.Areas WHERE IsActive=1 ORDER BY Priority ASC, AreaId ASC")

' Load list tables (with AreaName)
Dim rsList
Set rsList = conn.Execute( _
  "SELECT t.TableId, t.TableName, t.Capacity, t.AreaId, t.IsActive, t.Notes, a.AreaName " & _
  "FROM dbo.DiningTables t " & _
  "LEFT JOIN dbo.Areas a ON a.AreaId=t.AreaId " & _
  "ORDER BY a.Priority ASC, t.Capacity ASC, t.TableId ASC" _
)

' Load edit row if needed
Dim tCode, tName, tCap, tAreaId, tActive, tNotes
tCode="" : tName="" : tCap=2 : tAreaId=0 : tActive=1 : tNotes=""

If isEdit Then
  Dim cmdE, rsE
  Set cmdE = Server.CreateObject("ADODB.Command")
  Set cmdE.ActiveConnection = conn
  cmdE.CommandType = 1
  cmdE.CommandText = "SELECT TOP 1 TableId, TableCode, TableName, Capacity, AreaId, IsActive, Notes FROM dbo.DiningTables WHERE TableId=?;"
  cmdE.Parameters.Append cmdE.CreateParameter("@id", 3, 1, , editId)
  Set rsE = cmdE.Execute
  If Not rsE.EOF Then
    tCode = rsE("TableCode") & ""
    tName = rsE("TableName") & ""
    tCap = CLng(rsE("Capacity"))
    If Not IsNull(rsE("AreaId")) Then tAreaId = CLng(rsE("AreaId")) Else tAreaId = 0 End If
    tActive = IIf(rsE("IsActive")=True, 1, 0)
    tNotes = rsE("Notes") & ""
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
<title>Admin - Quản lý Bàn</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#f6f6f6}
  .wrap{max-width:1100px;margin:0 auto;padding:18px}
  .top{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px}
  .card{background:#fff;border:1px solid #eee;border-radius:14px;box-shadow:0 10px 22px rgba(0,0,0,.06);padding:14px}
  table{width:100%;border-collapse:collapse}
  th,td{padding:10px;border-bottom:1px solid #eee;text-align:left;vertical-align:top}
  th{background:#fafafa;font-size:13px;color:#555}
  input,select,textarea{padding:10px 12px;border:1px solid #ddd;border-radius:10px;width:100%}
  textarea{min-height:90px}
  .grid{display:grid;grid-template-columns:1.2fr .8fr;gap:14px}
  @media(max-width:900px){.grid{grid-template-columns:1fr}}
  .btn{display:inline-block;padding:10px 12px;border-radius:10px;background:#111;color:#fff;text-decoration:none;font-weight:700;border:0;cursor:pointer}
  .btn.gray{background:#888}
  .msg{background:#f0f8ff;border:1px solid #d7ecff;border-radius:12px;padding:10px 12px;margin-bottom:12px}
  .muted{color:#777;font-size:12px}
</style>
</head>
<body>
<div class="wrap">
  <div class="top">
    <div>
  <a href="<%=ROOT%>/admin/reservations.asp" style="text-decoration:none;font-weight:900;color:#111;">
    Nhà hàng Lửa &amp; Lá
  </a>
  / <a href="<%=ROOT%>/admin/reservations.asp" style="text-decoration:none;color:#111;">Admin</a>
  / <a href="<%=ROOT%>/admin/reservations.asp">Đơn</a>
  / <b>Bàn</b>
</div>

    <div>
      <a class="btn gray" href="<%=ROOT%>/admin/areas.asp">Quản lý Khu</a>
      <a class="btn" href="<%=ROOT%>/admin/logout.asp">Đăng xuất</a>
    </div>
  </div>

  <% If msg<>"" Then %>
    <div class="msg"><%=HE(msg)%></div>
  <% End If %>

  <div class="grid">
    <div class="card">
      <h3 style="margin:0 0 10px 0;">Danh sách Bàn</h3>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Tên bàn</th>
            <th>Capacity</th>
            <th>Khu</th>
            <th>Active</th>
            <th>Notes</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
        <%
          If rsList.EOF Then
        %>
          <tr><td colspan="7" class="muted">Chưa có bàn.</td></tr>
        <%
          Else
            Do While Not rsList.EOF
              Dim id, nm, cap, an, ac, notes
              id = CLng(rsList("TableId"))
              nm = rsList("TableName") & ""
              cap = rsList("Capacity")
              an = rsList("AreaName") & ""
              ac = rsList("IsActive")
              notes = rsList("Notes") & ""
        %>
          <tr>
            <td><%=id%></td>
            <td><b><%=HE(nm)%></b></td>
            <td><%=HE(cap)%></td>
            <td><%=HE(an)%></td>
            <td><%=IIf(ac=True,"1","0")%></td>
            <td class="muted"><%=HE(notes)%></td>
            <td><a class="btn gray" href="<%=ROOT%>/admin/tables.asp?id=<%=id%>">Sửa</a></td>
          </tr>
        <%
              rsList.MoveNext
            Loop
          End If
          rsList.Close : Set rsList = Nothing
        %>
        </tbody>
      </table>
      <div class="muted" style="margin-top:8px;">Auto-assign sẽ chọn bàn Capacity nhỏ nhất nhưng đủ chỗ, ưu tiên khu Priority thấp.</div>
    </div>

    <div class="card">
      <h3 style="margin:0 0 10px 0;"><%=IIf(isEdit,"Sửa Bàn","Thêm Bàn")%></h3>
      
      <form method="post" action="<%=ROOT%>/admin/table_save.asp">
        <input type="hidden" name="TableId" value="<%=editId%>">

        <div class="muted">Mã bàn</div>
        <input name="TableCode" value="<%=HE(tCode)%>" placeholder="Bàn 2 người" required>
        <div style="height:10px"></div>

        <div class="muted">Tên bàn</div>
        <input name="TableName" value="<%=HE(tName)%>" placeholder="Bàn 2 người" required>

        <div style="height:10px"></div>

        <div class="muted">Capacity</div>
        <input name="Capacity" type="number" value="<%=HE(tCap)%>" min="1" max="50" required>

        <div style="height:10px"></div>

        <div class="muted">Khu</div>
        <select name="AreaId" required>
          <option value="">-- Chọn khu --</option>
          <%
            ' rsAreas đã đọc một lần thì phải reset lại -> easiest: reopen query
            rsAreas.Close : Set rsAreas = Nothing
            Set rsAreas = conn.Execute("SELECT AreaId, AreaName FROM dbo.Areas WHERE IsActive=1 ORDER BY Priority ASC, AreaId ASC")
            Do While Not rsAreas.EOF
              Dim aid, aname
              aid = CLng(rsAreas("AreaId"))
              aname = rsAreas("AreaName") & ""
          %>
            <option value="<%=aid%>" <% If tAreaId=aid Then Response.Write "selected" %> ><%=HE(aname)%></option>
          <%
              rsAreas.MoveNext
            Loop
            rsAreas.Close : Set rsAreas = Nothing
          %>
        </select>

        <div style="height:10px"></div>

        <div class="muted">Active</div>
        <select name="IsActive">
          <option value="1" <% If tActive=1 Then Response.Write "selected" %> >1</option>
          <option value="0" <% If tActive=0 Then Response.Write "selected" %> >0</option>
        </select>

        <div style="height:10px"></div>

        <div class="muted">Notes</div>
        <textarea name="Notes"><%=HE(tNotes)%></textarea>

        <div style="height:12px"></div>
        <button class="btn" type="submit">Lưu</button>
        <a class="btn gray" href="<%=ROOT%>/admin/tables.asp">Reset</a>
      </form>
    </div>
  </div>
</div>
</body>
</html>

<%
conn.Close : Set conn = Nothing
Function IIf(cond, t, f)
  If cond Then IIf=t Else IIf=f End If
End Function
%>
