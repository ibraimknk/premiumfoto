# 🔧 PM2 ve SSL Sorun Çözümü

## ❌ Sorun 1: PM2 Uygulaması Çalışmıyor

PM2 listesi boş gösteriyor. Uygulama başlatılmamış.

### Çözüm:

```bash
cd ~/premiumfoto

# PM2 uygulamasını başlat
pm2 start npm --name "foto-ugur-app" -- start

# PM2'yi kaydet (sunucu yeniden başladığında otomatik başlasın)
pm2 save

# Durumu kontrol et
pm2 status

# Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

**Eğer build yapılmamışsa:**
```bash
cd ~/premiumfoto

# Build yap
npm run build

# PM2'yi başlat
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
```

## ❌ Sorun 2: SSL Sertifikası Kurulumu Başarısız

Let's Encrypt domain'lere erişemiyor. Bu genellikle şu nedenlerden olur:
1. DNS kayıtları henüz yayılmamış
2. Port 80 kapalı (firewall)
3. Nginx doğru yapılandırılmamış

### Adım 1: HTTP Erişimini Kontrol Et

```bash
# Sunucuda HTTP erişimini test et
curl -I http://localhost:3040

# Domain'lerin HTTP üzerinden erişilebilirliğini kontrol et
curl -I http://fotougur.com.tr
curl -I http://dugunkarem.com
curl -I http://dugunkarem.com.tr
```

### Adım 2: DNS Kayıtlarını Kontrol Et

```bash
# DNS kayıtlarını kontrol et
nslookup fotougur.com.tr
nslookup dugunkarem.com
nslookup dugunkarem.com.tr

# Tüm domain'ler 95.70.203.118 IP'sine yönlendirilmeli
```

**DNS kayıtları yoksa veya yanlışsa:**
Domain yönetim panelinde şu A kayıtlarını ekleyin:
```
fotougur.com.tr          → A → 95.70.203.118
www.fotougur.com.tr      → A → 95.70.203.118
dugunkarem.com           → A → 95.70.203.118
www.dugunkarem.com       → A → 95.70.203.118
dugunkarem.com.tr        → A → 95.70.203.118
www.dugunkarem.com.tr    → A → 95.70.203.118
```

### Adım 3: Firewall Kontrolü

```bash
# Port 80 ve 443'ün açık olduğunu kontrol et
sudo ufw status

# Eğer kapalıysa, aç:
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

### Adım 4: Nginx Kontrolü

```bash
# Nginx konfigürasyonunu kontrol et
sudo cat /etc/nginx/sites-available/foto-ugur

# Nginx'in çalıştığını kontrol et
sudo systemctl status nginx

# Nginx'i yeniden başlat
sudo systemctl restart nginx

# Nginx test
sudo nginx -t
```

### Adım 5: SSL Sertifikası Kur (DNS Hazır Olduktan Sonra)

**Önce sadece ana domain'ler için deneyin (www olmadan):**

```bash
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d dugunkarem.com \
  -d dugunkarem.com.tr
```

**Eğer başarılı olursa, www versiyonlarını ekleyin:**

```bash
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d www.fotougur.com.tr \
  -d dugunkarem.com \
  -d www.dugunkarem.com \
  -d dugunkarem.com.tr \
  -d www.dugunkarem.com.tr \
  --expand
```

## 🚀 Hızlı Çözüm (Tüm Adımlar)

```bash
cd ~/premiumfoto

# 1. Build yap (eğer yapılmamışsa)
npm run build

# 2. PM2'yi başlat
pm2 start npm --name "foto-ugur-app" -- start
pm2 save

# 3. PM2 durumunu kontrol et
pm2 status

# 4. Nginx'i kontrol et
sudo nginx -t
sudo systemctl restart nginx

# 5. HTTP erişimini test et
curl -I http://localhost:3040

# 6. DNS kayıtlarını kontrol et
nslookup fotougur.com.tr
nslookup dugunkarem.com
nslookup dugunkarem.com.tr

# 7. SSL sertifikası kur (DNS hazır olduktan sonra)
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d dugunkarem.com \
  -d dugunkarem.com.tr
```

## ✅ Doğrulama

### PM2 Kontrolü
```bash
pm2 status
# foto-ugur-app "online" durumunda olmalı

pm2 logs foto-ugur-app --lines 10
# Hata olmamalı
```

### HTTP Erişim Kontrolü
```bash
# Sunucuda
curl -I http://localhost:3040
# HTTP 200 dönmeli

# Dışarıdan (domain'ler üzerinden)
curl -I http://fotougur.com.tr
curl -I http://dugunkarem.com
curl -I http://dugunkarem.com.tr
# HTTP 200 dönmeli
```

### SSL Kontrolü
```bash
# SSL sertifikası kontrolü
sudo certbot certificates

# Domain'lerin HTTPS üzerinden erişilebilirliği
curl -I https://fotougur.com.tr
curl -I https://dugunkarem.com
curl -I https://dugunkarem.com.tr
```

## 🐛 Yaygın Hatalar

### PM2 "Script not found" Hatası
```bash
# package.json'da "start" script'i olmalı
cat package.json | grep '"start"'

# Eğer yoksa, ekleyin:
# "start": "next start -p 3040"
```

### PM2 "Port already in use" Hatası
```bash
# Port 3040'ı kullanan process'i bul
sudo lsof -i :3040

# Process'i durdur
sudo kill -9 <PID>

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app
```

### SSL "Connection refused" Hatası
- DNS kayıtları henüz yayılmamış (24-48 saat bekleyin)
- Port 80 kapalı (firewall kontrolü yapın)
- Nginx çalışmıyor (`sudo systemctl status nginx`)

## 📝 Önemli Notlar

1. **DNS Yayılımı:** DNS kayıtları değiştiğinde 24-48 saat içinde yayılır
2. **SSL Sertifikası:** DNS hazır olmadan SSL sertifikası alınamaz
3. **PM2 Auto-start:** `pm2 save` komutu çalıştırıldıktan sonra sunucu yeniden başladığında uygulama otomatik başlar
4. **Port 3040:** Uygulama port 3040'ta çalışır, Nginx bu porta proxy yapar

