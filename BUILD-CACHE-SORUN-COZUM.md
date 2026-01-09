# 🔧 Build Cache Sorunu Çözümü

## ❌ Sorun

- ✅ Uygulama port 3040'da başlatılmış ("Ready")
- ❌ "Failed to find Server Action" hatası
- ❌ Port 3040'da process görünmüyor
- ⚠️ Build cache sorunu olabilir

## 🚀 Çözüm

### Adım 1: Build Cache'i Temizle ve Yeniden Build

```bash
cd ~/premiumfoto

# PM2'yi durdur
pm2 stop foto-ugur-app

# Build cache'i temizle
rm -rf .next

# Node modules cache'i temizle (opsiyonel)
rm -rf node_modules/.cache

# Yeniden build
npm run build

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app

# 3 saniye bekle
sleep 3

# Port 3040 kontrolü
sudo lsof -i:3040

# Durumu kontrol et
pm2 status

# Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

### Adım 2: Eğer Hala Çalışmazsa - Tam Temizlik

```bash
cd ~/premiumfoto

# PM2'yi durdur
pm2 stop foto-ugur-app
pm2 delete foto-ugur-app

# Build cache'i temizle
rm -rf .next

# Node modules cache'i temizle
rm -rf node_modules/.cache

# Yeniden build
npm run build

# PM2'yi yeniden başlat
pm2 start npm --name "foto-ugur-app" -- start
pm2 save

# 3 saniye bekle
sleep 3

# Port 3040 kontrolü
sudo lsof -i:3040

# Durumu kontrol et
pm2 status
```

## 🔥 Tek Komutla Çözüm

```bash
cd ~/premiumfoto && \
pm2 stop foto-ugur-app && \
rm -rf .next node_modules/.cache && \
npm run build && \
pm2 restart foto-ugur-app && \
sleep 3 && \
sudo lsof -i:3040 && \
pm2 status
```

## ✅ Doğrulama

```bash
# Port 3040 kontrolü
sudo lsof -i:3040
# node process görünmeli

# PM2 durumu
pm2 status
# foto-ugur-app "online" olmalı

# Uygulama erişilebilir mi?
curl -I http://localhost:3040
# HTTP 200 dönmeli

# Nginx üzerinden test
curl -I http://localhost
# HTTP 200 dönmeli

# Loglar temiz mi?
pm2 logs foto-ugur-app --lines 10
# Hata olmamalı
```

## 🐛 Yaygın Sorunlar

### "Port already in use" Hatası

```bash
# Port 3040'ı kullanan process'i bul
sudo lsof -i:3040

# Process'i durdur
sudo kill -9 <PID>
```

### "Build failed" Hatası

```bash
# Node modules'ü temizle ve yeniden kur
rm -rf node_modules package-lock.json
npm install
npm run build
```

### PM2 "errored" Durumu

```bash
# PM2 loglarını kontrol et
pm2 logs foto-ugur-app --err --lines 50

# PM2'yi temizle ve yeniden başlat
pm2 delete foto-ugur-app
pm2 start npm --name "foto-ugur-app" -- start
```

