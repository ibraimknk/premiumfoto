# 🔄 Google'da Indexlenen Blog Sayfaları İçin Otomatik Blog Oluşturma

Bu script, Google'da indexlenen blog sayfalarını bulup, aynı URL ve konuyla otomatik olarak yeni blog yazıları oluşturur.

## 🚀 Kullanım

### Sunucuda Çalıştırma

```bash
cd ~/premiumfoto
git pull origin main
npm install
chmod +x scripts/regenerate-blogs-manual.sh
bash scripts/regenerate-blogs-manual.sh
```

### Veya Doğrudan npm Script ile

```bash
cd ~/premiumfoto
npm install
npm run regenerate-blogs
```

## 📋 Gereksinimler

1. **GEMINI_API_KEY**: `.env` dosyasında tanımlı olmalı
2. **cheerio**: HTML parsing için (otomatik kurulur)
3. **tsx**: TypeScript script'lerini çalıştırmak için (zaten kurulu)

## 🔧 Nasıl Çalışır?

1. **Blog URL'lerini Bulur**:
   - Google Custom Search API kullanır (varsa)
   - Veya sitemap.xml'den blog URL'lerini çeker
   - Veya alternatif yöntemlerle URL'leri bulur

2. **Her URL İçin**:
   - URL'den slug çıkarır
   - Sayfa içeriğinden konuyu çıkarır (başlık, meta description)
   - Gemini API ile aynı konuda yeni bir blog yazısı oluşturur
   - Aynı slug ile veritabanına kaydeder

3. **Sonuçlar**:
   - Başarılı ve başarısız blog'ları gösterir
   - Her blog için detaylı log çıktısı verir

## ⚙️ Yapılandırma

### Google Custom Search API (Opsiyonel)

Eğer Google Custom Search API kullanmak isterseniz:

1. **Google Cloud Console**'da bir proje oluşturun
2. **Custom Search API**'yi etkinleştirin
3. **API Key** oluşturun
4. **Custom Search Engine** oluşturun (https://programmablesearchengine.google.com/)
5. `.env` dosyasına ekleyin:

```bash
GOOGLE_SEARCH_API_KEY="your-api-key-here"
GOOGLE_SEARCH_ENGINE_ID="your-engine-id-here"
```

### Sitemap.xml (Alternatif)

Eğer Google Custom Search API yoksa, script otomatik olarak:
- `https://fotougur.com.tr/sitemap.xml` dosyasından blog URL'lerini çeker
- Veya manuel URL listesi kullanabilirsiniz

## 📝 Örnek Çıktı

```
🚀 Google'dan indexlenen blog sayfaları bulunuyor...

✅ Sitemap'ten 15 blog URL'i bulundu

📋 15 blog URL'i bulundu:

1. https://fotougur.com.tr/blog/dugun-fotografciligi
2. https://fotougur.com.tr/blog/urun-fotografciligi
...

🔄 Blog'lar oluşturuluyor...

[1/15] İşleniyor: https://fotougur.com.tr/blog/dugun-fotografciligi
   Slug: dugun-fotografciligi
   📝 Konu: Düğün Fotoğrafçılığı Rehberi
   ✅ Blog içeriği oluşturuldu: Düğün Fotoğrafçılığı İpuçları
   ✅ Veritabanına kaydedildi: clx1234567890

...

============================================================
📊 SONUÇLAR
============================================================
✅ Başarılı: 15
❌ Başarısız: 0

✅ Başarılı blog'lar:
   - Düğün Fotoğrafçılığı İpuçları (dugun-fotografciligi)
   - Ürün Fotoğrafçılığı Rehberi (urun-fotografciligi)
   ...
```

## 🔍 Özellikler

- ✅ **Otomatik URL Bulma**: Google'dan veya sitemap'ten blog URL'lerini bulur
- ✅ **Konu Çıkarma**: Her URL'den başlık ve meta bilgilerini çıkarır
- ✅ **Gemini AI**: Aynı konuda özgün blog içeriği oluşturur
- ✅ **Aynı Slug**: Orijinal URL'deki slug'ı korur
- ✅ **Otomatik Yayınlama**: Blog'lar otomatik olarak yayınlanır
- ✅ **Hata Yönetimi**: Hatalı blog'ları atlar ve devam eder
- ✅ **Rate Limiting**: API rate limit'lerini aşmamak için bekleme yapar

## ⚠️ Önemli Notlar

1. **Slug Çakışması**: Eğer aynı slug'da blog varsa, mevcut blog güncellenir
2. **Rate Limiting**: Her blog arasında 3 saniye bekleme yapılır
3. **İçerik Özgünlüğü**: Gemini API her seferinde yeni içerik oluşturur
4. **SEO Optimizasyonu**: Oluşturulan blog'lar SEO için optimize edilir

## 🐛 Sorun Giderme

### "cheerio bulunamadı" hatası

```bash
npm install cheerio
```

### "GEMINI_API_KEY bulunamadı" hatası

`.env` dosyasına ekleyin:
```bash
GEMINI_API_KEY="your-api-key-here"
```

### "Sitemap okunamadı" hatası

Sitemap.xml dosyasının erişilebilir olduğundan emin olun:
```bash
curl https://fotougur.com.tr/sitemap.xml
```

### Blog'lar oluşturulmuyor

1. Gemini API key'inin geçerli olduğundan emin olun
2. Veritabanı bağlantısını kontrol edin
3. Log çıktılarını kontrol edin

## 📚 İlgili Dosyalar

- `scripts/regenerate-blogs-from-google.ts` - Ana script
- `scripts/regenerate-blogs-manual.sh` - Bash wrapper script
- `lib/gemini.ts` - Gemini API entegrasyonu
- `lib/prisma.ts` - Veritabanı bağlantısı

