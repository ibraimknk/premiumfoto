# 🔧 Port 3040 Kesin Çözüm

## ❌ Sorun: Port 3040 sürekli kullanımda

PM2 sürekli yeniden başlamaya çalışıyor ama port zaten kullanımda.

## 🚀 Kesin Çözüm (Tüm Adımlar)

### 1. PM2'yi Durdur
```bash
pm2 stop all
pm2 delete all
```

### 2. Port 3040'ı Kullanan Tüm Process'leri Bul ve Durdur
```bash
# Port 3040'ı kullanan process'leri bul
sudo lsof -i:3040

# Eğer lsof yoksa:
sudo netstat -tulpn | grep 3040

# veya
sudo ss -tulpn | grep 3040

# Tüm process'leri durdur (tek komut)
sudo fuser -k 3040/tcp

# veya
sudo lsof -ti:3040 | xargs sudo kill -9
```

### 3. Node Process'lerini Kontrol Et
```bash
# Tüm node process'lerini bul
ps aux | grep node

# Tüm node process'lerini durdur (dikkatli!)
pkill -9 node
```

### 4. Port'un Boş Olduğunu Doğrula
```bash
# Port 3040 boş mu kontrol et
sudo lsof -i:3040
# Çıktı olmamalı
```

### 5. PM2'yi Temizle ve Yeniden Başlat
```bash
cd ~/premiumfoto

# PM2'yi tamamen temizle
pm2 kill
pm2 delete all

# PM2'yi yeniden başlat
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
pm2 status
```

## 🔥 Tek Komutla Tüm Çözüm

```bash
cd ~/premiumfoto && \
pm2 kill && \
sudo fuser -k 3040/tcp 2>/dev/null; \
sudo lsof -ti:3040 | xargs sudo kill -9 2>/dev/null; \
pkill -9 node 2>/dev/null; \
sleep 2 && \
pm2 start npm --name "foto-ugur-app" -- start && \
pm2 save && \
pm2 status
```

## 🔍 Alternatif: Farklı Port Kullan

Eğer port 3040'ı başka bir uygulama kullanıyorsa, port'u değiştirebilirsiniz:

```bash
# .env dosyasını düzenle
nano ~/premiumfoto/.env
# PORT=3041 ekle veya değiştir

# package.json'ı düzenle
nano ~/premiumfoto/package.json
# "start": "next start -p 3041" olarak değiştir

# Nginx config'i güncelle
sudo nano /etc/nginx/sites-available/foto-ugur
# proxy_pass http://localhost:3041; olarak değiştir

# Nginx'i test et ve yeniden yükle
sudo nginx -t
sudo systemctl reload nginx

# PM2'yi yeniden başlat
cd ~/premiumfoto
pm2 delete all
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
```

## ✅ Doğrulama

```bash
# Port 3040 boş mu?
sudo lsof -i:3040
# Çıktı olmamalı

# PM2 çalışıyor mu?
pm2 status
# foto-ugur-app "online" olmalı

# Uygulama erişilebilir mi?
curl -I http://localhost:3040
# HTTP 200 dönmeli

# Loglar temiz mi?
pm2 logs foto-ugur-app --lines 10
# Hata olmamalı
```

