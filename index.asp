<!--#include file="includes/header.asp" -->
<!--#include file="includes/config.asp" -->

<style>
  :root{
  --bg: #eef2f7;             /* nền sáng */
  --card: rgba(255,255,255,.78);
  --card2: rgba(255,255,255,.70);
  --text: #0f172a;           /* chữ đậm */
  --muted: #475569;          /* chữ phụ */
  --border: rgba(15,23,42,.12);
  --accent: #ffb703;
  --accent2: #fb8500;
  --shadow: 0 18px 60px rgba(2,6,23,.12);
  --radius: 18px;
  --radius2: 14px;
}

  body{ background: var(--bg); }

  .home-wrap{
    max-width: 1080px;
    margin: 0 auto;
    padding: 26px 16px 64px;
    color: var(--text);
  }

  .home-hero{
  position: relative;
  overflow: hidden;
  border-radius: var(--radius);
  border: 1px solid var(--border);
  box-shadow: var(--shadow);
  background: url("<%=ROOT%>/images/hero.jpg") center/cover no-repeat;
}

/* Lớp phủ làm sáng ảnh nền để chữ dễ đọc */
.home-hero::before{
  content:"";
  position:absolute;
  inset:0;
  background: linear-gradient(120deg, rgba(255,255,255,.92), rgba(255,255,255,.62));
}

.home-hero__inner{
  position: relative; /* để nằm trên overlay */
}


  .home-hero__inner{
    display: grid;
    grid-template-columns: 1.35fr .85fr;
    gap: 18px;
    padding: 34px;
    align-items: center;
  }

  .home-title{
    font-size: clamp(26px, 3.2vw, 42px);
    line-height: 1.1;
    margin: 0 0 10px;
    letter-spacing: -0.02em;
  }

  .home-sub{
    margin: 0 0 18px;
    max-width: 56ch;
    color: var(--muted);
    font-size: 15.5px;
    line-height: 1.6;
  }

  .home-actions{
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    align-items: center;
    margin-top: 6px;
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
    font-weight: 700;
    letter-spacing: .01em;
    transition: transform .15s ease, background .15s ease, border-color .15s ease, opacity .15s ease;
  }
  .btn:hover{ transform: translateY(-1px); }
  .btn:active{ transform: translateY(0px); opacity: .92; }

  .btn-primary{
    background: linear-gradient(90deg, var(--accent), var(--accent2));
    border-color: rgba(255,255,255,.18);
    color: #111;
    box-shadow: 0 10px 28px rgba(251,133,0,.25);
  }
  .btn-ghost{ background: rgba(255,255,255,.06); }

  .hero-card{
    background: rgba(255,255,255,.06);
    border: 1px solid var(--border);
    border-radius: var(--radius2);
    padding: 14px;
    backdrop-filter: blur(6px);
  }
  .hero-card img{
    width: 100%;
    height: 220px;
    object-fit: cover;
    border-radius: 12px;
    border: 1px solid rgba(255,255,255,.12);
    display: block;
  }
  .hero-card .caption{
    margin-top: 10px;
    color: var(--muted);
    font-size: 13.5px;
    line-height: 1.5;
  }

  .section{ margin-top: 18px; }
  .section-title{
    margin: 22px 0 10px;
    font-size: 18px;
    letter-spacing: -0.01em;
  }

  .cards{
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
  }
  .card{
    background: var(--card2);
    border: 1px solid var(--border);
    border-radius: var(--radius2);
    padding: 14px 14px 16px;
    box-shadow: 0 10px 34px rgba(0,0,0,.18);
  }
  .card h3{ margin: 6px 0 8px; font-size: 15.5px; }
  .card p{ margin: 0; color: var(--muted); line-height: 1.55; font-size: 14px; }

  .icon-badge{
    width: 40px; height: 40px;
    border-radius: 12px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background: rgba(255,183,3,.14);
    border: 1px solid rgba(255,183,3,.25);
    font-weight: 900;
    color: var(--accent);
  }

  .steps{
    display: grid;
    grid-template-columns: 1.15fr .85fr;
    gap: 14px;
    align-items: stretch;
  }

  .step-list{ display: grid; gap: 10px; }
  .step{
    display: grid;
    grid-template-columns: 42px 1fr;
    gap: 10px;
    align-items: start;
    background: rgba(255,255,255,.06);
    border: 1px solid var(--border);
    border-radius: var(--radius2);
    padding: 12px;
  }
  .step .num{
    width: 42px; height: 42px;
    border-radius: 14px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background: rgba(255,255,255,.08);
    border: 1px solid rgba(255,255,255,.14);
    font-weight: 900;
  }
  .step h4{ margin: 2px 0 4px; font-size: 15px; }
  .step p{ margin: 0; color: var(--muted); font-size: 13.8px; line-height: 1.55; }

  .side-photo{
    background: rgba(255,255,255,.06);
    border: 1px solid var(--border);
    border-radius: var(--radius2);
    padding: 12px;
    height: 100%;
  }
  .side-photo img{
    width: 100%;
    height: 100%;
    min-height: 230px;
    object-fit: cover;
    border-radius: 12px;
    border: 1px solid rgba(255,255,255,.12);
    display: block;
  }

  .cta{
    margin-top: 16px;
    border-radius: var(--radius);
    border: 1px solid var(--border);
    background: linear-gradient(120deg, rgba(255,183,3,.18), rgba(255,255,255,.05));
    padding: 18px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 14px;
  }
  .cta strong{ display: block; font-size: 16px; margin-bottom: 4px; }
  .cta span{ color: var(--muted); font-size: 13.8px; line-height: 1.5; }

  .gallery{
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
  }
  .gallery img{
    width: 100%;
    height: 160px;
    object-fit: cover;
    border-radius: 14px;
    border: 1px solid var(--border);
    box-shadow: 0 10px 26px rgba(0,0,0,.2);
  }

  @media (max-width: 900px){
    .home-hero__inner{ grid-template-columns: 1fr; padding: 22px; }
    .cards{ grid-template-columns: 1fr; }
    .steps{ grid-template-columns: 1fr; }
    .gallery{ grid-template-columns: 1fr; }
    .hero-card img{ height: 200px; }
    .cta{ flex-direction: column; align-items: flex-start; }
  }
</style>

<div class="home-wrap">

  <section class="home-hero">
    <div class="home-hero__inner">
      <div>
        <h1 class="home-title">Đặt bàn nhanh – giữ chỗ chắc, không cần gọi điện</h1>
        <p class="home-sub">
          Chọn ngày/giờ, số lượng khách và ghi chú yêu cầu. Hệ thống giúp bạn đặt bàn gọn gàng và rõ ràng.
        </p>

        <div class="home-actions">
          <a class="btn btn-primary" href="<%=ROOT%>/datban.asp">👉 Đặt bàn ngay</a>
          <a class="btn btn-ghost" href="<%=ROOT%>/thucdon.asp">🍽️ Xem thực đơn</a>
        </div>
      </div>

      <div class="hero-card">
        <img src="<%=ROOT%>/images/hero-dish.jpg" alt="Món ăn nổi bật" />
        <div class="caption">Món signature / combo đề xuất hôm nay.</div>
      </div>
    </div>
  </section>

  <section class="section">
    <div class="section-title">Vì sao nên đặt bàn online?</div>

    <div class="cards">
      <div class="card">
        <div class="icon-badge">⚡</div>
        <h3>Nhanh & đơn giản</h3>
    
<!--#include file="includes/footer.asp" -->
     