# 🚀 Hızlı Kurulum (3 Domain)

## 📋 Domain'ler

- **Domain 1:** fotougur.com.tr
- **Domain 2:** dugunkarem.com
- **Domain 3:** dugunkarem.com.tr

## 🔧 Tek Komutla Kurulum

Sunucuya bağlandıktan sonra:

```bash
ssh ibrahim@192.168.1.120
cd ~/premiumfoto
git pull origin main
sudo bash deploy.sh fotougur.com.tr dugunkarem.com dugunkarem.com.tr
```

## 📝 Adım Adım Kurulum

### 1. Sunucuya Bağlan
```bash
ssh ibrahim@192.168.1.120
```

### 2. Projeyi Hazırla
```bash
mkdir -p ~/premiumfoto
cd ~/premiumfoto

# Git repository'den klonla (eğer yoksa)
if [ ! -d ".git" ]; then
    git clone https://github.com/ibraimknk/premiumfoto.git .
fi

# Son değişiklikleri çek
git pull origin main
```

### 3. Deploy Script'ini Çalıştır

**Seçenek 1: Parametre ile (Önerilen)**
```bash
sudo bash deploy.sh fotougur.com.tr dugunkarem.com dugunkarem.com.tr
```

**Seçenek 2: İnteraktif**
```bash
sudo bash deploy.sh
# Domain'leri tek tek girin
```

### 4. SSL Sertifikası Kur

Kurulum tamamlandıktan sonra:

```bash
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d www.fotougur.com.tr \
  -d dugunkarem.com \
  -d www.dugunkarem.com \
  -d dugunkarem.com.tr \
  -d www.dugunkarem.com.tr
```

## ✅ Kurulum Sonrası Kontrol

```bash
# PM2 durumu
pm2 status

# PM2 logları
pm2 logs foto-ugur-app --lines 20

# Nginx test
sudo nginx -t

# Domain'lerin çalıştığını kontrol et
curl -I http://fotougur.com.tr
curl -I http://dugunkarem.com
curl -I http://dugunkarem.com.tr
```

## 🔍 Sorun Giderme

### Build Hatası
```bash
cd ~/premiumfoto
rm -rf .next
npm run build
pm2 restart foto-ugur-app
```

### Upload Hatası (HTTP 413)
```bash
# Nginx limit kontrolü
cat /etc/nginx/sites-available/foto-ugur | grep client_max_body_size
# Çıktı: client_max_body_size 50M; olmalı
```

### PM2 Yeniden Başlatma
```bash
cd ~/premiumfoto
pm2 restart foto-ugur-app
pm2 logs foto-ugur-app --lines 20
```

## 📊 Site Haritası

3 domain için site haritası otomatik oluşturulur:
- URL: `https://fotougur.com.tr/sitemap.xml`
- Tüm domain'ler için URL'ler tek sitemap'te birleştirilir

Admin panelden site haritasını arama motorlarına göndermek için:
1. `/admin/settings` sayfasına gidin
2. "SEO" sekmesine tıklayın
3. "Site Haritasını Arama Motorlarına Gönder" butonuna tıklayın

## 🎯 Özet

- ✅ 3 domain otomatik yapılandırılır
- ✅ Nginx 6 domain için ayarlanır (her domain + www)
- ✅ `.env` dosyası `NEXT_PUBLIC_SITE_URLS` ile yapılandırılır
- ✅ SSL sertifikası kurulabilir
- ✅ Site haritası otomatik oluşturulur

