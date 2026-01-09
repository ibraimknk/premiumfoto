# 🚀 Dugunkarem.com Deploy Adımları

## ✅ Clone Tamamlandı

Şimdi deploy script'ini çalıştırın:

```bash
cd ~/premiumfoto
bash deploy-dugunkarem.sh
```

## 📋 Script Ne Yapacak?

1. ✅ Sistem paketlerini kontrol eder (Node.js, PM2, Nginx)
2. ✅ `.env` dosyası oluşturur/günceller
3. ✅ NPM paketlerini kurar
4. ✅ Prisma client oluşturur
5. ✅ Production build alır
6. ✅ PM2 ile uygulamayı başlatır (port 3041)
7. ✅ Nginx config oluşturur (`dugunkarem.com` için)
8. ✅ `foto-ugur` config'inden `dugunkarem.com`'u çıkarır

## ✅ Doğrulama (Script Sonrası)

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

