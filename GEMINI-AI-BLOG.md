# 🤖 Gemini AI ile Otomatik Blog Oluşturma

## ✅ Özellikler

- **SEO Uyumlu İçerik**: Her blog yazısı SEO için optimize edilmiş başlık, meta açıklama ve anahtar kelimeler içerir
- **Toplu Oluşturma**: 1-10 arası blog yazısını tek seferde oluşturabilirsiniz
- **Otomatik Slug**: Türkçe karakterler otomatik olarak İngilizce karakterlere dönüştürülür
- **Kategori Belirleme**: AI otomatik olarak uygun kategori belirler
- **Zengin İçerik**: En az 800 kelime, H1/H2/H3 başlıkları ile yapılandırılmış içerik

## 🚀 Kullanım

1. Admin paneline giriş yapın
2. **Blog Yazıları** sayfasına gidin (`/admin/blog`)
3. **"AI ile Oluştur"** butonuna tıklayın
4. Oluşturulacak blog sayısını girin (1-10)
5. İsteğe bağlı olarak bir konu belirtin
6. **"Blog Yazılarını Oluştur"** butonuna tıklayın

## 📝 Oluşturulan Blog Özellikleri

- **Başlık**: SEO uyumlu, 50-60 karakter
- **Slug**: URL-friendly, Türkçe karakterler dönüştürülmüş
- **Excerpt**: 150-160 karakter, SEO için optimize edilmiş
- **Kategori**: Otomatik belirlenir (Düğün Fotoğrafçılığı, Ürün Fotoğrafçılığı, vb.)
- **SEO Başlığı**: Meta title için optimize edilmiş
- **SEO Açıklaması**: Meta description, 150-160 karakter
- **Anahtar Kelimeler**: 5-10 anahtar kelime, virgülle ayrılmış
- **İçerik**: En az 800 kelime, HTML formatında, H1/H2/H3 başlıkları ile

## ⚙️ Yapılandırma

### Environment Variable

`.env` dosyasına `GEMINI_API_KEY` eklenmelidir:

```env
GEMINI_API_KEY="AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"
```

### API Key

Gemini API key'i `lib/gemini.ts` dosyasında varsayılan olarak ayarlanmıştır. İsterseniz environment variable kullanabilirsiniz.

## 📁 Dosya Yapısı

- `lib/gemini.ts` - Gemini API utility
- `app/api/admin/blog/generate/route.ts` - Blog oluşturma API endpoint
- `app/(admin)/admin/blog/ai-generate/page.tsx` - Admin sayfası
- `components/features/AIBlogGenerator.tsx` - UI component

## 🔒 Güvenlik

- Sadece admin kullanıcıları blog oluşturabilir (NextAuth session kontrolü)
- API rate limiting: Her blog arasında 2 saniye bekleme
- Maksimum 10 blog tek seferde oluşturulabilir

## 📦 Bağımlılıklar

```json
"@google/generative-ai": "^0.21.0"
```

Kurulum:
```bash
npm install
```

## 🎯 Kullanım Senaryoları

1. **Hızlı İçerik Üretimi**: Yeni blog yazıları için hızlı başlangıç
2. **SEO Optimizasyonu**: Her blog otomatik olarak SEO için optimize edilir
3. **Toplu İçerik**: Birden fazla blog yazısını tek seferde oluşturun
4. **Düzenleme**: Oluşturulan blogları düzenleyip yayınlayabilirsiniz

## ⚠️ Notlar

- Oluşturulan bloglar varsayılan olarak **yayınlanmamış** durumda olur
- Blogları oluşturduktan sonra düzenleyip yayınlayabilirsiniz
- Her blog oluşturma işlemi yaklaşık 10-15 saniye sürebilir
- API rate limit'leri nedeniyle çok fazla blog oluştururken dikkatli olun

## 🐛 Sorun Giderme

### "GEMINI_API_KEY environment variable is not set" hatası

`.env` dosyasına `GEMINI_API_KEY` ekleyin veya `lib/gemini.ts` dosyasındaki varsayılan değeri kullanın.

### Blog oluşturma başarısız

- API key'in geçerli olduğundan emin olun
- İnternet bağlantınızı kontrol edin
- Console loglarını kontrol edin

### Slug çakışması

Sistem otomatik olarak benzersiz slug oluşturur (örn: `blog-yazisi-1`, `blog-yazisi-2`).

