# 🔧 Blog Yedek Arama ve 502 Çözümü

## 📋 Yapılacaklar

1. **Blog yedeklerini bul** - Eski blogları kurtarmak için
2. **502 hatasını çöz** - dugunkarem.com ve dugunkarem.com.tr için

## 🚀 Sunucuda Çalıştırılacak Komutlar

### Adım 1: Projeyi Güncelle

```bash
cd ~/premiumfoto
git pull origin main
chmod +x scripts/find-all-blog-backups.sh
chmod +x scripts/fix-502-dugunkarem-final.sh
```

### Adım 2: Blog Yedeklerini Bul

```bash
bash scripts/find-all-blog-backups.sh
```

Bu script:
- ✅ Mevcut veritabanındaki blog sayısını gösterir
- ✅ Sistem genelinde tüm .db dosyalarını bulur
- ✅ Backup dizinlerini kontrol eder
- ✅ Git geçmişini kontrol eder
- ✅ En çok blog içeren yedeği bulur

### Adım 3: Blog Yedeğini Geri Yükle (Eğer bulunduysa)

Eğer script bir yedek bulursa:

```bash
# Yedek dosyasını belirle (script çıktısından)
BACKUP_FILE="/path/to/backup.db"

# Yedeği geri yükle
cp ~/premiumfoto/prisma/dev.db ~/premiumfoto/prisma/dev.db.backup.$(date +%Y%m%d_%H%M%S)
cp "$BACKUP_FILE" ~/premiumfoto/prisma/dev.db

# Prisma client'ı yeniden oluştur
cd ~/premiumfoto
npx prisma generate

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app --update-env
```

### Adım 4: 502 Hatasını Çöz

```bash
sudo bash scripts/fix-502-dugunkarem-final.sh
```

Bu script:
- ✅ Port 3040'ın dinlendiğini kontrol eder
- ✅ foto-ugur-app'i başlatır (eğer çalışmıyorsa)
- ✅ fikirtepetekelpaket.com config'ini devre dışı bırakır
- ✅ dugunkarem.com ve dugunkarem.com.tr için Nginx server block'ları ekler
- ✅ HTTP -> HTTPS redirect ekler
- ✅ Tüm proxy_pass'leri port 3040'a yönlendirir
- ✅ Nginx'i test eder ve reload eder

### Adım 5: Kontrol

```bash
# PM2 durumu
pm2 status

# Port kontrolü
sudo lsof -i:3040

# Domain test
curl -I https://dugunkarem.com
curl -I https://dugunkarem.com.tr

# Nginx config kontrolü
sudo nginx -t
sudo grep -A 10 "server_name.*dugunkarem.com" /etc/nginx/sites-available/foto-ugur
```

## 📊 Blog Yedek Arama Detayları

Script şu yerlerde arama yapar:
- `~/premiumfoto/prisma/dev.db` (mevcut veritabanı)
- `~/` altındaki tüm .db dosyaları
- `~/premiumfoto/backups/` dizini
- `~/backup/` dizini
- `/var/backups/` dizini
- Git geçmişi (eğer veritabanı commit edilmişse)

## 🔍 Sohbet Geçmişinden Blog Silme Bilgisi

Sohbet geçmişine göre:
- Kullanıcı "bloglar silinmiş" demişti
- `restore-database-backup.sh` scripti ile yedek geri yüklenmişti
- Ancak yedekte sadece 5 blog vardı
- Kullanıcı daha fazla blog olduğunu söylüyor

**Önemli:** Script tüm sistemde .db dosyalarını arayacak, bu yüzden daha eski yedekler bulunabilir.

## ⚠️ Dikkat

- Script çalıştırılmadan önce mevcut veritabanının yedeğini alın:
  ```bash
  cp ~/premiumfoto/prisma/dev.db ~/premiumfoto/prisma/dev.db.backup.$(date +%Y%m%d_%H%M%S)
  ```

- Eğer birden fazla yedek bulunursa, en çok blog içeren yedeği seçin.

- 502 hatası devam ederse, PM2 loglarını kontrol edin:
  ```bash
  pm2 logs foto-ugur-app --lines 50
  ```

