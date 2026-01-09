# 🔧 Port 3040 Final Çözüm

## ❌ Sorun: PM2'de iki process var, biri errored

PM2'de birden fazla process var ve port 3040 hala kullanımda.

## 🚀 Kesin Çözüm

### Adım 1: PM2'deki Tüm Process'leri Temizle
```bash
pm2 kill
pm2 delete all
pm2 flush  # Logları temizle
```

### Adım 2: Port 3040'ı Kullanan Process'i Bul ve Durdur
```bash
# Port 3040'ı kullanan process'i bul
sudo lsof -i:3040

# Eğer çıktı varsa, PID'yi al ve durdur
# Örnek çıktı:
# COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# node    38809 ibrahim   20u  IPv6  123456      0t0  TCP *:3040 (LISTEN)

# PID'yi durdur (örnek: 38809)
sudo kill -9 38809

# veya fuser ile
sudo fuser -k 3040/tcp

# Tüm node process'lerini durdur
sudo pkill -9 node
```

### Adım 3: Port'un Boş Olduğunu Doğrula
```bash
# Port 3040 boş mu?
sudo lsof -i:3040
# Çıktı olmamalı

# veya ss ile
sudo ss -tulpn | grep 3040
# Çıktı olmamalı
```

### Adım 4: PM2'yi Yeniden Başlat
```bash
cd ~/premiumfoto

# PM2'yi temizle
pm2 kill
pm2 delete all
pm2 flush

# Biraz bekle
sleep 2

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
pm2 flush && \
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
# 1. Tüm process'leri gör
ps aux | grep -E "(node|npm|next)"

# 2. Port 3040'ı kullanan process'i bul
sudo lsof -i:3040

# 3. PID'yi al ve durdur
sudo kill -9 <PID>

# 4. Port'un boş olduğunu kontrol et
sudo lsof -i:3040

# 5. PM2'yi başlat
cd ~/premiumfoto
pm2 kill
pm2 delete all
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
```

## 🔄 Alternatif: Farklı Port Kullan

Eğer port 3040'ı başka bir uygulama kullanıyorsa ve durduramıyorsanız:

```bash
# 1. package.json'ı düzenle
nano ~/premiumfoto/package.json
# "start": "next start -p 3041" olarak değiştir

# 2. Nginx config'i güncelle
sudo nano /etc/nginx/sites-available/foto-ugur
# proxy_pass http://localhost:3041; olarak değiştir

# 3. Nginx'i test et ve yeniden yükle
sudo nginx -t
sudo systemctl reload nginx

# 4. PM2'yi yeniden başlat
cd ~/premiumfoto
pm2 kill
pm2 delete all
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
```

## ✅ Doğrulama

```bash
# Port 3040 boş mu?
sudo lsof -i:3040
# Çıktı olmamalı

# PM2'de tek process var mı?
pm2 status
# Sadece 1 process olmalı, "online" durumunda

# Uygulama erişilebilir mi?
curl -I http://localhost:3040
# HTTP 200 dönmeli

# Loglar temiz mi?
pm2 logs foto-ugur-app --lines 10
# Hata olmamalı
```

