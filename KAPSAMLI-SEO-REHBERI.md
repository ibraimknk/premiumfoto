# Kapsamlı SEO Rehberi - Rich Snippet Dışında

## 📊 Mevcut SEO Durumu

### ✅ Zaten Yapılmış Olanlar

1. **Rich Snippets (Schema.org)** ✅
   - Organization, LocalBusiness, BlogPosting, FAQPage, vb.
   
2. **Meta Tags** ✅
   - Title, Description, Keywords
   - OpenGraph (Facebook, LinkedIn)
   - Twitter Cards

3. **Sitemap** ✅
   - Otomatik sitemap oluşturma
   - Google Search Console'a gönderim

4. **Responsive Design** ✅
   - Mobile-friendly

## 🚀 Yapılabilecek Ek SEO İyileştirmeleri

### 1. Canonical URLs (Önemli!)

**Sorun**: Duplicate content (www vs non-www, http vs https)

**Çözüm**: Her sayfaya canonical URL ekle

```typescript
// lib/seo.ts'e ekle
export async function generatePageMetadata(
  title?: string,
  description?: string,
  keywords?: string,
  image?: string,
  canonicalUrl?: string // Yeni parametre
): Promise<Metadata> {
  return {
    // ... mevcut kodlar
    alternates: {
      canonical: canonicalUrl || siteUrl,
    },
  }
}
```

### 2. Image Optimization (Görsel SEO)

**Yapılacaklar**:
- ✅ Alt text ekle (zaten var mı kontrol et)
- ✅ Image lazy loading
- ✅ WebP format kullan
- ✅ Image sitemap oluştur

**Kontrol**:
```bash
# Tüm görsellerde alt text var mı?
grep -r "alt=" app/ | wc -l
```

### 3. Page Speed Optimization

**Yapılacaklar**:
- ✅ Next.js Image component kullan (zaten kullanılıyor)
- ✅ Code splitting
- ✅ Font optimization
- ✅ CSS/JS minification
- ✅ CDN kullanımı
- ✅ Caching headers

**Test**:
- Google PageSpeed Insights: https://pagespeed.web.dev/
- GTmetrix: https://gtmetrix.com/

### 4. Internal Linking (İç Linkleme)

**Yapılacaklar**:
- Blog yazıları arasında cross-linking
- İlgili hizmetlere linkler
- Breadcrumb navigation (zaten var ✅)
- Related posts (zaten var ✅)

**Örnek**:
```typescript
// Blog yazısında ilgili hizmetlere link
<Link href="/hizmetler/dugun-fotografciligi">
  Düğün Fotoğrafçılığı Hizmetlerimiz
</Link>
```

### 5. Content Optimization (İçerik Optimizasyonu)

