# 🔧 Port 3040 Son Çözüm

## ❌ Sorun: PM2 "too many unstable restarts" - Port 3040 hala kullanımda

PM2 durdu çünkü çok fazla başarısız restart denemesi yaptı. Port 3040'ı kullanan process'i bulup durdurmamız gerekiyor.

## 🚀 Kesin Çözüm

### Adım 1: PM2'yi Durdur
```bash
pm2 kill
pm2 delete all
```

### Adım 2: Port 3040'ı Kullanan Process'i Bul
```bash
# Port 3040'ı kullanan process'i bul
sudo lsof -i:3040

# Eğer lsof yoksa:
sudo netstat -tulpn | grep 3040

# veya
sudo ss -tulpn | grep 3040

# veya tüm node process'lerini gör
ps aux | grep node
```

### Adım 3: Process'i Durdur
```bash
# Yöntem 1: fuser (en etkili)
sudo fuser -k 3040/tcp

# Yöntem 2: lsof ile
sudo lsof -ti:3040 | xargs sudo kill -9

# Yöntem 3: Tüm node process'lerini durdur (dikkatli!)
sudo pkill -9 node

# Yöntem 4: Process ID'yi manuel bul ve durdur
# Önce process'i bul:
ps aux | grep node
# Sonra PID'yi al ve durdur:
sudo kill -9 <PID>
```

### Adım 4: Port'un Boş Olduğunu Doğrula
```bash
# Port 3040 boş mu?
sudo lsof -i:3040
# Çıktı olmamalı

# veya
sudo netstat -tulpn | grep 3040
# Çıktı olmamalı
```

### Adım 5: PM2'yi Yeniden Başlat
```bash
cd ~/premiumfoto

# PM2'yi temizle
pm2 kill
pm2 delete all

# PM2'yi yeniden başlat
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
pm2 status

# Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

## 🔥 Tek Komutla Tüm Çözüm

```bash
cd ~/premiumfoto && \
pm2 kill && \
pm2 delete all && \
sudo fuser -k 3040/tcp 2>/dev/null; \
sudo lsof -ti:3040 | xargs sudo kill -9 2>/dev/null; \
sudo pkill -9 node 2>/dev/null; \
sleep 3 && \
sudo lsof -i:3040 && \
pm2 start npm --name "foto-ugur-app" -- start && \
pm2 save && \
pm2 status
```

## 🔍 Process'i Manuel Bulma

Eğer yukarıdaki komutlar çalışmazsa:

```bash
# 1. Port 3040'ı kullanan process'i bul
sudo lsof -i:3040

# Çıktı örneği:
# COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# node    12345 ibrahim   20u  IPv6  123456      0t0  TCP *:3040 (LISTEN)

# 2. PID'yi al (örnek: 12345) ve durdur
sudo kill -9 12345

# 3. Port'un boş olduğunu kontrol et
sudo lsof -i:3040
# Çıktı olmamalı

# 4. PM2'yi başlat
cd ~/premiumfoto
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
```

## 🔄 Alternatif: Farklı Port Kullan

Eğer port 3040'ı başka bir uygulama kullanıyorsa ve durduramıyorsanız, port'u değiştirin:

```bash
# 1. package.json'ı düzenle
nano ~/premiumfoto/package.json
# "start": "next start -p 3041" olarak değiştir

# 2. .env dosyasını düzenle (eğer varsa)
nano ~/premiumfoto/.env
# PORT=3041 ekle

# 3. Nginx config'i güncelle
sudo nano /etc/nginx/sites-available/foto-ugur
# proxy_pass http://localhost:3041; olarak değiştir

# 4. Nginx'i test et ve yeniden yükle
sudo nginx -t
sudo systemctl reload nginx

# 5. PM2'yi yeniden başlat
cd ~/premiumfoto
pm2 delete all
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
pm2 status
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

## 🐛 Yaygın Hatalar

### "lsof: command not found"
```bash
sudo apt-get update
sudo apt-get install lsof
```

### "fuser: command not found"
```bash
sudo apt-get update
sudo apt-get install psmisc
```

### "Permission denied"
```bash
# sudo ile çalıştır
sudo lsof -i:3040
sudo kill -9 <PID>
```

