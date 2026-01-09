# 🔧 Sunucuda Build Hatası Çözümü

## ❌ Sorunlar

1. **Production build bulunamıyor**: `.next` dizininde build yok
2. **Geçersiz next.config.js**: `api` key'i tanınmıyor

## ✅ Çözüm

### 1. next.config.js'yi Düzelt

```bash
cd ~/premiumfoto
nano next.config.js
```

`api` key'ini kaldırın veya düzeltin.

### 2. Build Cache'i Temizle ve Build Et

```bash
cd ~/premiumfoto

# Build cache'i temizle
rm -rf .next node_modules/.cache

# Build et
npm run build
```

### 3. PM2'yi Restart Et

```bash
pm2 restart foto-ugur-app
```

## 🔥 Tek Komutla Çözüm

```bash
cd ~/premiumfoto && \
rm -rf .next node_modules/.cache && \
npm run build && \
pm2 restart foto-ugur-app
```

## 📝 next.config.js Kontrolü

Eğer `api` key'i varsa, kaldırın:

```javascript
// ❌ YANLIŞ
module.exports = {
  api: {
    // ...
  }
}

// ✅ DOĞRU
module.exports = {
  // api key'i yok
}
```