**Yapılacaklar**:
- ✅ H1, H2, H3 yapısı (zaten var)
- ✅ Keyword density kontrolü
- ✅ Long-tail keywords
- ✅ LSI keywords (semantic keywords)
- ✅ Content length (blog'lar en az 1000 kelime)

**Örnek**:
- Ana keyword: "ataşehir fotoğrafçı"
- Long-tail: "ataşehir düğün fotoğrafçısı fiyatları"
- LSI: "istanbul fotoğrafçı", "profesyonel fotoğraf", "fotoğraf stüdyosu"

### 6. Local SEO (Yerel SEO)

**Yapılacaklar**:
- ✅ Google Business Profile (Google My Business)
- ✅ NAP consistency (Name, Address, Phone)
- ✅ Local keywords
- ✅ Location pages (Ataşehir, İstanbul)
- ✅ Reviews schema (zaten var ✅)

**Google Business Profile**:
1. https://business.google.com/ adresine gidin
2. İşletmenizi ekleyin
3. Fotoğraflar, saatler, yorumlar ekleyin

### 7. Technical SEO

**Yapılacaklar**:
- ✅ Robots.txt (kontrol et)
- ✅ XML Sitemap (zaten var ✅)
- ✅ HTTPS (zaten var ✅)
- ✅ SSL certificate
- ✅ 404 error handling
- ✅ Redirect management (301, 302)

**Robots.txt Kontrolü**:
```bash
# Sunucuda kontrol et
curl https://fotougur.com.tr/robots.txt
```

### 8. Mobile SEO

**Yapılacaklar**:
- ✅ Responsive design (zaten var ✅)
- ✅ Mobile-first indexing
- ✅ Touch-friendly buttons
- ✅ Mobile page speed

**Test**:
- Google Mobile-Friendly Test: https://search.google.com/test/mobile-friendly

### 9. Social Signals (Sosyal Sinyaller)

**Yapılacaklar**:
- ✅ OpenGraph tags (zaten var ✅)
- ✅ Twitter Cards (zaten var ✅)
- ✅ Social sharing buttons
- ✅ Social media presence
- ✅ Social media links (zaten var ✅)

**Eklenebilir**:
- Facebook Pixel
- Instagram integration
- Social proof (testimonials zaten var ✅)

### 10. Backlink Strategy (Geri Bağlantı Stratejisi)

**Yapılacaklar**:
- ✅ Local directories (Yandex, Google Maps)
- ✅ Industry directories
- ✅ Guest posting
- ✅ PR activities
- ✅ Social media links

**Örnekler**:
- Yandex Rehber
- Google Maps
- Fotoğrafçılık dernekleri
- Yerel işletme rehberleri

### 11. Core Web Vitals

**Yapılacaklar**:
- ✅ LCP (Largest Contentful Paint) < 2.5s
- ✅ FID (First Input Delay) < 100ms
- ✅ CLS (Cumulative Layout Shift) < 0.1

**Test**:
- Google Search Console > Core Web Vitals
- PageSpeed Insights

### 12. Content Freshness (İçerik Güncelliği)

**Yapılacaklar**:
- ✅ Düzenli blog yazıları (zaten var ✅)
- ✅ Güncel içerik
- ✅ Last modified dates
- ✅ Content updates

**Örnek**:
```typescript
// Blog yazısında güncelleme tarihi
<time dateTime={post.updatedAt?.toISOString()}>
  Son güncelleme: {formatDate(post.updatedAt)}
</time>
```

### 13. URL Structure (URL Yapısı)

**Mevcut Durum**: ✅ İyi
- `/blog/slug` formatı
- `/hizmetler/slug` formatı
- Kısa ve açıklayıcı URL'ler

**İyileştirmeler**:
- ✅ Slug'lar keyword içermeli
- ✅ Türkçe karakterler URL-friendly olmalı

### 14. Analytics & Tracking

**Yapılacaklar**:
- ✅ Google Analytics 4
- ✅ Google Search Console (zaten var ✅)
- ✅ Conversion tracking
- ✅ Event tracking

**Kurulum**:
```typescript
// app/layout.tsx'e ekle
import Script from 'next/script'

<Script
  src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"
  strategy="afterInteractive"
/>
```

### 15. Security & Trust Signals

**Yapılacaklar**:
- ✅ HTTPS (zaten var ✅)
- ✅ SSL certificate
- ✅ Privacy policy (zaten var ✅)
- ✅ Terms of service
- ✅ Trust badges

## 📋 Öncelik Sırası

### 🔴 Yüksek Öncelik (Hemen Yapılmalı)

1. **Canonical URLs** - Duplicate content önleme
2. **Image Alt Text** - Tüm görsellere alt text
3. **Google Business Profile** - Local SEO için kritik
4. **Robots.txt** - Kontrol et ve optimize et
5. **Page Speed** - Core Web Vitals iyileştirme

### 🟡 Orta Öncelik (1-2 Hafta İçinde)

1. **Internal Linking** - Blog'lar arası linkleme
2. **Content Optimization** - Keyword density
3. **Image Optimization** - WebP, lazy loading
4. **Analytics** - Google Analytics kurulumu
5. **Social Sharing** - Paylaşım butonları

### 🟢 Düşük Öncelik (1 Ay İçinde)

1. **Backlink Strategy** - Directory listings
2. **Content Freshness** - Güncelleme tarihleri
3. **Advanced Schema** - Video, Product schema
4. **A/B Testing** - Conversion optimization

## 🛠️ Hızlı Kontrol Listesi

### Teknik SEO

- [ ] Canonical URLs eklendi mi?
- [ ] Robots.txt doğru mu?
- [ ] Sitemap güncel mi?
- [ ] 404 sayfası var mı?
- [ ] HTTPS aktif mi?
- [ ] SSL certificate geçerli mi?

### İçerik SEO

- [ ] Tüm görsellerde alt text var mı?
- [ ] H1, H2, H3 yapısı doğru mu?
- [ ] Meta descriptions optimize mi?
- [ ] Keywords doğru kullanılmış mı?
- [ ] Internal linking yeterli mi?

### Local SEO

- [ ] Google Business Profile aktif mi?
- [ ] NAP consistency sağlanmış mı?
- [ ] Local keywords kullanılmış mı?
- [ ] Reviews schema var mı?

### Performance

- [ ] PageSpeed score > 90?
- [ ] Core Web Vitals geçerli mi?
- [ ] Images optimize edilmiş mi?
- [ ] Caching aktif mi?

## 📊 SEO Araçları

### Ücretsiz Araçlar

1. **Google Search Console** - İndeksleme, hatalar
2. **Google Analytics** - Trafik analizi
3. **PageSpeed Insights** - Performans
4. **Rich Results Test** - Schema kontrolü
5. **Mobile-Friendly Test** - Mobil uyumluluk

### Ücretli Araçlar (Opsiyonel)

1. **Ahrefs** - Backlink analizi
2. **SEMrush** - Keyword research
3. **Screaming Frog** - Technical SEO audit

## 🎯 Sonuç

**Mevcut Durum**: ✅ İyi bir temel var
- Rich snippets ✅
- Meta tags ✅
- Sitemap ✅
- Responsive ✅

**Yapılacaklar**:
1. Canonical URLs (öncelikli)
2. Image optimization
3. Google Business Profile
4. Internal linking
5. Page speed optimization

**Beklenen Sonuç**:
- %20-30 daha iyi sıralama
- Daha fazla organik trafik
- Daha iyi kullanıcı deneyimi
- Daha yüksek conversion rate

