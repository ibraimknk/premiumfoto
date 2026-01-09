# 🚀 Sunucu Kurulum Kılavuzu (3 Domain)

## 📋 Ön Gereksinimler

- Ubuntu/Debian sunucu
- Root veya sudo yetkisi
- 3 domain adresi (DNS kayıtları sunucuya yönlendirilmiş olmalı)
- SSH erişimi

## 🔧 Kurulum Adımları

### 1. Sunucuya Bağlanma

```bash
ssh ibrahim@192.168.1.120
```

### 2. Projeyi İndirme veya Klonlama

```bash
# Eğer dizin yoksa oluştur
mkdir -p ~/premiumfoto
cd ~/premiumfoto

# Git repository'den klonla (eğer yoksa)
if [ ! -d ".git" ]; then
    git clone https://github.com/ibraimknk/premiumfoto.git .
fi

# Son değişiklikleri çek
git pull origin main
```

### 3. Deploy Script'ini Çalıştırma

```bash
# Root yetkisi ile çalıştır
sudo bash deploy.sh
```

Script çalıştığında **3 domain adresi** isteyecek:
- Domain 1: (örn: `fotougur.com`)
- Domain 2: (örn: `www.fotougur.com`)
- Domain 3: (örn: `foto-ugur.com`)

**Not:** Domain'leri `www` olmadan girin, script otomatik olarak `www` versiyonlarını da ekler.

### 4. Otomatik Yapılanlar

Script şunları otomatik yapar:
- ✅ Sistem paketlerini günceller
- ✅ Node.js 20 kurar
- ✅ PM2 kurar
- ✅ NPM paketlerini kurar
- ✅ Prisma veritabanını oluşturur
- ✅ Seed verilerini yükler
- ✅ Production build oluşturur
- ✅ PM2 ile uygulamayı başlatır
- ✅ Nginx konfigürasyonunu 3 domain için yapar
- ✅ `.env` dosyasını `NEXT_PUBLIC_SITE_URLS` ile yapılandırır

### 5. SSL Sertifikası Kurulumu

Kurulum tamamlandıktan sonra SSL sertifikası kurun:

```bash
sudo certbot --nginx \
  -d domain1.com \
  -d www.domain1.com \
  -d domain2.com \
  -d www.domain2.com \
  -d domain3.com \
  -d www.domain3.com
```

**Örnek:**
```bash
sudo certbot --nginx \
  -d fotougur.com \
  -d www.fotougur.com \
  -d dugunkarem.com \
  -d www.dugunkarem.com \
  -d foto-ugur.com \
  -d www.foto-ugur.com
```

### 6. Doğrulama

```bash
# PM2 durumunu kontrol et
pm2 status

# PM2 loglarını kontrol et
pm2 logs foto-ugur-app --lines 50

# Nginx konfigürasyonunu test et
sudo nginx -t

# Nginx durumunu kontrol et
sudo systemctl status nginx
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

Nginx zaten 50M olarak ayarlanmış olmalı. Kontrol edin:

```bash
cat /etc/nginx/sites-available/foto-ugur | grep client_max_body_size
# Çıktı: client_max_body_size 50M; olmalı

# Eğer farklıysa:
sudo sed -i 's/client_max_body_size .*/client_max_body_size 50M;/g' /etc/nginx/sites-available/foto-ugur
sudo nginx -t
sudo systemctl reload nginx
```

### Domain Erişim Sorunu

```bash
# Nginx server_name kontrolü
cat /etc/nginx/sites-available/foto-ugur | grep server_name

# DNS kontrolü (her domain için)
nslookup domain1.com
nslookup domain2.com
nslookup domain3.com
```

### PM2 Uygulama Yeniden Başlatma

```bash
cd ~/premiumfoto
pm2 restart foto-ugur-app
pm2 logs foto-ugur-app --lines 20
```

## 📝 Önemli Dosyalar

- **Uygulama Dizini:** `~/premiumfoto`
- **Nginx Config:** `/etc/nginx/sites-available/foto-ugur`
- **PM2 App:** `foto-ugur-app`
- **Port:** `3040`
- **.env Dosyası:** `~/premiumfoto/.env`

## 🔄 Güncelleme

Sunucuda güncelleme yapmak için:

```bash
cd ~/premiumfoto
git pull origin main
npm ci
npx prisma generate
npm run build
pm2 restart foto-ugur-app
```

## 📊 Site Haritası ve SEO

3 domain için site haritası otomatik oluşturulur:
- URL: `https://domain1.com/sitemap.xml`
- Tüm domain'ler için URL'ler tek sitemap'te birleştirilir

Admin panelden site haritasını arama motorlarına göndermek için:
1. `/admin/settings` sayfasına gidin
2. "SEO" sekmesine tıklayın
3. "Site Haritasını Arama Motorlarına Gönder" butonuna tıklayın

## ✅ Kurulum Sonrası Kontrol Listesi

- [ ] 3 domain de erişilebilir
- [ ] SSL sertifikaları kurulu
- [ ] Admin paneline giriş yapılabiliyor (`/admin/login`)
- [ ] Dosya yükleme çalışıyor
- [ ] Site haritası oluşturuldu (`/sitemap.xml`)
- [ ] PM2 uygulama çalışıyor (`pm2 status`)
- [ ] Nginx çalışıyor (`sudo systemctl status nginx`)

## 🆘 Destek

Sorun yaşarsanız:
1. PM2 loglarını kontrol edin: `pm2 logs foto-ugur-app`
2. Nginx loglarını kontrol edin: `sudo tail -f /var/log/nginx/error.log`
3. Build loglarını kontrol edin: `npm run build`

