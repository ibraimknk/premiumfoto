# Çoklu Domain Sitemap Kullanım Kılavuzu

## 🎯 Özellikler

- ✅ 3 farklı domain için otomatik sitemap oluşturma
- ✅ Tüm domain'ler için tek bir sitemap.xml dosyası
- ✅ Her domain için arama motorlarına otomatik gönderim
- ✅ Admin panelinden tek tıkla gönderim

## 📝 Kurulum

### 1. Environment Variable Ayarları

`.env` dosyanıza aşağıdaki şekilde domain'lerinizi ekleyin:

#### Seçenek 1: Çoklu Domain (Önerilen)
```env
NEXT_PUBLIC_SITE_URLS=https://domain1.com,https://domain2.com,https://domain3.com
```

#### Seçenek 2: Tek Domain (Eski Yöntem)
```env
NEXT_PUBLIC_SITE_URL=https://domain1.com
```

**Not:** Eğer `NEXT_PUBLIC_SITE_URLS` tanımlıysa, o kullanılır. Yoksa `NEXT_PUBLIC_SITE_URL` kullanılır.

### 2. Domain Formatı

- Domain'ler virgülle ayrılmalı
- `http://` veya `https://` ile başlamalı (yoksa otomatik `https://` eklenir)
- Boşluklar otomatik temizlenir

**Örnek:**
```env
NEXT_PUBLIC_SITE_URLS=https://fotougur.com,https://www.fotougur.com,https://foto-ugur.com
```

## 🚀 Kullanım

### Sitemap Oluşturma

Sitemap otomatik olarak oluşturulur:
- URL: `/sitemap.xml`
- Tüm domain'ler için URL'ler tek bir sitemap'te birleştirilir
- Her domain için tüm sayfalar (statik, hizmetler, blog) dahil edilir

### Arama Motorlarına Gönderme

#### Yöntem 1: Admin Panelinden
1. `/admin/settings` sayfasına gidin
2. "SEO" sekmesine tıklayın
3. "Site Haritasını Arama Motorlarına Gönder" butonuna tıklayın
4. Her domain için sonuçları görüntüleyin

#### Yöntem 2: API Endpoint
```bash
# POST isteği (Admin session gerekli)
curl -X POST http://localhost:3000/api/sitemap-submit

# GET isteği (Token gerekli)
curl -X GET http://localhost:3000/api/sitemap-submit \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Yöntem 3: Script ile
```bash
npm run submit-sitemap
```

#### Yöntem 4: Cron Job
```bash
# Her gün saat 02:00'de otomatik gönderim
0 2 * * * cd /path/to/project && npm run submit-sitemap
```

## 📊 Sitemap Yapısı

Sitemap şu sayfaları içerir:

### Statik Sayfalar (Her domain için)
- Ana sayfa (`/`)
- Hakkımızda (`/hakkimizda`)
- Hizmetler (`/hizmetler`)
- Galeri (`/galeri`)
- Blog (`/blog`)
- İletişim (`/iletisim`)
- SSS (`/sss`)
- KVKK (`/kvkk`)
- Gizlilik Politikası (`/gizlilik-politikasi`)
- Çerez Politikası (`/cerez-politikasi`)

### Dinamik Sayfalar
- **Hizmetler**: Her aktif hizmet için (`/hizmetler/[slug]`)
- **Blog**: Her yayınlanmış blog yazısı için (`/blog/[slug]`)

## 🔍 Örnek Sitemap Çıktısı

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <!-- Domain 1 -->
  <url>
    <loc>https://domain1.com/</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://domain1.com/hizmetler/dugun-fotografciligi</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
  
  <!-- Domain 2 -->
  <url>
    <loc>https://domain2.com/</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>
  
  <!-- Domain 3 -->
  <url>
    <loc>https://domain3.com/</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

## ⚙️ Teknik Detaylar

### Dosyalar
- `lib/sitemap-utils.ts` - Domain yönetimi ve sitemap oluşturma fonksiyonları
- `app/sitemap.ts` - Next.js sitemap route'u
- `app/api/sitemap-submit/route.ts` - Arama motorlarına gönderme API'si
- `app/robots.ts` - Robots.txt oluşturma (ana domain'i kullanır)

### Fonksiyonlar
- `getAllDomains()` - Tüm domain'leri döndürür
- `getPrimaryDomain()` - Ana domain'i döndürür (ilk domain)
- `generateSitemapUrls(baseUrl)` - Belirli bir domain için sitemap URL'leri oluşturur

## 🐛 Sorun Giderme

### Sitemap boş görünüyor
- `.env` dosyasında domain'lerin doğru tanımlandığından emin olun
- Domain'lerin `http://` veya `https://` ile başladığından emin olun

### Arama motorlarına gönderim başarısız
- Her domain'in erişilebilir olduğundan emin olun
- Sitemap URL'lerinin doğru olduğunu kontrol edin
- API response'u kontrol edin (admin panelinde görüntülenir)

### Domain'ler görünmüyor
- `.env` dosyasını yeniden yükleyin (uygulamayı yeniden başlatın)
- Environment variable formatını kontrol edin

## 📝 Notlar

- Sitemap otomatik olarak güncellenir (yeni içerik eklendiğinde)
- Her domain için aynı içerik gösterilir (URL'ler farklıdır)
- Arama motorlarına gönderim yapıldığında tüm domain'ler için gönderilir
- Robots.txt dosyası ana domain'i kullanır

