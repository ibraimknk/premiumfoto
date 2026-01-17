# Sunucuda Güvenli Build - Blog Yedekleme ile

## ⚠️ ÖNEMLİ: Blog'ları Kaybetmemek İçin

Build yapmadan önce **mutlaka** güvenli build script'ini kullanın!

## 🚀 Güvenli Build (Önerilen)

```bash
cd ~/premiumfoto
bash scripts/safe-build-with-backup.sh
```

Bu script:
- ✅ **Otomatik yedekleme** yapar
- ✅ Blog kayıt sayısını kontrol eder
- ✅ Build sonrası kontrol yapar
- ✅ Kayıp varsa otomatik geri yükler

## 📋 Alternatif: Manuel Yedekleme ile Build

Eğer script kullanmak istemiyorsanız:

```bash
cd ~/premiumfoto

# 1. VERİTABANI YEDEKLE (ÖNEMLİ!)
mkdir -p backups
sqlite3 prisma/dev.db ".backup backups/dev.db.backup.$(date +%Y%m%d_%H%M%S)"

# 2. Blog kayıt sayısını kontrol et
sqlite3 prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"

# 3. Git pull
git pull

# 4. Build
npm run build

# 5. Blog kayıt sayısını tekrar kontrol et
sqlite3 prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"

# 6. PM2 restart
pm2 restart foto-ugur-app
```

## 🔍 Yedek Kontrolü

### Yedekleri Listele
```bash
ls -lh ~/premiumfoto/backups/
```

### Blog Kayıt Sayısını Kontrol Et
```bash
sqlite3 ~/premiumfoto/prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"
```

### Yedekten Geri Yükleme (Gerekirse)
```bash
# En son yedeği bul
LATEST_BACKUP=$(ls -t ~/premiumfoto/backups/dev.db.backup.* | head -1)
echo "Yedek: $LATEST_BACKUP"

# Geri yükle
cp "$LATEST_BACKUP" ~/premiumfoto/prisma/dev.db
npx prisma generate
pm2 restart foto-ugur-app
```

## ✅ Özet

**Güvenli Yöntem:**
```bash
cd ~/premiumfoto
bash scripts/safe-build-with-backup.sh
```

**Manuel Yöntem:**
```bash
cd ~/premiumfoto
sqlite3 prisma/dev.db ".backup backups/dev.db.backup.$(date +%Y%m%d_%H%M%S)" && \
git pull && \
npm run build && \
pm2 restart foto-ugur-app
```

## 🎯 Sonuç

- ✅ Güvenli build script'i otomatik yedekleme yapar
- ✅ Blog kayıtları korunur
- ✅ Hata durumunda otomatik geri yükleme yapılır

