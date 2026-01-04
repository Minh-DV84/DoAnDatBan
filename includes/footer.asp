</div>
</main>

<footer style="background:#1b1b1b; color:#e6e6e6; padding:28px 0; margin-top:48px; border-top:1px solid rgba(255,255,255,.12);">
  <div class="container" style="max-width:1080px; margin:0 auto; padding:0 16px;">

    <div style="display:flex; gap:18px; align-items:flex-start; justify-content:space-between; flex-wrap:wrap;">

      <!-- Brand -->
      <div style="min-width:240px;">
        <div style="display:flex; align-items:center; gap:10px; margin-bottom:10px;">
          <span style="width:40px; height:40px; border-radius:14px; display:inline-flex; align-items:center; justify-content:center;
                       background: rgba(255,183,3,.16); border:1px solid rgba(255,183,3,.32);">
            <!-- Restaurant cloche icon (SVG) -->
            <svg viewBox="0 0 24 24" width="22" height="22" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M8 6c0-2.2 1.8-4 4-4s4 1.8 4 4" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
              <path d="M6 11a6 6 0 1 1 12 0" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
              <path d="M4 13h16" stroke="#ffb703" stroke-width="2" stroke-linecap="round"/>
              <path d="M5 16h14" stroke="#ffb703" stroke-width="2" stroke-linecap="round" opacity=".9"/>
              <path d="M7 19h10" stroke="#ffb703" stroke-width="2" stroke-linecap="round" opacity=".75"/>
            </svg>
          </span>

          <div>
            <div style="font-weight:900; font-size:16px; letter-spacing:-.01em; color:#ffffff;">
              Nhà hàng Lửa &amp; Lá
            </div>
            <div style="font-size:13px; color:rgba(255,255,255,.78); margin-top:2px;">
              Đặt bàn nhanh • Phục vụ tận tâm
            </div>
          </div>
        </div>

        <div style="font-size:13.5px; line-height:1.65; color:rgba(255,255,255,.80);">
          Không gian ấm cúng, món ăn chuẩn vị. Đặt bàn trước để giữ chỗ giờ cao điểm.
        </div>
      </div>

      <!-- Info -->
      <div style="display:flex; gap:30px; flex-wrap:wrap;">
        <div style="min-width:220px;">
          <div style="font-weight:900; color:#ffffff; margin-bottom:10px;">Thông tin</div>
          <div style="font-size:13.5px; line-height:1.85; color:rgba(255,255,255,.82);">
            📞 Hotline: <span style="color:#ffffff; font-weight:900;">0123 456 789</span><br/>
            ⏰ Giờ mở cửa: 10:00 – 22:00<br/>
            📍 Địa chỉ: 123 Đường ABC, Quận 1
          </div>
        </div>

        <div style="min-width:220px;">
          <div style="font-weight:900; color:#ffffff; margin-bottom:10px;">Liên kết nhanh</div>
          <div style="font-size:13.5px; line-height:1.9;">
            <a href="<%=ROOT%>/index.asp" style="color:rgba(255,255,255,.82); text-decoration:none;">Trang chủ</a><br/>
            <a href="<%=ROOT%>/datban.asp" style="color:#ffb703; text-decoration:none; font-weight:900;">👉 Đặt bàn</a><br/>
            <a href="<%=ROOT%>/thucdon.asp" style="color:rgba(255,255,255,.82); text-decoration:none;">Thực đơn</a>
          </div>
        </div>
      </div>

    </div>

    <!-- Bottom line -->
    <div style="margin-top:18px; padding-top:14px; border-top:1px solid rgba(255,255,255,.12);
                display:flex; justify-content:space-between; gap:10px; flex-wrap:wrap; font-size:13px; color:rgba(255,255,255,.72);">
      <div>© <%=Year(Date())%> Nhà hàng Lửa &amp; Lá. All rights reserved.</div>
      <div style="color:rgba(255,255,255,.78);">Powered by DoAnDatBan</div>
    </div>

  </div>
</footer>

</body>
</html>
