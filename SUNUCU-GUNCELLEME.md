# 🔄 Sunucu Güncelleme

## 📋 Durum

- ✅ `package.json` yerelde güncellendi (port 3040)
- ✅ `deploy.sh` yerelde güncellendi (port 3040)
- ❌ Değişiklikler henüz sunucuya gitmedi

## 🚀 Sunucuya Güncelleme

### 1. Yerelde GitHub'a Push

```bash
# Değişiklikleri kontrol et
git status

# Değişiklikleri ekle
git add package.json deploy.sh

# Commit
git commit -m "Port 3040'a geri döndürüldü"

# GitHub'a push
git push origin main
```

### 2. Sunucuda Pull

```bash
cd ~/premiumfoto

# Son değişiklikleri çek
git pull origin main

# package.json kontrolü
cat package.json | grep '"start"'
# Çıktı: "start": "next start -p 3040", olmalı
```

### 3. PM2'yi Yeniden Başlat

```bash
cd ~/premiumfoto

# PM2'yi durdur
pm2 stop foto-ugur-app

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app

# Durumu kontrol et
pm2 status

# Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

## 🔥 Tek Komutla Tüm İşlemler (Sunucuda)

```bash
cd ~/premiumfoto && \
git pull origin main && \
cat package.json | grep '"start"' && \
pm2 restart foto-ugur-app && \
pm2 status
```

## ✅ Doğrulama

```bash
# package.json kontrolü
cat package.json | grep '"start"'
# Çıktı: "start": "next start -p 3040", olmalı

# Port 3040 kontrolü
sudo lsof -i:3040
# node process görünmeli

# PM2 durumu
pm2 status
# foto-ugur-app "online" olmalı

# Uygulama erişilebilir mi?
curl -I http://localhost:3040
# HTTP 200 dönmeli
```
