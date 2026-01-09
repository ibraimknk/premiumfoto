# 🚀 Sunucu Kurulum Adımları (Detaylı)

## ⚠️ Önce Yapılması Gerekenler

### 1. SSH Bağlantısı

**Sorun:** `Permission denied (publickey)`

**Çözüm Seçenekleri:**

**A) Şifre ile Bağlan (Eğer mümkünse)**
```bash
ssh ibrahim@192.168.1.120
# Şifre isteyecek
```

**B) SSH Key Ekleme**
```bash
# Yerel bilgisayarda (Windows PowerShell)
ssh-keygen -t rsa -b 4096
# Enter'a bas (varsayılan konum: C:\Users\DELL\.ssh\id_rsa)

# SSH key'i sunucuya kopyala (eğer ssh-copy-id yoksa)
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh ibrahim@192.168.1.120 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

**C) Root ile Bağlan (Eğer mümkünse)**
```bash
ssh root@192.168.1.120
```

### 2. DNS Kayıtlarını Hazırlama

SSL sertifikası için domain'lerin DNS kayıtları olmalı:

**Gerekli DNS A Kayıtları:**
```
fotougur.com.tr          → A → 95.70.203.118
www.fotougur.com.tr      → A → 95.70.203.118
dugunkarem.com           → A → 95.70.203.118
www.dugunkarem.com       → A → 95.70.203.118
dugunkarem.com.tr        → A → 95.70.203.118
www.dugunkarem.com.tr    → A → 95.70.203.118
```

**DNS Kontrolü (Yerel Bilgisayarda):**
```powershell
# PowerShell'de
nslookup fotougur.com.tr
nslookup www.fotougur.com.tr
nslookup dugunkarem.com
nslookup www.dugunkarem.com
nslookup dugunkarem.com.tr
nslookup www.dugunkarem.com.tr
```

## 📋 Sunucuda Kurulum Adımları

### Adım 1: Sunucuya Bağlan

```bash
ssh ibrahim@192.168.1.120
# veya
ssh root@192.168.1.120
```

### Adım 2: Dizini Oluştur ve Projeyi Klonla

```bash
# Dizini oluştur
mkdir -p ~/premiumfoto
cd ~/premiumfoto

# Git repository'den klonla
git clone https://github.com/ibraimknk/premiumfoto.git .

# Deploy script'ine çalıştırma izni ver
chmod +x deploy.sh
```

### Adım 3: Deploy Script'ini Çalıştır

```bash
sudo bash deploy.sh fotougur.com.tr dugunkarem.com dugunkarem.com.tr
```

**Script şunları yapacak:**
- ✅ Sistem paketlerini kurar/günceller
- ✅ Node.js 20 kurar
- ✅ PM2 kurar
- ✅ NPM paketlerini kurar
- ✅ Prisma veritabanını oluşturur
- ✅ Seed verilerini yükler
- ✅ Production build oluşturur
- ✅ PM2 ile uygulamayı başlatır
- ✅ Nginx'i 3 domain için yapılandırır
- ✅ `.env` dosyasını yapılandırır

### Adım 4: DNS Kayıtlarını Kontrol Et

```bash
# DNS kayıtlarını kontrol et
nslookup fotougur.com.tr
nslookup www.fotougur.com.tr
nslookup dugunkarem.com
nslookup www.dugunkarem.com
nslookup dugunkarem.com.tr
nslookup www.dugunkarem.com.tr

# Tüm domain'ler 95.70.203.118 IP'sine yönlendirilmeli
```

### Adım 5: SSL Sertifikası Kur (DNS Hazır Olduktan Sonra)

**DNS kayıtları hazır olduktan sonra (genellikle 24 saat içinde):**

```bash
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d www.fotougur.com.tr \
  -d dugunkarem.com \
  -d www.dugunkarem.com \
  -d dugunkarem.com.tr \
  -d www.dugunkarem.com.tr
```

**Eğer `www` kayıtları yoksa, önce ana domain'ler için:**

```bash
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d dugunkarem.com \
  -d dugunkarem.com.tr
```

## ✅ Kurulum Sonrası Kontrol

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

## 🔄 Güncelleme

```bash
cd ~/premiumfoto
git pull origin main
npm ci
npx prisma generate
npm run build
pm2 restart foto-ugur-app
```

## 🐛 Sorun Giderme

### SSH Bağlantı Sorunu
```bash
# SSH key oluştur (yerel bilgisayarda)
ssh-keygen -t rsa -b 4096

# Sunucuya kopyala
ssh-copy-id ibrahim@192.168.1.120
```

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

## 📝 Önemli Notlar

1. **DNS Yayılımı:** DNS kayıtları değiştiğinde 24-48 saat içinde yayılır
2. **SSL Sertifikası:** DNS hazır olmadan SSL sertifikası alınamaz
3. **www Kayıtları:** Eğer `www` kayıtları yoksa, önce ana domain'ler için SSL alın
4. **Firewall:** Port 80 ve 443'in açık olduğundan emin olun

