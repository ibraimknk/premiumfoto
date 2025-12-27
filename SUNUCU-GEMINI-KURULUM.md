# 🤖 Sunucuya Gemini AI Blog Özelliği Kurulumu

## 🚀 Hızlı Kurulum (Tek Komut)

Sunucuda şu komutu çalıştırın:

```bash
cd ~/premiumfoto && \
git pull origin main && \
npm ci --production=false && \
if ! grep -q "GEMINI_API_KEY" .env; then echo 'GEMINI_API_KEY="AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"' >> .env; fi && \
npm run build && \
pm2 restart foto-ugur-app && \
pm2 status
```

## 📋 Adım Adım Kurulum

### 1. Sunucuya Bağlan

```bash
ssh ibrahim@192.168.1.120
# veya
ssh root@192.168.1.120
```

### 2. Proje Dizinine Git

```bash
cd ~/premiumfoto
# veya root kullanıcısıysanız
cd /home/ibrahim/premiumfoto
```

### 3. GitHub'dan Güncellemeleri Çek

```bash
git pull origin main
```

### 4. Yeni Paketleri Kur

```bash
npm ci --production=false
```

Bu komut `@google/generative-ai` paketini kuracaktır.

### 5. .env Dosyasına GEMINI_API_KEY Ekle

```bash
# .env dosyasını kontrol et
cat .env | grep GEMINI_API_KEY

# Eğer yoksa ekle
if ! grep -q "GEMINI_API_KEY" .env; then
    echo 'GEMINI_API_KEY="AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"' >> .env
    echo "✅ GEMINI_API_KEY eklendi"
fi
```

### 6. Projeyi Build Et

```bash
npm run build
```

### 7. PM2'yi Yeniden Başlat

```bash
pm2 restart foto-ugur-app
```

### 8. Durumu Kontrol Et

```bash
# PM2 durumu
pm2 status

# Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

## 🔄 Güncelleme Script'i Kullanma

Eğer `deploy-update.sh` script'iniz varsa:

```bash
cd ~/premiumfoto
bash deploy-update.sh
```

Script otomatik olarak:
- ✅ Git pull yapar
- ✅ npm ci ile paketleri kurar
- ✅ GEMINI_API_KEY'i .env'ye ekler (yoksa)
- ✅ Build yapar
- ✅ PM2'yi restart eder

## ✅ Doğrulama

### 1. Paket Kontrolü

```bash
npm list @google/generative-ai
```

Çıktı: `@google/generative-ai@0.21.0` görünmeli

### 2. .env Kontrolü

```bash
cat .env | grep GEMINI_API_KEY
```

Çıktı: `GEMINI_API_KEY="AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"` görünmeli

### 3. Build Kontrolü

```bash
ls -la .next
```

`.next` dizini mevcut olmalı

### 4. PM2 Kontrolü

```bash
pm2 status
```

`foto-ugur-app` "online" olmalı

### 5. Admin Panel Kontrolü

1. Tarayıcıda admin paneline giriş yapın
2. **Blog Yazıları** sayfasına gidin (`/admin/blog`)
3. **"AI ile Oluştur"** butonunu görüyor musunuz? ✅

## 🐛 Sorun Giderme

### "Module not found: @google/generative-ai"

```bash
cd ~/premiumfoto
npm install @google/generative-ai
npm run build
pm2 restart foto-ugur-app
```

### "GEMINI_API_KEY environment variable is not set"

```bash
# .env dosyasına ekle
echo 'GEMINI_API_KEY="AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"' >> .env

# PM2'yi restart et
pm2 restart foto-ugur-app
```

### Build Hatası

```bash
# Cache'i temizle
rm -rf .next node_modules/.cache

# Tekrar build et
npm run build

# PM2'yi restart et
pm2 restart foto-ugur-app
```

### PM2 Restart Başarısız

```bash
# PM2'yi durdur
pm2 stop foto-ugur-app

# PM2'yi sil
pm2 delete foto-ugur-app

# Yeniden başlat
cd ~/premiumfoto
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
```

## 📝 Önemli Notlar

1. **API Key**: API key `deploy.sh` script'ine eklendi, yeni kurulumlarda otomatik eklenir
2. **Mevcut Kurulum**: Mevcut sunucuda manuel olarak `.env` dosyasına eklemeniz gerekebilir
3. **Build**: Her güncellemeden sonra `npm run build` yapılmalı
4. **PM2**: PM2 restart edilmeden değişiklikler aktif olmaz

## 🎯 Kullanım

Kurulum tamamlandıktan sonra:

1. Admin paneline giriş yapın
2. **Blog Yazıları** → **"AI ile Oluştur"** butonuna tıklayın
3. Blog sayısını girin (1-10)
4. İsteğe bağlı konu belirtin
5. **"Blog Yazılarını Oluştur"** butonuna tıklayın

Her blog yaklaşık 10-15 saniye sürebilir.

