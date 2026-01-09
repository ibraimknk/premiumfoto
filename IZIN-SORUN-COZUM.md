# 🔧 İzin Sorunu Çözümü

## ❌ Hata: `EACCES: permission denied, open '/home/ibrahim/premiumfoto/.next/trace'`

Bu hata, `.next` dizinine yazma izni olmadığında oluşur.

## 🔧 Çözüm

### Hızlı Çözüm (Tek Komut)

```bash
cd ~/premiumfoto

# Eski build'i temizle
rm -rf .next

# İzinleri düzelt
sudo chown -R ibrahim:ibrahim ~/premiumfoto
chmod -R 755 ~/premiumfoto

# Build yap
npm run build

# .next dizinine yazma izni ver
chmod -R 755 .next

# PM2'yi başlat
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
pm2 status
```

### Adım Adım Çözüm

#### 1. Eski Build'i Temizle
```bash
cd ~/premiumfoto
rm -rf .next
```

#### 2. Dizin Sahipliğini Düzelt
```bash
# Tüm dosyaların sahibini kontrol et
ls -la ~/premiumfoto

# Eğer root veya başka kullanıcı sahibiyse, düzelt:
sudo chown -R ibrahim:ibrahim ~/premiumfoto
```

#### 3. İzinleri Düzelt
```bash
# Dizin izinlerini düzelt
chmod -R 755 ~/premiumfoto

# node_modules izinlerini düzelt (eğer varsa)
if [ -d "node_modules" ]; then
    chmod -R 755 node_modules
fi
```

#### 4. Build Yap
```bash
npm run build
```

#### 5. .next Dizini İzinlerini Kontrol Et
```bash
# .next dizini oluşturulduktan sonra
chmod -R 755 .next

# Kontrol et
ls -la .next
```

#### 6. PM2'yi Başlat
```bash
pm2 start npm --name "foto-ugur-app" -- start
pm2 save
pm2 status
```

## 🚀 Tek Komutla Tüm Çözüm

```bash
cd ~/premiumfoto && \
sudo chown -R ibrahim:ibrahim ~/premiumfoto && \
chmod -R 755 ~/premiumfoto && \
rm -rf .next && \
npm run build && \
chmod -R 755 .next && \
pm2 start npm --name "foto-ugur-app" -- start && \
pm2 save && \
pm2 status
```

## 🔍 Sorun Tespiti

### Dizin Sahipliğini Kontrol Et
```bash
ls -la ~/premiumfoto
# Tüm dosyalar "ibrahim ibrahim" sahibinde olmalı
```

### İzinleri Kontrol Et
```bash
ls -ld ~/premiumfoto
# Çıktı: drwxr-xr-x olmalı (755)
```

### .next Dizini Kontrolü
```bash
ls -la ~/premiumfoto/.next
# Eğer yoksa, build yapılmamış demektir
```

## ⚠️ Önemli Notlar

1. **Root ile Çalıştırma:** Eğer deploy script'i root ile çalıştırıldıysa, dosyalar root sahibi olabilir. Bu durumda `chown` ile düzeltin.

2. **PM2 Kullanıcısı:** PM2'yi hangi kullanıcı ile başlattıysanız, o kullanıcının dosyalara yazma izni olmalı.

3. **Build Cache:** Bazen eski build cache'i sorun çıkarabilir. `.next` dizinini tamamen temizleyin.

## 🐛 Yaygın Hatalar

### "Permission denied" Hatası Devam Ediyor
```bash
# Daha agresif izin düzeltme
sudo chown -R ibrahim:ibrahim ~/premiumfoto
sudo chmod -R 777 ~/premiumfoto  # Geçici olarak (güvenlik riski var)
npm run build
chmod -R 755 ~/premiumfoto  # Güvenli izinlere geri dön
```

### "Cannot find module" Hatası
```bash
# node_modules izinlerini düzelt
chmod -R 755 node_modules
```

### PM2 "Script not found" Hatası
```bash
# package.json kontrolü
cat package.json | grep '"start"'
# Çıktı: "start": "next start -p 3040" olmalı
```

## ✅ Doğrulama

```bash
# Build başarılı mı?
ls -la .next

# İzinler doğru mu?
ls -ld .next
# Çıktı: drwxr-xr-x olmalı

# PM2 çalışıyor mu?
pm2 status
# foto-ugur-app "online" olmalı

# Loglar temiz mi?
pm2 logs foto-ugur-app --lines 10
# Hata olmamalı
```

