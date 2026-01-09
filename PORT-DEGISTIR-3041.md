# 🔧 Port Değiştirme: 3040 → 3041

## ❌ Sorun: Port 3040 sürekli kullanımda

Port 3040 başka bir uygulama tarafından kullanılıyor ve durduramıyoruz. Port'u 3041'e değiştiriyoruz.

## 🚀 Sunucuda Yapılacaklar

### 1. PM2'yi Durdur
```bash
pm2 kill
pm2 delete all
```

### 2. package.json'ı Güncelle
```bash
cd ~/premiumfoto
nano package.json
```

Şu satırı bulun:
```json
"start": "next start -p 3040",
```

Şu şekilde değiştirin:
```json
"start": "next start -p 3041",
```

Kaydedin: `Ctrl+O`, `Enter`, `Ctrl+X`

### 3. Nginx Config'i Güncelle
```bash
sudo nano /etc/nginx/sites-available/foto-ugur
```

Şu satırı bulun:
```nginx
proxy_pass http://localhost:3040;
```

Şu şekilde değiştirin:
```nginx
proxy_pass http://localhost:3041;
```

Kaydedin: `Ctrl+O`, `Enter`, `Ctrl+X`

### 4. Nginx'i Test Et ve Yeniden Yükle
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 5. PM2'yi Yeniden Başlat
```bash
cd ~/premiumfoto
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
pm2 status

# Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

## 🔥 Tek Komutla Tüm İşlemler

```bash
cd ~/premiumfoto && \
pm2 kill && \
pm2 delete all && \
sed -i 's/"start": "next start -p 3040"/"start": "next start -p 3041"/' package.json && \
sudo sed -i 's/proxy_pass http:\/\/localhost:3040;/proxy_pass http:\/\/localhost:3041;/' /etc/nginx/sites-available/foto-ugur && \
sudo nginx -t && \
sudo systemctl reload nginx && \
pm2 start npm --name "foto-ugur-app" -- start && \
pm2 save && \
pm2 status
```

## ✅ Doğrulama

```bash
# package.json kontrolü
cat package.json | grep '"start"'
# Çıktı: "start": "next start -p 3041", olmalı

# Nginx config kontrolü
sudo cat /etc/nginx/sites-available/foto-ugur | grep proxy_pass
# Çıktı: proxy_pass http://localhost:3041; olmalı

# PM2 çalışıyor mu?
pm2 status
# foto-ugur-app "online" olmalı

# Port 3041 kullanımda mı?
sudo lsof -i:3041
# Çıktı: node process görünmeli

# Uygulama erişilebilir mi?
curl -I http://localhost:3041
# HTTP 200 dönmeli

# Loglar temiz mi?
pm2 logs foto-ugur-app --lines 10
# Hata olmamalı
```

## 📝 Notlar

1. **Port Değişikliği:** Port 3040 → 3041 olarak değiştirildi
2. **Nginx:** Nginx config'i otomatik güncellendi
3. **PM2:** PM2 yeniden başlatıldı
4. **Domain'ler:** Domain'ler hala aynı şekilde çalışacak (Nginx proxy yapıyor)

## 🔄 Geri Alma (Eğer Gerekirse)

Eğer port 3040'ı kullanmak isterseniz:

```bash
cd ~/premiumfoto
sed -i 's/"start": "next start -p 3041"/"start": "next start -p 3040"/' package.json
sudo sed -i 's/proxy_pass http:\/\/localhost:3041;/proxy_pass http:\/\/localhost:3040;/' /etc/nginx/sites-available/foto-ugur
sudo nginx -t
sudo systemctl reload nginx
pm2 restart foto-ugur-app
```

