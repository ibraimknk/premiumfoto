# 🔧 İzin ve Git Conflict Çözümü

## ❌ Sorunlar
1. `app/api/upload/route.ts` dosyası oluşturulamıyor (izin hatası)
2. Bash'te parantezler sorun yaratıyor

## ✅ Çözüm

### 1. Klasör İzinlerini Düzelt

```bash
cd ~/premiumfoto

# API klasörü izinlerini düzelt
sudo chown -R ibrahim:ibrahim app/api/
sudo chmod -R 755 app/api/

# Public klasör izinlerini düzelt
sudo chown -R ibrahim:ibrahim "app/(public)/"
sudo chmod -R 755 "app/(public)/"
```

### 2. Git Pull (Force)

```bash
cd ~/premiumfoto

# Mevcut değişiklikleri at
git reset --hard HEAD

# Remote'dan çek
git fetch origin
git reset --hard origin/main
```

### 3. Dosyaları Kontrol Et (Tırnak İçinde)

```bash
# Parantezleri tırnak içine al
ls -la "app/(public)/fotolar/"
ls -la app/api/uploads/list/route.ts
ls -la app/api/upload/route.ts
```

### 4. Eğer Dosya Yoksa, Manuel Oluştur

Windows'tan dosyayı kopyalayıp sunucuya yapıştırabilirsiniz veya:

```bash
# Klasörü oluştur
mkdir -p app/api/upload
mkdir -p app/api/uploads/list

# İzinleri düzelt
sudo chown -R ibrahim:ibrahim app/api/
sudo chmod -R 755 app/api/
```

### 5. Build ve Restart

```bash
npm run build
pm2 restart foto-ugur-app
```

