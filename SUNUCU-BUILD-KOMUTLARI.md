# Sunucuda Build Komutları - GitHub'dan Çekme

## 🚀 Hızlı Başlangıç (Tek Komut)

```bash
cd ~/premiumfoto && git pull && bash scripts/safe-build-with-backup.sh
```

## 📋 Adım Adım Detaylı Komutlar

### 1. Dizine Git

```bash
cd ~/premiumfoto
```

### 2. GitHub'dan Son Değişiklikleri Çek

```bash
git pull origin main
```

veya

```bash
git pull
```

### 3. Güvenli Build (Önerilen - Otomatik Yedekleme ile)

```bash
bash scripts/safe-build-with-backup.sh
```

### 4. Alternatif: Manuel Build (Yedekleme ile)

```bash
# 1. Veritabanını yedekle
mkdir -p backups
sqlite3 prisma/dev.db ".backup backups/dev.db.backup.$(date +%Y%m%d_%H%M%S)"

# 2. Blog kayıt sayısını kontrol et (yedekleme öncesi)
sqlite3 prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"

# 3. Bağımlılıkları güncelle
npm ci --production=false

# 4. Prisma client güncelle
npx prisma generate

# 5. Veritabanı migration (veri kaybı olmadan)
npx prisma db push --skip-generate

# 6. Build
npm run build

# 7. Blog kayıt sayısını tekrar kontrol et
sqlite3 prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"

# 8. PM2 restart
pm2 restart foto-ugur-app --update-env
```

## 🔍 Kontrol Komutları

### Build Sonrası Kontroller

```bash
# Blog kayıt sayısını kontrol et
sqlite3 ~/premiumfoto/prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"

# PM2 durumunu kontrol et
pm2 status

# PM2 loglarını kontrol et
pm2 logs foto-ugur-app --lines 30

# Build başarılı mı kontrol et
pm2 info foto-ugur-app
```

### Yedekleri Kontrol Et

```bash
# Yedek dizinini listele
ls -lh ~/premiumfoto/backups/

# En son yedeği göster
ls -lt ~/premiumfoto/backups/ | head -5
```

## ⚠️ Sorun Giderme

### Git Pull Hatası

```bash
# Eğer local değişiklikler varsa
git stash
git pull
git stash pop
```

### Build Hatası

```bash
# Node modules'ü temizle ve yeniden yükle
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Veritabanı Hatası

```bash
# Prisma client'ı yeniden oluştur
npx prisma generate

# Veritabanı şemasını kontrol et
npx prisma db push --skip-generate
```

### Blog Kayıtları Kaybolduysa

```bash
# En son yedeği bul
LATEST_BACKUP=$(ls -t ~/premiumfoto/backups/dev.db.backup.* | head -1)
echo "Yedek: $LATEST_BACKUP"

# Yedeği geri yükle
cp "$LATEST_BACKUP" ~/premiumfoto/prisma/dev.db
npx prisma generate
pm2 restart foto-ugur-app
```

## 📊 Örnek Tam Komut Dizisi

```bash
# Tüm işlemleri tek seferde yap
cd ~/premiumfoto && \
git pull && \
bash scripts/safe-build-with-backup.sh && \
echo "✅ Build tamamlandı!" && \
sqlite3 prisma/dev.db "SELECT COUNT(*) FROM BlogPost;" && \
pm2 logs foto-ugur-app --lines 10
```

## 🎯 Önerilen Yöntem

**En Güvenli Yöntem**: `safe-build-with-backup.sh` script'ini kullanın

```bash
cd ~/premiumfoto
bash scripts/safe-build-with-backup.sh
```

Bu script:
- ✅ Otomatik veritabanı yedekleme
- ✅ Blog kayıt kontrolü
- ✅ Otomatik geri yükleme
- ✅ Hata yönetimi
- ✅ Detaylı log

## 📝 Notlar

1. **İlk Kez Çalıştırıyorsanız**: Script'i çalıştırabilir hale getirin:
   ```bash
   chmod +x scripts/safe-build-with-backup.sh
   ```

2. **Git Pull Öncesi**: Eğer local değişiklikleriniz varsa:
   ```bash
   git stash
   git pull
   git stash pop
   ```

3. **Build Sonrası**: Mutlaka blog kayıt sayısını kontrol edin:
   ```bash
   sqlite3 prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"
   ```

