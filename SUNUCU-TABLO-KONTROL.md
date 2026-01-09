# 🔍 Veritabanı Tablo Kontrolü

## Tabloları Listele

```bash
cd ~/premiumfoto

# Tüm tabloları listele
sqlite3 prisma/dev.db ".tables"

# Blog ile ilgili tabloları bul
sqlite3 prisma/dev.db "SELECT name FROM sqlite_master WHERE type='table';"

# BlogPost tablosunun schema'sını kontrol et
sqlite3 prisma/dev.db ".schema BlogPost"
```

## Eğer Tablo Yoksa

```bash
# Prisma migration'larını zorla uygula
npx prisma db push --force-reset

# VEYA migration'ları manuel çalıştır
npx prisma migrate deploy
```

## Tablo Adını Kontrol Et

SQLite'da tablo adları case-sensitive olabilir. Şunları deneyin:

```bash
# Küçük harf ile
sqlite3 prisma/dev.db "SELECT * FROM blogpost LIMIT 1;"

# Büyük harf ile
sqlite3 prisma/dev.db "SELECT * FROM BlogPost LIMIT 1;"

# Tırnak içinde
sqlite3 prisma/dev.db 'SELECT * FROM "BlogPost" LIMIT 1;'
```

