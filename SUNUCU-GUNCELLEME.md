# Sunucuda Güncelleme Komutları

## 🔄 GitHub'dan Güncelleme Çekme

### 1. Proje Dizinine Git
```bash
cd ~/premiumfoto
```

### 2. Güncellemeleri Çek
```bash
git pull origin main
```

### 3. Bağımlılıkları Güncelle (Gerekirse)
```bash
npm install
```

### 4. Build Yap
```bash
npm run build
```

### 5. PM2 ile Yeniden Başlat
```bash
pm2 restart foto-ugur-app
```

## 📋 Tek Komutla Tüm İşlemler

```bash
cd ~/premiumfoto && git pull origin main && npm install && npm run build && pm2 restart foto-ugur-app
```

## 🔍 Durum Kontrolü

```bash
# Git durumu kontrol et
git status

# PM2 durumu kontrol et
pm2 status

# PM2 logları görüntüle
pm2 logs foto-ugur-app --lines 50
```

## ⚠️ Sorun Giderme

### Eğer çakışma varsa:
```bash
# Değişiklikleri kaydetmeden çek
git stash
git pull origin main
git stash pop
```

### Eğer build hatası varsa:
```bash
# Node modules'ü temizle ve yeniden kur
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Eğer PM2 çalışmıyorsa:
```bash
# PM2'yi başlat
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
```

