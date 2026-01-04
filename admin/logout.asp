<%
Response.CodePage = 65001
Response.Charset  = "utf-8"

' Xóa các session liên quan admin
Session("AdminId") = Empty
Session("AdminUsername") = Empty
Session("AdminFullName") = Empty

' Xóa toàn bộ session
Session.Contents.RemoveAll
Session.Abandon

' Chống cache để tránh bấm Back vẫn thấy trang admin
Response.Expires = -1
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"

' Về trang login
Response.Redirect "/DoAnDatBan/index.asp"
Response.End
%>
