# 🚀 Dugunkarem.com Hızlı Deploy

## ✅ Repository Public Yapıldı

Artık script otomatik olarak HTTPS ile clone edecek.

## 🚀 Deploy Adımları

```bash
# 1. Güncellemeleri çek
cd ~/premiumfoto
git pull origin main

# 2. Deploy script'ini çalıştır
bash deploy-dugunkarem.sh
```

## 📋 Script Ne Yapacak?

1. ✅ Sistem paketlerini kontrol eder (Node.js, PM2, Nginx)
2. ✅ `dugunkarem` projesini GitHub'dan clone eder (HTTPS ile)
3. ✅ `.env` dosyası oluşturur/günceller
4. ✅ NPM paketlerini kurar
5. ✅ Prisma client oluşturur
6. ✅ Production build alır
7. ✅ PM2 ile uygulamayı başlatır (port 3041)
8. ✅ Nginx config oluşturur (`dugunkarem.com` için)
9. ✅ `foto-ugur` config'inden `dugunkarem.com`'u çıkarır

## ✅ Doğrulama

```bash
# PM2 durumu
pm2 status
# dugunkarem-app "online" olmalı

# Port kontrolü
sudo lsof -i:3041
# node process görünmeli

# Nginx config
sudo cat /etc/nginx/sites-available/dugunkarem
sudo cat /etc/nginx/sites-available/foto-ugur | grep server_name
# dugunkarem.com olmamalı

# Domain erişimi
curl -I http://dugunkarem.com
# HTTP 200 dönmeli
```

## 🔒 SSL Sertifikası (Opsiyonel)

```bash
sudo certbot --nginx -d dugunkarem.com -d www.dugunkarem.com
```

