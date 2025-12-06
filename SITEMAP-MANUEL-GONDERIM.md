# Sitemap Manuel Gönderim Kılavuzu

## ⚠️ Önemli Not

Google ve Bing'in ping endpoint'leri artık çalışmıyor (404/410 hatası). Bu nedenle sitemap'leri **Google Search Console** ve **Bing Webmaster Tools** üzerinden manuel olarak göndermeniz gerekiyor.

Yandex ping endpoint'i çalışıyor ve otomatik gönderim başarılı.

## 📋 Manuel Gönderim Adımları

### 1. Google Search Console

1. **Google Search Console'a giriş yapın:**
   - https://search.google.com/search-console

2. **Her domain için ayrı ayrı:**
   - Sol menüden "Sitemaps" seçeneğine tıklayın
   - "Yeni sitemap ekle" butonuna tıklayın
   - Sitemap URL'sini girin: `https://fotougur.com.tr/sitemap.xml`
   - "Gönder" butonuna tıklayın

3. **Tüm domain'ler için tekrarlayın:**
   - `https://fotougur.com.tr/sitemap.xml`
   - `https://dugunkarem.com/sitemap.xml`
   - `https://dugunkarem.com.tr/sitemap.xml`

### 2. Bing Webmaster Tools

1. **Bing Webmaster Tools'a giriş yapın:**
   - https://www.bing.com/webmasters

2. **Her domain için ayrı ayrı:**
   - Sol menüden "Sitemaps" seçeneğine tıklayın
   - "Sitemap ekle" butonuna tıklayın
   - Sitemap URL'sini girin: `https://fotougur.com.tr/sitemap.xml`
   - "Gönder" butonuna tıklayın

3. **Tüm domain'ler için tekrarlayın:**
   - `https://fotougur.com.tr/sitemap.xml`
   - `https://dugunkarem.com/sitemap.xml`
   - `https://dugunkarem.com.tr/sitemap.xml`

## ✅ Yandex

Yandex ping endpoint'i çalışıyor, otomatik gönderim başarılı. Ek bir işlem gerekmiyor.

## 🔄 Güncelleme

Sitemap içeriği değiştiğinde (yeni sayfa, blog yazısı, hizmet eklendiğinde):

1. **Google Search Console:** Sitemap'i yeniden göndermenize gerek yok, otomatik tarar
2. **Bing Webmaster Tools:** Sitemap'i yeniden göndermenize gerek yok, otomatik tarar
3. **Yandex:** Admin panelinden "Site Haritasını Arama Motorlarına Gönder" butonuna tıklayın

## 📝 Notlar

- İlk gönderimden sonra arama motorları sitemap'i otomatik olarak periyodik olarak kontrol eder
- Sitemap URL'lerinin erişilebilir olduğundan emin olun (tarayıcıda açarak test edin)
- Robots.txt dosyanızda sitemap URL'si belirtilmiş olmalı (otomatik olarak ekleniyor)

## 🔗 Hızlı Linkler

- **Google Search Console:** https://search.google.com/search-console
- **Bing Webmaster Tools:** https://www.bing.com/webmasters
- **Yandex Webmaster:** https://webmaster.yandex.com

