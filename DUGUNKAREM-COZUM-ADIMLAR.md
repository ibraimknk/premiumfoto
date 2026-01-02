# 🔧 dugunkarem.com ve dugunkarem.com.tr Çözüm Adımları

## ⚠️ Önce Git Conflict'i Çözün

Sunucuda şu komutları sırayla çalıştırın:

### Adım 1: Git Conflict'i Çöz

```bash
cd ~/premiumfoto
git stash
git fetch origin main
git reset --hard origin/main
```

### Adım 2: Script'i Çalıştır

```bash
chmod +x scripts/fix-dugunkarem-final-working.sh
sudo bash scripts/fix-dugunkarem-final-working.sh
```

## 🔍 Script Ne Yapıyor?

1. ✅ Git conflict'i çözer
2. ✅ `fikirtepetekelpaket.com`'u devre dışı bırakır
3. ✅ Nginx config'ini düzeltir (boş server_name satırlarını temizler)
4. ✅ `dugunkarem.com` block'larını en başa ekler
5. ✅ Nginx'i test eder ve restart eder
6. ✅ Domain'leri test eder

## 📋 Manuel Kontrol (Eğer Script Başarısız Olursa)

```bash
# Nginx config'i kontrol et
sudo nginx -t

# Config dosyasının ilk 20 satırını gör
sudo head -20 /etc/nginx/sites-available/foto-ugur

# dugunkarem.com block'larını kontrol et
sudo grep -A 10 "server_name.*dugunkarem.com" /etc/nginx/sites-available/foto-ugur

# Port 3040 kontrolü
curl -I http://localhost:3040

# Domain testleri
curl -I https://dugunkarem.com
curl -I https://dugunkarem.com.tr
```

