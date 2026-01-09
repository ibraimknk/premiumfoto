# 🔧 Port 3040 Sorun Çözümü

## ❌ Sorun

- `sudo lsof -i:3040` → Çıktı yok (port 3040'da process yok)
- PM2 "online" görünüyor ama port dinlemiyor

## 🔍 Sorun Tespiti

### 1. PM2 Loglarını Kontrol Et

```bash
# PM2 loglarını kontrol et
pm2 logs foto-ugur-app --lines 50

# Hata var mı kontrol et
pm2 logs foto-ugur-app --err --lines 50
```

### 2. Uygulama Durumunu Kontrol Et

```bash
# PM2 detaylı durum
pm2 describe foto-ugur-app

# Process ID'yi al
pm2 list

# Process'in çalıştığını kontrol et
ps aux | grep node
```

### 3. Port Kontrolü

```bash
# Tüm portları kontrol et
sudo netstat -tulpn | grep 3040
# veya
sudo ss -tulpn | grep 3040

# Node process'lerini kontrol et
ps aux | grep node
```

## 🚀 Çözüm

### Adım 1: PM2'yi Durdur ve Yeniden Başlat

```bash
cd ~/premiumfoto

# PM2'yi durdur
pm2 stop foto-ugur-app

# PM2'yi sil
pm2 delete foto-ugur-app

# package.json kontrolü
cat package.json | grep '"start"'
# Çıktı: "start": "next start -p 3040", olmalı

# PM2'yi yeniden başlat
pm2 start npm --name "foto-ugur-app" -- start
pm2 save

# Durumu kontrol et
pm2 status

# Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

### Adım 2: Port 3040 Kontrolü

```bash
# Port 3040'ı kontrol et
sudo lsof -i:3040

# Eğer hala boşsa, build kontrolü
cd ~/premiumfoto
ls -la .next

# Build yoksa, build yap
npm run build
```

### Adım 3: Manuel Test

```bash
# Uygulamayı manuel başlat (test için)
cd ~/premiumfoto
npm start

# Başka bir terminal'de port kontrolü
sudo lsof -i:3040
```

## 🔥 Tek Komutla Çözüm

```bash
cd ~/premiumfoto && \
pm2 stop foto-ugur-app && \
pm2 delete foto-ugur-app && \
cat package.json | grep '"start"' && \
pm2 start npm --name "foto-ugur-app" -- start && \
pm2 save && \
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
```

## 🐛 Yaygın Sorunlar

### "Port already in use" Hatası

```bash
# Port 3040'ı kullanan process'i bul
sudo lsof -i:3040

# Process'i durdur
sudo kill -9 <PID>
```

### "Build not found" Hatası

```bash
# Build yap
cd ~/premiumfoto
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

