# Rich Snippet Kontrol Kılavuzu

## 🔍 Rich Snippet'leri Kontrol Etme Yöntemleri

### 1. Google Rich Results Test (Önerilen)

**URL**: https://search.google.com/test/rich-results

**Kullanım**:
1. Sayfanın URL'sini girin (örn: `https://fotougur.com.tr/blog/dugun-fotografciliginda-5-onemli-ipucu`)
2. "Test URL" butonuna tıklayın
3. Sonuçları kontrol edin

**Beklenen Sonuç**:
- ✅ "Article" schema bulundu
- ✅ "BreadcrumbList" schema bulundu
- ✅ Hata yok

### 2. Schema.org Validator

**URL**: https://validator.schema.org/

**Kullanım**:
1. Sayfanın URL'sini girin
2. "Run Test" butonuna tıklayın
3. JSON-LD kodlarını kontrol edin

### 3. Sayfa Kaynağını Görüntüleme (Manuel)

**Tarayıcıda**:
1. Sayfaya gidin (örn: `https://fotougur.com.tr/blog/dugun-fotografciliginda-5-onemli-ipucu`)
2. Sağ tık → "Sayfa Kaynağını Görüntüle" (veya `Ctrl+U`)
3. `application/ld+json` arayın
4. JSON-LD kodlarını kontrol edin

**Örnek**:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "...",
  ...
}
</script>
```

### 4. Browser DevTools ile Kontrol

**Chrome/Edge**:
1. Sayfaya gidin
2. `F12` tuşuna basın (DevTools açılır)
3. "Elements" sekmesine gidin
4. `Ctrl+F` ile `application/ld+json` arayın
5. JSON-LD kodlarını kontrol edin

### 5. cURL ile Kontrol (Sunucuda)

```bash
# Blog yazısı sayfası
curl -s https://fotougur.com.tr/blog/dugun-fotografciliginda-5-onemli-ipucu | grep -A 20 "application/ld+json"

# Ana sayfa
curl -s https://fotougur.com.tr | grep -A 20 "application/ld+json"

# Hizmet sayfası
curl -s https://fotougur.com.tr/hizmetler/dugun-fotografciligi | grep -A 20 "application/ld+json"
```

## 📋 Kontrol Edilecek Sayfalar

### ✅ Eklenen Rich Snippet'ler

1. **Ana Sayfa** (`/`)
   - Organization Schema
   - LocalBusiness Schema
   - WebSite Schema
   - Review Schema (testimonials varsa)

2. **Blog Listesi** (`/blog`)
   - Blog Schema

3. **Blog Yazısı** (`/blog/[slug]`)
   - BlogPosting Schema
   - BreadcrumbList Schema

4. **Hizmet Listesi** (`/hizmetler`)
   - ItemList Schema

5. **Hizmet Detay** (`/hizmetler/[slug]`)
   - Service Schema
   - BreadcrumbList Schema

6. **İletişim** (`/iletisim`)
   - ContactPage Schema

7. **SSS** (`/sss`)
   - FAQPage Schema

## 🧪 Hızlı Test Komutları

### Sunucuda Test

```bash
# Blog yazısı sayfasında schema kontrolü
curl -s https://fotougur.com.tr/blog/dugun-fotografciliginda-5-onemli-ipucu | grep -o 'application/ld+json' | wc -l
# Sonuç: 2 olmalı (BlogPosting + BreadcrumbList)

# Ana sayfada schema kontrolü
curl -s https://fotougur.com.tr | grep -o 'application/ld+json' | wc -l
# Sonuç: 3-4 olmalı (Organization + LocalBusiness + WebSite + Review)
```

### Local Test (Geliştirme)

```bash
# Next.js dev server'da test
curl -s http://localhost:3000/blog | grep -o 'application/ld+json' | wc -l
```

## 🔍 Beklenen Schema Türleri

### Ana Sayfa
- `@type: "Organization"`
- `@type: "ProfessionalService"` (LocalBusiness)
- `@type: "WebSite"`
- `@type: "Organization"` (Review için)

### Blog Yazısı
- `@type: "BlogPosting"`
- `@type: "BreadcrumbList"`

### Hizmet Detay
- `@type: "Service"`
- `@type: "BreadcrumbList"`

### İletişim
- `@type: "ContactPage"`

### SSS
- `@type: "FAQPage"`

## ⚠️ Yaygın Sorunlar

### Schema Bulunamadı
- **Sebep**: Build yapılmamış veya cache sorunu
- **Çözüm**: `npm run build` ve cache temizleme

### Schema Hatalı
- **Sebep**: JSON syntax hatası
- **Çözüm**: Google Rich Results Test ile kontrol edin

### Schema Görünmüyor
- **Sebep**: Sayfa henüz indekslenmemiş
- **Çözüm**: Google Search Console'da URL'yi test edin

## 📊 Google Search Console Kontrolü

1. **Google Search Console**'a gidin: https://search.google.com/search-console
2. **Gelişmiş** > **Yapılandırılmış veriler** bölümüne gidin
3. Hataları kontrol edin
4. Geçerli schema'ları görüntüleyin

## 🎯 Hızlı Kontrol Script'i

Sunucuda çalıştırın:

```bash
#!/bin/bash
# Rich snippet kontrol script'i

DOMAIN="https://fotougur.com.tr"

echo "🔍 Rich Snippet Kontrolü"
echo "========================"
echo ""

# Ana sayfa
echo "1. Ana Sayfa:"
curl -s "$DOMAIN" | grep -o 'application/ld+json' | wc -l | xargs echo "   Schema sayısı:"

# Blog listesi
echo "2. Blog Listesi:"
curl -s "$DOMAIN/blog" | grep -o 'application/ld+json' | wc -l | xargs echo "   Schema sayısı:"

# Blog yazısı (ilk blog slug'ını al)
BLOG_SLUG=$(curl -s "$DOMAIN/blog" | grep -oP 'href="/blog/[^"]+"' | head -1 | sed 's/href="\/blog\///;s/"//')
if [ ! -z "$BLOG_SLUG" ]; then
    echo "3. Blog Yazısı ($BLOG_SLUG):"
    curl -s "$DOMAIN/blog/$BLOG_SLUG" | grep -o 'application/ld+json' | wc -l | xargs echo "   Schema sayısı:"
fi

# Hizmet listesi
echo "4. Hizmet Listesi:"
curl -s "$DOMAIN/hizmetler" | grep -o 'application/ld+json' | wc -l | xargs echo "   Schema sayısı:"

# İletişim
echo "5. İletişim:"
curl -s "$DOMAIN/iletisim" | grep -o 'application/ld+json' | wc -l | xargs echo "   Schema sayısı:"

echo ""
echo "✅ Kontrol tamamlandı!"
```

## 📝 Notlar

1. **İndeksleme**: Google'ın schema'ları görmesi 1-2 hafta sürebilir
2. **Test**: Google Rich Results Test anında sonuç verir
3. **Cache**: Tarayıcı cache'i temizleyin veya incognito mod kullanın
4. **Build**: Production build'de schema'lar aktif olur

