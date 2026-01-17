# Rich Snippet (Yapılandırılmış Veri) Kullanım Kılavuzu

## 📋 Eklenen Rich Snippet'ler

### 1. **Organization Schema** (Kuruluş Bilgileri)
- **Konum**: Ana sayfa (`/`)
- **İçerik**: Şirket bilgileri, adres, iletişim, sosyal medya linkleri
- **Fayda**: Google'da şirket bilgileri zengin snippet olarak gösterilir

### 2. **LocalBusiness Schema** (Yerel İşletme)
- **Konum**: Ana sayfa (`/`)
- **İçerik**: İşletme detayları, çalışma saatleri, konum bilgileri
- **Fayda**: Google Maps'te ve arama sonuçlarında işletme bilgileri gösterilir

### 3. **WebSite Schema** (Web Sitesi)
- **Konum**: Ana sayfa (`/`)
- **İçerik**: Site arama özelliği
- **Fayda**: Google'da site içi arama kutusu gösterilebilir

### 4. **BlogPosting Schema** (Blog Yazıları)
- **Konum**: Her blog yazısı sayfası (`/blog/[slug]`)
- **İçerik**: Başlık, açıklama, yayın tarihi, yazar, görsel
- **Fayda**: Blog yazıları arama sonuçlarında zengin snippet olarak gösterilir

### 5. **Blog Schema** (Blog Listesi)
- **Konum**: Blog ana sayfası (`/blog`)
- **İçerik**: Blog koleksiyonu bilgileri
- **Fayda**: Blog sayfası Google'da daha iyi tanınır

### 6. **Service Schema** (Hizmetler)
- **Konum**: Her hizmet detay sayfası (`/hizmetler/[slug]`)
- **İçerik**: Hizmet adı, açıklama, sağlayıcı bilgileri
- **Fayda**: Hizmetler arama sonuçlarında öne çıkar

### 7. **ItemList Schema** (Hizmet Listesi)
- **Konum**: Hizmetler ana sayfası (`/hizmetler`)
- **İçerik**: Tüm hizmetlerin listesi
- **Fayda**: Hizmet listesi Google'da daha iyi indekslenir

### 8. **ContactPage Schema** (İletişim Sayfası)
- **Konum**: İletişim sayfası (`/iletisim`)
- **İçerik**: İletişim bilgileri, adres, telefon
- **Fayda**: İletişim bilgileri doğrudan arama sonuçlarında gösterilir

### 9. **FAQPage Schema** (SSS Sayfası)
- **Konum**: SSS sayfası (`/sss`)
- **İçerik**: Sorular ve cevaplar
- **Fayda**: SSS'ler Google'da accordion formatında gösterilir

### 10. **BreadcrumbList Schema** (Breadcrumb Navigasyon)
- **Konum**: Blog ve hizmet detay sayfaları
- **İçerik**: Sayfa hiyerarşisi
- **Fayda**: Arama sonuçlarında breadcrumb gösterilir

### 11. **Review Schema** (Müşteri Yorumları)
- **Konum**: Ana sayfa (`/`)
- **İçerik**: Müşteri yorumları ve puanları
- **Fayda**: Yıldız puanları ve yorumlar arama sonuçlarında gösterilir

## 🔍 Google'da Test Etme

### 1. **Google Rich Results Test**
- URL: https://search.google.com/test/rich-results
- Her sayfayı test edin
- Hataları kontrol edin

### 2. **Google Search Console**
- URL: https://search.google.com/search-console
- "Gelişmiş" > "Yapılandırılmış veriler" bölümünden kontrol edin
- Hataları düzeltin

### 3. **Schema Markup Validator**
- URL: https://validator.schema.org/
- JSON-LD kodlarını doğrulayın

## 📊 Beklenen Sonuçlar

### Arama Sonuçlarında Görebileceğiniz:
- ⭐ Yıldız puanları (testimonials)
- 📍 İşletme bilgileri (adres, telefon)
- 📅 Blog yazı tarihleri
- 🏷️ Breadcrumb navigasyon
- ❓ SSS accordion'ları
- 🖼️ Görseller (blog yazıları)

## 🚀 Sonraki Adımlar

1. **Deploy Edin**: Değişiklikleri sunucuya yükleyin
2. **Test Edin**: Google Rich Results Test ile kontrol edin
3. **Bekleyin**: Google'ın indekslemesi 1-2 hafta sürebilir
4. **İzleyin**: Search Console'dan performansı takip edin

## 📝 Notlar

- Tüm schema'lar JSON-LD formatında eklenmiştir
- Schema'lar dinamik olarak oluşturulur (veritabanından veri çeker)
- Her sayfa için uygun schema seçilmiştir
- Google'ın schema.org standartlarına uygundur

## 🔧 Teknik Detaylar

- **Dosya**: `lib/seo.ts` - Tüm schema fonksiyonları
- **Format**: JSON-LD (application/ld+json)
- **Yerleşim**: Her sayfanın `<head>` bölümünde `<script>` tag'i içinde

