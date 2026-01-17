# Güvenli Build Kılavuzu - Veritabanı Yedekleme ile

## 🎯 Amaç

Sunucudaki blog'ları kaybetmeden güvenli bir şekilde build yapmak için oluşturulmuş script.

## 📋 Script Özellikleri

✅ **Otomatik Veritabanı Yedekleme**: Build öncesi veritabanı otomatik yedeklenir
✅ **Blog Kayıt Kontrolü**: Build sonrası blog kayıt sayısı kontrol edilir
✅ **Otomatik Geri Yükleme**: Eğer blog kayıtları azalırsa otomatik geri yüklenir
✅ **Hata Yönetimi**: Build başarısız olursa veritabanı geri yüklenir
✅ **Detaylı Log**: Her adım detaylı şekilde loglanır

## 🚀 Kullanım

### Sunucuda Çalıştırma

```bash
cd ~/premiumfoto
bash scripts/safe-build-with-backup.sh
```

### Script Ne Yapıyor?

1. **Veritabanı Yedekleme**
   - Mevcut veritabanını `backups/dev.db.backup.TARIH_SAAT` olarak yedekler
   - Blog kayıt sayısını kontrol eder

2. **Git Pull**
   - Son değişiklikleri çeker

3. **Bağımlılık Güncelleme**
   - `npm ci` veya `npm install` çalıştırır

4. **Prisma Güncelleme**
   - Prisma client'ı yeniden oluşturur

5. **Migration**
   - Veritabanı şema değişikliklerini uygular (veri kaybı olmadan)

6. **Build**
   - Production build oluşturur
   - Eğer başarısız olursa veritabanını geri yükler

7. **Veritabanı Kontrolü**
   - Blog kayıt sayısını kontrol eder
   - Eğer azaldıysa otomatik geri yükler

8. **PM2 Restart**
   - Uygulamayı yeniden başlatır

## 📊 Örnek Çıktı

```
╔════════════════════════════════════════════════════════╗
║   Güvenli Build - Veritabanı Yedekleme ile          ║
╚════════════════════════════════════════════════════════╝

1️⃣  Dizin kontrolü...
✅ Dizin: /home/ibrahim/premiumfoto

2️⃣  Veritabanı yedekleniyor...
   Mevcut veritabanı boyutu: 2.5M
   Blog kayıt sayısı: 45
✅ Yedek oluşturuldu: /home/ibrahim/premiumfoto/backups/dev.db.backup.20241220_143022
   Yedek boyutu: 2.5M

3️⃣  Git değişiklikleri çekiliyor...
✅ Git pull tamamlandı

4️⃣  Bağımlılıklar güncelleniyor...
✅ Bağımlılıklar güncellendi

5️⃣  Prisma client güncelleniyor...
✅ Prisma client güncellendi

6️⃣  Veritabanı migration kontrol ediliyor...
✅ Migration tamamlandı

7️⃣  Production build oluşturuluyor...
✅ Build başarılı

8️⃣  Veritabanı kontrol ediliyor...
   Yeni blog kayıt sayısı: 45
✅ Blog kayıtları korundu

9️⃣  PM2 uygulaması yeniden başlatılıyor...
✅ PM2 restart edildi

╔════════════════════════════════════════════════════════╗
║                    ÖZET                              ║
╚════════════════════════════════════════════════════════╝
✅ Build tamamlandı!

📋 Bilgiler:
   Yedek dosyası: /home/ibrahim/premiumfoto/backups/dev.db.backup.20241220_143022
   Blog kayıt sayısı: 45
```

## 🔄 Manuel Yedekleme (İsteğe Bağlı)

Eğer script'i kullanmadan önce manuel yedek almak isterseniz:

```bash
cd ~/premiumfoto
mkdir -p backups
sqlite3 prisma/dev.db ".backup backups/dev.db.manual.$(date +%Y%m%d_%H%M%S)"
```

## 🔍 Yedekleri Kontrol Etme

```bash
# Yedek dizinini kontrol et
ls -lh ~/premiumfoto/backups/

# Blog kayıt sayısını kontrol et
sqlite3 ~/premiumfoto/prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"
```

## ⚠️ Önemli Notlar

1. **Yedek Dizini**: Yedekler `~/premiumfoto/backups/` dizininde saklanır
2. **Otomatik Geri Yükleme**: Script blog kayıt sayısı azalırsa otomatik geri yükler
3. **Build Hatası**: Build başarısız olursa veritabanı otomatik geri yüklenir
4. **PM2**: Script PM2'yi otomatik restart eder

## 🆘 Sorun Giderme

### Build Başarısız Olursa

```bash
# Logları kontrol et
pm2 logs foto-ugur-app --lines 50

# Veritabanını manuel geri yükle
cp ~/premiumfoto/backups/dev.db.backup.TARIH_SAAT ~/premiumfoto/prisma/dev.db
npx prisma generate
pm2 restart foto-ugur-app
```

### Blog Kayıtları Azaldıysa

Script otomatik geri yükler, ama manuel kontrol için:

```bash
# Blog kayıt sayısını kontrol et
sqlite3 ~/premiumfoto/prisma/dev.db "SELECT COUNT(*) FROM BlogPost;"

# En son yedeği geri yükle
LATEST_BACKUP=$(ls -t ~/premiumfoto/backups/dev.db.backup.* | head -1)
cp "$LATEST_BACKUP" ~/premiumfoto/prisma/dev.db
npx prisma generate
pm2 restart foto-ugur-app
```

## 📝 Script İzinleri

Script'i çalıştırabilmek için:

```bash
chmod +x scripts/safe-build-with-backup.sh
```

## 🎯 Sonuç

Bu script sayesinde:
- ✅ Veritabanı otomatik yedeklenir
- ✅ Blog kayıtları korunur
- ✅ Build hatalarında otomatik geri yükleme yapılır
- ✅ Güvenli ve sorunsuz build yapılır

