# 🖥️ Sunucu Kurulum Komutları

## 🚀 Tek Komutla Kurulum

```bash
ssh ibrahim@192.168.1.120 "cd ~/premiumfoto && git pull origin main && sudo bash deploy.sh fotougur.com.tr dugunkarem.com dugunkarem.com.tr"
```

## 📋 Adım Adım Kurulum

### 1. Sunucuya Bağlan
```bash
ssh ibrahim@192.168.1.120
```

### 2. Projeyi Hazırla
```bash
cd ~/premiumfoto
git pull origin main
```

### 3. Deploy Script'ini Çalıştır
```bash
sudo bash deploy.sh fotougur.com.tr dugunkarem.com dugunkarem.com.tr
```

Bu komut:
- ✅ Tüm sistem paketlerini kurar/günceller
- ✅ Node.js 20 kurar
- ✅ PM2 kurar
- ✅ NPM paketlerini kurar
- ✅ Prisma veritabanını oluşturur
- ✅ Seed verilerini yükler
- ✅ Production build oluşturur
- ✅ PM2 ile uygulamayı başlatır
- ✅ Nginx'i 3 domain için yapılandırır
- ✅ `.env` dosyasını `NEXT_PUBLIC_SITE_URLS` ile yapılandırır

### 4. SSL Sertifikası Kur (Kurulum Sonrası)
```bash
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d www.fotougur.com.tr \
  -d dugunkarem.com \
  -d www.dugunkarem.com \
  -d dugunkarem.com.tr \
  -d www.dugunkarem.com.tr
```

## ✅ Kontrol Komutları

```bash
# PM2 durumu
pm2 status

# PM2 logları
pm2 logs foto-ugur-app --lines 20

# Nginx test
sudo nginx -t

# Nginx durumu
sudo systemctl status nginx

# Domain'lerin çalıştığını kontrol et
curl -I http://fotougur.com.tr
curl -I http://dugunkarem.com
curl -I http://dugunkarem.com.tr
```

## 🔄 Güncelleme Komutları

```bash
cd ~/premiumfoto
git pull origin main
npm ci
npx prisma generate
npm run build
pm2 restart foto-ugur-app
```

## 🐛 Sorun Giderme Komutları

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

# Eğer 50M değilse:
sudo sed -i 's/client_max_body_size .*/client_max_body_size 50M;/g' /etc/nginx/sites-available/foto-ugur
sudo nginx -t
sudo systemctl reload nginx
```

### PM2 Yeniden Başlatma
```bash
cd ~/premiumfoto
pm2 restart foto-ugur-app
pm2 logs foto-ugur-app --lines 20
```

### Nginx Yeniden Yükleme
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 📊 Site Haritası

3 domain için site haritası otomatik oluşturulur:
- URL: `https://fotougur.com.tr/sitemap.xml`

Admin panelden göndermek için:
1. `https://fotougur.com.tr/admin/settings` sayfasına gidin
2. "SEO" sekmesine tıklayın
3. "Site Haritasını Arama Motorlarına Gönder" butonuna tıklayın

## 🎯 Domain Yapılandırması

Kurulum sonrası şu domain'ler çalışır:
- ✅ fotougur.com.tr
- ✅ www.fotougur.com.tr
- ✅ dugunkarem.com
- ✅ www.dugunkarem.com
- ✅ dugunkarem.com.tr
- ✅ www.dugunkarem.com.tr

Tüm domain'ler aynı uygulamaya yönlendirilir (port 3040).

