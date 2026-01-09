# Sunucuda Upload API Deploy Adımları

## 1. Proje Dizinine Git

```bash
cd ~/premiumfoto
# veya
cd /home/ibrahim/premiumfoto
```

## 2. Git Pull (Yeni Dosyaları Çek)

```bash
git pull origin main
# veya
git pull origin master
```

## 3. Build Yap

```bash
npm run build
```

## 4. PM2 Restart

```bash
pm2 restart foto-ugur-app
# veya
pm2 restart all
```

## 5. Logları Kontrol Et

```bash
pm2 logs foto-ugur-app --lines 50
```

## 6. API Endpoint Test

```bash
curl https://fotougur.com.tr/api/upload
```

## Tam Komut Dizisi

```bash
# SSH ile bağlan
ssh ibrahim@192.168.1.120

# Proje dizinine git
cd ~/premiumfoto

# Git pull
git pull

# Build
npm run build

# Restart
pm2 restart foto-ugur-app

# Log kontrol
pm2 logs foto-ugur-app --lines 20
```

## Sorun Giderme

### 500 Internal Server Error

1. **Logları kontrol et:**
```bash
pm2 logs foto-ugur-app --lines 100
```

2. **Uploads klasörü izinleri:**
```bash
cd ~/premiumfoto
mkdir -p public/uploads
chmod 755 public/uploads
```

3. **Route dosyası var mı kontrol et:**
```bash
ls -la app/api/upload/route.ts
```

4. **Next.js build hatası var mı:**
```bash
npm run build 2>&1 | grep -i error
```

### 404 Not Found

- Route dosyası deploy edilmemiş olabilir
- Git pull yapın ve build edin

### Permission Denied

```bash
chmod -R 755 public/uploads
chown -R ibrahim:ibrahim public/uploads
```

