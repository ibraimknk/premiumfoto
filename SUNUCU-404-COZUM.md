# 🔧 404 Hatası Çözümü - /fotolar Sayfası

## ❌ Sorun
`https://fotougur.com.tr/fotolar` sayfası 404 hatası veriyor.

## ✅ Çözüm Adımları

### 1. Sunucuda Dosyaları Kontrol Et

```bash
# SSH ile bağlan
ssh ibrahim@192.168.1.120

# Proje dizinine git
cd ~/premiumfoto

# Dosyalar var mı kontrol et
ls -la app/(public)/fotolar/
ls -la app/api/uploads/list/
```

### 2. Git Pull Yap

```bash
cd ~/premiumfoto
git pull origin main
```

### 3. API Endpoint'leri de Eklenmeli

Eğer `app/api/uploads/list/route.ts` dosyası yoksa, Windows'ta ekleyin:

```powershell
cd "C:\Users\DELL\Desktop\premium foto"
git add "app/api/uploads/list/route.ts"
git commit -m "Add uploads list API endpoint"
git push
```

Sonra sunucuda:
```bash
git pull
```

### 4. Build Yap

```bash
cd ~/premiumfoto
npm run build
```

### 5. PM2 Restart

```bash
pm2 restart foto-ugur-app
```

### 6. Logları Kontrol Et

```bash
pm2 logs foto-ugur-app --lines 50
```

## 🔍 Hızlı Kontrol

```bash
# Dosyalar var mı?
ls -la app/(public)/fotolar/page.tsx
ls -la app/api/uploads/list/route.ts

# Build klasöründe var mı?
ls -la .next/server/app/(public)/fotolar/

# Git'te var mı?
git ls-files | grep fotolar
```

## 🚨 Eğer Hala 404 Veriyorsa

1. **Cache temizle:**
```bash
rm -rf .next
npm run build
pm2 restart foto-ugur-app
```

2. **Next.js route cache:**
```bash
pm2 stop foto-ugur-app
rm -rf .next
npm run build
pm2 start foto-ugur-app
```

3. **Dosya izinleri:**
```bash
chmod -R 755 app/(public)/fotolar/
```

