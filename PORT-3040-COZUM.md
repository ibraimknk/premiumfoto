# 🔧 Port 3040 Kullanımda Sorunu Çözümü

## ❌ Hata: `EADDRINUSE: address already in use :::3040`

Port 3040 başka bir process tarafından kullanılıyor.

## 🔧 Çözüm

### Hızlı Çözüm (Tek Komut)

```bash
# Port 3040'ı kullanan process'i bul ve durdur
sudo lsof -ti:3040 | xargs sudo kill -9

# PM2'deki tüm process'leri temizle
pm2 delete all

# PM2'yi yeniden başlat
cd ~/premiumfoto
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
pm2 status
```

### Adım Adım Çözüm

#### 1. Port 3040'ı Kullanan Process'i Bul
```bash
# Port 3040'ı kullanan process'i bul
sudo lsof -i:3040

# veya
sudo netstat -tulpn | grep 3040

# veya
sudo ss -tulpn | grep 3040
```

#### 2. Process'i Durdur
```bash
# Process ID'yi al (örnek: 12345)
# Sonra durdur:
sudo kill -9 <PID>

# veya tek komutla:
sudo lsof -ti:3040 | xargs sudo kill -9
```

#### 3. PM2 Process'lerini Temizle
```bash
# Tüm PM2 process'lerini durdur
pm2 delete all

# veya sadece foto-ugur-app'i sil
pm2 delete foto-ugur-app
```

#### 4. PM2'yi Yeniden Başlat
```bash
cd ~/premiumfoto
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
pm2 status
```

## 🚀 Tek Komutla Tüm Çözüm

```bash
cd ~/premiumfoto && \
sudo lsof -ti:3040 | xargs sudo kill -9 2>/dev/null; \
pm2 delete all 2>/dev/null; \
pm2 start npm --name "foto-ugur-app" -- start && \
pm2 save && \
pm2 status
```

## 🔍 Sorun Tespiti

### Port Kullanımını Kontrol Et
```bash
# Port 3040'ı kullanan process'i bul
sudo lsof -i:3040

# Çıktı örneği:
# COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# node    12345 ibrahim   20u  IPv6  123456      0t0  TCP *:3040 (LISTEN)
```

### PM2 Process'lerini Kontrol Et
```bash
pm2 list
# Tüm process'lerin durumunu gösterir
```

### PM2 Loglarını Kontrol Et
```bash
pm2 logs foto-ugur-app --lines 50
# Hata mesajlarını gösterir
```

## ⚠️ Önemli Notlar

1. **Kill Komutu:** `kill -9` process'i zorla durdurur. Önce normal `kill` deneyin:
   ```bash
   sudo kill <PID>
   # Eğer çalışmazsa:
   sudo kill -9 <PID>
   ```

2. **PM2 Delete:** `pm2 delete all` tüm PM2 process'lerini siler. Sadece bir process'i silmek için:
   ```bash
   pm2 delete foto-ugur-app
   ```

3. **Port Değiştirme:** Eğer port 3040'ı başka bir uygulama kullanıyorsa, port'u değiştirebilirsiniz:
   ```bash
   # .env dosyasında PORT değiştir
   nano ~/premiumfoto/.env
   # PORT=3041 gibi farklı bir port
   
   # package.json'da start script'ini güncelle
   # "start": "next start -p 3041"
   ```

## 🐛 Yaygın Hatalar

### "lsof: command not found"
```bash
# lsof kurulumu
sudo apt-get install lsof
```

### "Permission denied" Hatası
```bash
# sudo ile çalıştır
sudo lsof -i:3040
sudo kill -9 <PID>
```

### PM2 "Process not found" Hatası
```bash
# PM2 listesini kontrol et
pm2 list

# Eğer process yoksa, başlat
pm2 start npm --name "foto-ugur-app" -- start
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
```

## 🔄 Alternatif Çözüm: Farklı Port Kullan

Eğer port 3040'ı başka bir uygulama kullanıyorsa:

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

# Nginx'i yeniden yükle
sudo nginx -t
sudo systemctl reload nginx

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app
```

