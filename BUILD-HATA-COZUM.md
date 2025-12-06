# Build Hatası ve HTTP 413 Çözümü

## 🔧 Sorun 1: Build Hatası (initCoreHelpers)

Bu hata genellikle build cache sorunundan kaynaklanır.

### Çözüm:

```bash
cd ~/premiumfoto

# Build cache'i temizle
rm -rf .next

# Node modules'ü temizle (gerekirse)
rm -rf node_modules package-lock.json

# Yeniden kur
npm install

# Build yap
npm run build

# PM2 restart
pm2 restart foto-ugur-app
```

## 🔧 Sorun 2: HTTP 413 Hala Devam Ediyor

Nginx konfigürasyonu henüz güncellenmemiş olabilir.

### Kontrol:

```bash
# Nginx config'i kontrol et
cat /etc/nginx/sites-available/foto-ugur | grep client_max_body_size
```

Eğer `10M` görüyorsanız, güncelleme yapılmamış demektir.

### Çözüm:

```bash
# Nginx config'i düzenle
sudo nano /etc/nginx/sites-available/foto-ugur

# client_max_body_size 10M; satırını bulun ve şu şekilde değiştirin:
# client_max_body_size 50M;

# Kaydedin (Ctrl+O, Enter, Ctrl+X)

# Test et
sudo nginx -t

# Yeniden yükle
sudo systemctl reload nginx
```

## 🚀 Tek Komutla Tüm Çözümler

```bash
cd ~/premiumfoto && \
rm -rf .next && \
npm run build && \
pm2 restart foto-ugur-app && \
sudo sed -i 's/client_max_body_size 10M;/client_max_body_size 50M;/g' /etc/nginx/sites-available/foto-ugur && \
sudo nginx -t && \
sudo systemctl reload nginx
```

## ✅ Doğrulama

1. **Build hatası kontrolü:**
   ```bash
   pm2 logs foto-ugur-app --lines 20 | grep -i error
   ```

2. **Nginx limit kontrolü:**
   ```bash
   cat /etc/nginx/sites-available/foto-ugur | grep client_max_body_size
   ```
   Çıktı: `client_max_body_size 50M;` olmalı

3. **Tarayıcıda test:**
   - Admin panelinde 50MB'dan küçük bir dosya yükleyin
   - Artık HTTP 413 hatası almamalısınız

