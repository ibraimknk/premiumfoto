# 🔧 Veritabanı Yeniden Oluşturma

## ✅ Veritabanı Reset Edildi

Veritabanı reset edildi ve şimdi boş. Tabloları oluşturup seed verilerini eklemeliyiz.

## 🚀 Çözüm

### 1. Tabloları Oluştur

```bash
cd ~/premiumfoto

# Prisma db push ile tabloları oluştur
npx prisma db push

# Prisma client'ı oluştur
npx prisma generate
```

### 2. Seed Verilerini Ekle (Opsiyonel)

```bash
# Seed script'ini çalıştır (admin kullanıcı, hizmetler, sayfalar, vb.)
npm run db:seed
```

### 3. Yeni Bloglar Oluştur

Artık yeni bloglar oluşturduğunuzda otomatik olarak yayınlanacak:
- Admin panelinde "AI ile Oluştur" butonuna tıklayın
- Blog sayısını girin
- Bloglar otomatik olarak yayınlanacak ve müşteri tarafında görünecek

### 4. Cache'i Temizle ve Restart Et

```bash
cd ~/premiumfoto

# Build cache'i temizle
rm -rf .next

# Build et
npm run build

# PM2'yi restart et
pm2 restart foto-ugur-app --update-env
```

## 🔥 Tek Komutla

```bash
cd ~/premiumfoto && \
npx prisma db push && \
npx prisma generate && \
npm run db:seed && \
rm -rf .next && \
npm run build && \
pm2 restart foto-ugur-app --update-env
```

## ✅ Doğrulama

```bash
# Tabloları kontrol et
sqlite3 prisma/dev.db ".tables"

# BlogPost tablosunu kontrol et
sqlite3 prisma/dev.db "SELECT COUNT(*) FROM \"BlogPost\";"
```

