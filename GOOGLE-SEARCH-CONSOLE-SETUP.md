# 🔍 Google Search Console API Kurulumu ve Kullanımı

`google.py` script'i, Google Search Console API kullanarak sitemap'ten URL'leri alıp Google'da indexlenen blog sayfalarını bulur.

## 📋 Gereksinimler

1. **Python 3.7+**
2. **Gerekli Python paketleri**:
   ```bash
   pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client beautifulsoup4 requests
   ```

## 🔧 Kurulum

### 1. Google Cloud Console'da Proje Oluşturma

1. **Google Cloud Console**'a gidin: https://console.cloud.google.com/
2. Yeni bir proje oluşturun veya mevcut projeyi seçin
3. **APIs & Services > Library**'ye gidin
4. **"Google Search Console API"**'yi arayın ve etkinleştirin

### 2. OAuth 2.0 Credentials Oluşturma

1. **APIs & Services > Credentials**'e gidin
2. **+ CREATE CREDENTIALS > OAuth client ID** seçin
3. **Application type**: **Desktop app** seçin
4. **Name**: "Blog Index Checker" gibi bir isim verin
5. **CREATE** butonuna tıklayın
6. **JSON** dosyasını indirin ve `client_secret.json` olarak kaydedin

### 3. Search Console'da Site Ekleme

1. **Google Search Console**'a gidin: https://search.google.com/search-console
2. Sitenizi ekleyin (örn: `https://fotougur.com.tr/`)
3. Doğrulama yapın (DNS, HTML dosyası, vs.)

## 🚀 Kullanım

### Temel Kullanım

```bash
python google.py \
  --client-secret client_secret.json \
  --site-url https://fotougur.com.tr/ \
  --sitemap https://fotougur.com.tr/sitemap.xml
```

### Birden Fazla Sitemap

```bash
python google.py \
  --client-secret client_secret.json \
  --site-url https://fotougur.com.tr/ \
  --sitemap https://fotougur.com.tr/sitemap.xml \
  --sitemap https://fotougur.com.tr/blog-sitemap.xml
```

### Sadece Blog URL'lerini Filtrele

```bash
python google.py \
  --client-secret client_secret.json \
  --site-url https://fotougur.com.tr/ \
  --sitemap https://fotougur.com.tr/sitemap.xml \
  --out blog_indexed_urls.csv
```

Sonra CSV'den sadece `/blog/` içeren URL'leri filtreleyin.

### Rate Limiting

```bash
python google.py \
  --client-secret client_secret.json \
  --site-url https://fotougur.com.tr/ \
  --sitemap https://fotougur.com.tr/sitemap.xml \
  --sleep 0.5  # Her istek arasında 0.5 saniye bekle
```

### Test İçin Limit

```bash
python google.py \
  --client-secret client_secret.json \
  --site-url https://fotougur.com.tr/ \
  --sitemap https://fotougur.com.tr/sitemap.xml \
  --max 10  # Sadece ilk 10 URL'i kontrol et
```

## 📊 Çıktı

Script, `indexed_urls.csv` dosyası oluşturur:

```csv
url,verdict,coverageState,lastCrawlTime
https://fotougur.com.tr/blog/dugun-fotografciligi,PASS,Submitted and indexed,2026-01-02T10:30:00Z
https://fotougur.com.tr/blog/urun-fotografciligi,PASS,Submitted and indexed,2026-01-02T09:15:00Z
```

## 🔄 TypeScript Script ile Entegrasyon

CSV dosyasını okuyup TypeScript script'imizle blog oluşturmak için:

```bash
# 1. Google'da indexlenen blog URL'lerini bul
python google.py \
  --client-secret client_secret.json \
  --site-url https://fotougur.com.tr/ \
  --sitemap https://fotougur.com.tr/sitemap.xml \
  --out blog_indexed_urls.csv

# 2. CSV'den sadece blog URL'lerini çıkar
grep "/blog/" blog_indexed_urls.csv > blog_urls_only.csv

# 3. TypeScript script'i CSV'den okuyacak şekilde güncelle (gelecekte)
```

## ⚠️ Önemli Notlar

1. **İlk Çalıştırma**: İlk çalıştırmada tarayıcı açılacak ve Google hesabınızla giriş yapmanız istenecek
2. **Rate Limiting**: Google API rate limit'leri var, `--sleep` parametresi ile kontrol edin
3. **Quota**: Günlük API quota limit'iniz olabilir
4. **Güvenlik**: `client_secret.json` dosyasını asla Git'e commit etmeyin!

## 🐛 Sorun Giderme

### "ModuleNotFoundError: No module named 'google_auth_oauthlib'"

```bash
pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client beautifulsoup4 requests
```

### "403 Forbidden" hatası

- Search Console API'nin etkinleştirildiğinden emin olun
- OAuth credentials'ın doğru olduğundan emin olun
- Site'nin Search Console'da doğrulandığından emin olun

### "Rate limit exceeded" hatası

`--sleep` parametresini artırın:
```bash
--sleep 1.0  # Her istek arasında 1 saniye bekle
```

## 📚 İlgili Dosyalar

- `google.py` - Ana Python script
- `scripts/regenerate-blogs-from-google.ts` - TypeScript blog oluşturma script'i
- `GOOGLE-BLOG-REGENERATE.md` - Blog oluşturma dokümantasyonu

