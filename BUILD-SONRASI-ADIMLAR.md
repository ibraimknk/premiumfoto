# Build Sonrası Yapılacaklar

## ✅ Build Başarılı!

- ✅ Veritabanı yedeklendi
- ✅ Blog kayıtları korundu (5 blog)
- ✅ Tüm SEO iyileştirmeleri aktif
- ✅ Google Analytics aktif (G-PR5RQ39RRG)
- ✅ PM2 restart edildi

## 🎯 Şimdi Yapılacaklar (Sırayla)

### 1. Google Analytics Kontrolü (2 Dakika) ✅

**Kontrol et:**
1. https://analytics.google.com/ adresine git
2. Realtime > Overview
3. Siteyi ziyaret et (https://fotougur.com.tr)
4. Realtime'da görünüyor mu kontrol et

**Beklenen:**
- Birkaç dakika içinde veri görünmeye başlar
- Eğer görünmüyorsa, birkaç dakika bekle

**Sorun varsa:**
- PM2 loglarını kontrol et: `pm2 logs foto-ugur-app --lines 20`
- Siteyi farklı tarayıcıdan ziyaret et
- Incognito modda test et

---

### 2. Google Business Profile Oluştur (10-15 Dakika) 📍

**Adımlar:**

1. **Google Business Profile'a git:**
   - https://business.google.com/
   - "Manage now" veya "Get started" butonuna tıkla

2. **İşletme bilgilerini gir:**
   - İşletme adı: **Foto Uğur** veya **Uğur Fotoğrafçılık**
   - Kategori: **Fotoğraf Stüdyosu** veya **Fotoğrafçı**
   - Adres: **Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul, 34758**
   - Telefon: **0216 472 46 28**
   - Website: **https://fotougur.com.tr**

3. **Doğrulama yap:**
   - Telefon veya posta ile doğrulama seçeneği sunulur
   - Doğrulama kodunu gir

4. **Profili tamamla:**
   - **Fotoğraflar ekle** (en az 3-5 fotoğraf - önemli!)
   - **Çalışma saatleri:** 
     - Pazartesi: 09:00 - 19:00
     - Salı: 09:00 - 19:00
     - Çarşamba: 09:00 - 19:00
     - Perşembe: 09:00 - 19:00
     - Cuma: 09:00 - 19:00
     - Cumartesi: 09:00 - 19:00
     - Pazar: Kapalı
   - **Açıklama ekle:**
     ```
     Foto Uğur - 1997'den beri Ataşehir'de profesyonel fotoğraf hizmetleri sunuyoruz. 
     Düğün fotoğrafçılığı, dış mekan çekimi, ürün fotoğrafçılığı ve daha fazlası.
     ```
   - **Hizmetler ekle:**
     - Düğün Fotoğrafçılığı
     - Dış Mekan Çekimi
     - Ürün Fotoğrafçılığı
     - Stüdyo Çekimi
     - Vesikalık & Biyometrik Fotoğraf

**Fayda:**
- Google Maps'te görünürsünüz
- "Ataşehir fotoğrafçı" gibi yerel aramalarda öne çıkarsınız
- Müşteriler kolayca bulur ve yorum yapabilir

---

### 3. Image Alt Text Kontrolü (5 Dakika) 🖼️

**Mevcut durum:**
- 8 alt text bulundu
- Tüm görsellerde alt text olup olmadığını kontrol et

**Kontrol komutu:**
```bash
# Eksik alt text'leri bul
cd ~/premiumfoto
grep -r "<Image" app/ | grep -v "alt="
```

**Eğer eksik varsa:**
1. Admin panelden blog'ları düzenle
2. Her görsele alt text ekle
3. Örnek alt text formatı:
   - "Düğün fotoğrafçılığı hizmeti - Foto Uğur"
   - "Ataşehir dış mekan çekimi örneği - Foto Uğur"
   - "Ürün fotoğrafçılığı çalışması - Foto Uğur"

**Önemli:**
- Alt text SEO için çok önemli
- Görsel aramalarda görünürsünüz
- Erişilebilirlik için gerekli

---

### 4. Google Search Console Kontrolü (5 Dakika) 🔍

**Kontrol et:**
1. https://search.google.com/search-console adresine git
2. Site ekli mi kontrol et
3. Sitemap gönderilmiş mi kontrol et:
   - Sol menü > Sitemaps
   - `https://fotougur.com.tr/sitemap.xml` gönderilmiş mi?

**Eğer sitemap gönderilmemişse:**
1. Sol menüden "Sitemaps" seç
2. "Yeni sitemap ekle" butonuna tıkla
3. `https://fotougur.com.tr/sitemap.xml` gir
4. "Gönder" butonuna tıkla

**Rich Snippet kontrolü:**
1. Sol menü > Gelişmiş > Yapılandırılmış veriler
2. Rich snippet'lerin görünüp görünmediğini kontrol et

---

## 📋 Hızlı Checklist

### Bugün Yapılacaklar

- [ ] **1. Google Analytics kontrol et**
  - Veri geliyor mu?
  - Realtime çalışıyor mu?

- [ ] **2. Google Business Profile oluştur**
  - İşletme bilgilerini ekle
  - Doğrulama yap
  - Fotoğraflar ekle
  - Profili tamamla

- [ ] **3. Image Alt Text kontrolü**
  - Eksik alt text var mı?
  - Varsa admin panelden ekle

- [ ] **4. Google Search Console kontrol**
  - Sitemap gönderilmiş mi?
  - Rich snippet'ler görünüyor mu?

### Bu Hafta Yapılacaklar

- [ ] **5. İçerik güncellemeleri**
  - Yeni blog yazıları ekle
  - Hizmet sayfalarını güncelle

- [ ] **6. Sosyal medya paylaşımları**
  - Blog yazılarını paylaş
  - Google Business Profile'dan paylaş

---

## 🎯 Öncelik Sırası

### 1. ÖNCE: Google Business Profile (En Önemli!)
- Yerel SEO için kritik
- Google Maps'te görünürlük
- 10-15 dakika sürer

### 2. SONRA: Google Analytics Kontrolü
- Veri geliyor mu kontrol et
- 2 dakika sürer

### 3. SONRA: Image Alt Text
- Eksik varsa ekle
- 5-10 dakika sürer

### 4. SONRA: Google Search Console
- Sitemap kontrolü
- 5 dakika sürer

---

## ✅ Özet

**Build başarılı!** Şimdi:

1. **Google Business Profile oluştur** (en önemli - 10-15 dk)
2. **Google Analytics kontrol et** (2 dk)
3. **Image Alt Text kontrol et** (5 dk)
4. **Google Search Console kontrol et** (5 dk)

**Tüm bunlar yapıldıktan sonra bekleyin ve sonuçları izleyin!**

