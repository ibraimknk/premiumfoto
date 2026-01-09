# 📦 Sunucuda Gemini AI Paketi Kurulumu

## ❌ Sorun

`npm list @google/generative-ai` komutu `(empty)` gösteriyor. Paket kurulmamış.

## ✅ Çözüm

### 1. Paketi Kur

```bash
cd ~/premiumfoto
npm install @google/generative-ai
```

### 2. Build Et

```bash
npm run build
```

### 3. PM2'yi Restart Et

```bash
pm2 restart foto-ugur-app
```

### 4. Doğrulama

```bash
# Paket kontrolü
npm list @google/generative-ai

# Çıktı şöyle olmalı:
# foto-ugur@1.0.0 /home/ibrahim/premiumfoto
# └── @google/generative-ai@0.21.0
```

## 🔄 Alternatif: Tüm Paketleri Yeniden Kur

Eğer yukarıdaki çözüm işe yaramazsa:

```bash
cd ~/premiumfoto

# node_modules'ı sil
rm -rf node_modules

# package-lock.json'ı sil (opsiyonel)
# rm package-lock.json

# Tüm paketleri yeniden kur
npm install

# Build et
npm run build

# PM2'yi restart et
pm2 restart foto-ugur-app
```

## ✅ Tek Komutla Çözüm

```bash
cd ~/premiumfoto && \
npm install @google/generative-ai && \
npm run build && \
pm2 restart foto-ugur-app && \
npm list @google/generative-ai
```

