# 🔍 Blog Yayınlama Sorunu - Çözüm

## ❌ Sorun

- Admin tarafında bloglar "yayınlandı" olarak görünüyor
- Müşteri tarafında görünmüyor

## ✅ Çözüm

### 1. Veritabanını Kontrol Et

```bash
cd ~/premiumfoto

# Prisma Studio ile veritabanını kontrol et
npx prisma studio
```

Veya SQLite ile:

```bash
sqlite3 prisma/dev.db "SELECT id, title, isPublished, publishedAt FROM BlogPost ORDER BY createdAt DESC LIMIT 10;"
```

### 2. Mevcut Blogları Yayınla (Eğer Gerekirse)

```bash
cd ~/premiumfoto

# Tüm blogları yayınla (isPublished: false olanları)
sqlite3 prisma/dev.db "UPDATE BlogPost SET isPublished = 1, publishedAt = datetime('now') WHERE isPublished = 0;"

# Kontrol et
sqlite3 prisma/dev.db "SELECT id, title, isPublished, publishedAt FROM BlogPost;"
```

### 3. Next.js Cache'i Temizle

```bash
cd ~/premiumfoto

# Build cache'i temizle
rm -rf .next

# PM2'yi restart et
pm2 restart foto-ugur-app --update-env
```

### 4. Tarayıcı Cache'i Temizle

- Hard refresh: `Ctrl + F5` veya `Ctrl + Shift + R`
- Veya tarayıcı ayarlarından cache'i temizleyin

## 🔥 Tek Komutla Çözüm

```bash
cd ~/premiumfoto && \
sqlite3 prisma/dev.db "UPDATE BlogPost SET isPublished = 1, publishedAt = datetime('now') WHERE isPublished = 0 OR publishedAt IS NULL;" && \
rm -rf .next && \
npm run build && \
pm2 restart foto-ugur-app --update-env
```

## ✅ Doğrulama

```bash
# Yayınlanmış blogları kontrol et
sqlite3 prisma/dev.db "SELECT COUNT(*) as yayinlanan FROM BlogPost WHERE isPublished = 1;"

# Tüm blogları listele
sqlite3 prisma/dev.db "SELECT id, title, isPublished, publishedAt FROM BlogPost ORDER BY createdAt DESC;"
```

## 📝 Notlar

1. **isPublished**: `1` = true, `0` = false (SQLite boolean)
2. **publishedAt**: NULL olmamalı, tarih olmalı
3. **Cache**: Next.js cache'i temizlenmeli
4. **PM2**: Restart edilmeli

