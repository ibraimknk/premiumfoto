# Şimdi Ne Yapmalı? - Adım Adım Rehber

## 🎯 Öncelik Sırası

### 1. Sunucuda Build (ÖNCE BUNU YAP) ⚠️

**Güvenli build script ile:**
```bash
cd ~/premiumfoto
bash scripts/safe-build-with-backup.sh
```

Bu script:
- ✅ Veritabanını otomatik yedekler
- ✅ Git pull yapar
- ✅ Build yapar
- ✅ PM2 restart yapar
- ✅ Blog kayıtlarını kontrol eder

**Neden önce bu?**
- Tüm SEO iyileştirmeleri (canonical URLs, internal linking, Google Analytics) aktif olacak
- Kod değişiklikleri canlıya çıkacak

---

### 2. Google Analytics (5 Dakika) ✅

**Zaten eklendi!** Kodda `G-PR5RQ39RRG` ID'si var.

**Sadece kontrol et:**
1. Google Analytics'te veri geliyor mu kontrol et:
   - https://analytics.google.com/
   - Realtime > Overview
   - Siteyi ziyaret et, veri geliyor mu bak

**Eğer veri gelmiyorsa:**
- Build yapıldı mı kontrol et
- PM2 restart yapıldı mı kontrol et
- Birkaç dakika bekle (veri gelmesi zaman alabilir)

---

### 3. Google Business Profile (10-15 Dakika) 📍

**Adımlar:**

1. **Google Business Profile oluştur:**
   - https://business.google.com/ adresine git
   - "Manage now" veya "Get started" butonuna tıkla
   - İşletme adını gir: "Foto Uğur" veya "Uğur Fotoğrafçılık"

2. **İşletme bilgilerini ekle:**
   - Adres: Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul
   - Telefon: 0216 472 46 28
   - Website: https://fotougur.com.tr
   - Kategori: Fotoğraf Stüdyosu / Fotoğrafçı

3. **Doğrulama yap:**
   - Telefon veya posta ile doğrulama seçeneği sunulur
   - Doğrulama kodunu gir

4. **Profili tamamla:**
   - Fotoğraflar ekle (en az 3-5 fotoğraf)
   - Çalışma saatleri: Pazartesi-Cumartesi 09:00-19:00
   - Açıklama ekle
   - Hizmetler ekle

**Fayda:**
- Google Maps'te görünürsünüz
- Yerel aramalarda öne çıkarsınız
- Müşteriler kolayca bulur

---

### 4. Image Alt Text Kontrolü (10 Dakika) 🖼️

**Kontrol et:**

```bash
# Sunucuda çalıştır
cd ~/premiumfoto

# Tüm görsellerde alt text var mı kontrol et
grep -r "alt=" app/ | wc -l

# Eksik alt text'leri bul
grep -r "<Image" app/ | grep -v "alt="
```

**Eğer eksik varsa:**
- Admin panelden blog'ları düzenle
- Her görsele alt text ekle
- Örnek: "Düğün fotoğrafçılığı hizmeti - Foto Uğur"

**Önemli:**
- Alt text SEO için çok önemli
- Görsel aramalarda görünürsünüz
- Erişilebilirlik için gerekli

---

## 📋 Hızlı Checklist

### Şimdi Yapılacaklar (Bugün)

- [ ] **1. Sunucuda build yap** (Güvenli script ile)
  ```bash
  cd ~/premiumfoto
  bash scripts/safe-build-with-backup.sh
  ```

- [ ] **2. Google Analytics kontrol et**
  - https://analytics.google.com/
  - Realtime verileri kontrol et

- [ ] **3. Google Business Profile oluştur**
  - https://business.google.com/
  - İşletme bilgilerini ekle
  - Doğrulama yap

### Bu Hafta Yapılacaklar

- [ ] **4. Image Alt Text kontrolü**
  - Eksik alt text'leri bul
  - Admin panelden ekle

- [ ] **5. Google Search Console kontrol**
  - Sitemap gönderildi mi?
  - Rich snippet'ler görünüyor mu?

### Bu Ay Yapılacaklar

- [ ] **6. İçerik güncellemeleri**
  - Yeni blog yazıları
  - Hizmet sayfalarını güncelle

- [ ] **7. Backlink stratejisi**
  - Yerel dizinlere kayıt
  - Sosyal medya paylaşımları

---

## 🚀 Hızlı Başlangıç (Tek Komut)

**Sunucuda çalıştır:**
```bash
cd ~/premiumfoto && bash scripts/safe-build-with-backup.sh
```

Bu komut:
1. ✅ Veritabanını yedekler
2. ✅ Git pull yapar
3. ✅ Build yapar
4. ✅ PM2 restart yapar
5. ✅ Blog kayıtlarını kontrol eder

---

## 📊 Beklenen Sonuçlar

### Hemen (Build Sonrası)
- ✅ Canonical URLs aktif
- ✅ Internal linking çalışıyor
- ✅ Google Analytics veri topluyor
- ✅ Page speed iyileşti

### 1-2 Hafta İçinde
- 📈 Google Business Profile görünür
- 📈 Rich snippet'ler indekslenmeye başlar
- 📈 Google Analytics verileri birikmeye başlar

### 1-2 Ay İçinde
- 📈 Daha iyi sıralama
- 📈 Daha fazla organik trafik
- 📈 Daha fazla yerel arama sonucu

### 3-6 Ay İçinde
- 📈 %20-30 daha iyi sıralama
- 📈 %15-25 daha fazla trafik
- 📈 Daha yüksek conversion rate

---

## 🎯 Özet: Şimdi Ne Yapmalı?

### 1. ÖNCE: Sunucuda Build
```bash
cd ~/premiumfoto
bash scripts/safe-build-with-backup.sh
```

### 2. SONRA: Google Business Profile
- https://business.google.com/
- İşletme oluştur ve doğrula

### 3. SONRA: Kontroller
- Google Analytics veri geliyor mu?
- Image Alt Text eksik var mı?

**Tüm bunlar yapıldıktan sonra bekleyin ve sonuçları izleyin!**

