# 🔧 Veritabanı Tablo Sorunu - Çözüm

## ❌ Sorun

`Error: in prepare, no such table: BlogPost`

Bu, veritabanı migration'larının uygulanmadığı anlamına gelir.

## ✅ Çözüm

### 1. Prisma Migration'larını Uygula

```bash
cd ~/premiumfoto

# Prisma client'ı oluştur
npx prisma generate

# Veritabanı migration'larını uygula
npx prisma db push

# Veya migration'ları çalıştır
npx prisma migrate deploy
```

### 2. Veritabanını Kontrol Et

```bash
# Tabloları listele
sqlite3 prisma/dev.db ".tables"

# BlogPost tablosunu kontrol et
sqlite3 prisma/dev.db "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%Blog%';"
```

### 3. Mevcut Blogları Yayınla

```bash
# Tablo adını kontrol et (büyük/küçük harf farkı olabilir)
sqlite3 prisma/dev.db ".schema BlogPost"

# Eğer tablo varsa, blogları yayınla
sqlite3 prisma/dev.db "UPDATE BlogPost SET isPublished = 1, publishedAt = datetime('now') WHERE isPublished = 0 OR publishedAt IS NULL;"
```

### 4. Alternatif: Prisma Studio ile Kontrol

```bash
# Prisma Studio'yu aç (tarayıcıda)
npx prisma studio
```

## 🔥 Tek Komutla Çözüm

```bash
cd ~/premiumfoto && \
npx prisma generate && \
npx prisma db push && \
sqlite3 prisma/dev.db "UPDATE BlogPost SET isPublished = 1, publishedAt = datetime('now') WHERE isPublished = 0 OR publishedAt IS NULL;" && \
rm -rf .next && \
npm run build && \
pm2 restart foto-ugur-app --update-env
```

## ✅ Doğrulama

```bash
# Tabloları listele
sqlite3 prisma/dev.db ".tables"

# BlogPost tablosundaki kayıtları kontrol et
sqlite3 prisma/dev.db "SELECT id, title, isPublished, publishedAt FROM BlogPost LIMIT 5;"
```

