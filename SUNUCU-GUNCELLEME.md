# Sunucuda Güncelleme Adımları

## 1. Git Pull Çakışmasını Çöz

```bash
cd ~/premiumfoto

# Çakışan test dosyalarını sil (sunucuda gerekli değil)
rm -f test-api-simple.ps1 test-upload-alternative.ps1 test-upload-final.ps1 test-upload-fixed.ps1 test-upload-ps5.ps1 test-upload-simple.ps1 test-upload-working.ps1 test-upload.ps1

# Git pull yap
git pull

# Eğer hala çakışma varsa, force pull
git fetch origin
git reset --hard origin/main
```

## 2. Build ve Restart

```bash
# Build yap
npm run build

# PM2 restart
pm2 restart foto-ugur-app

# Logları kontrol et
pm2 logs foto-ugur-app --lines 50
```

## 3. Dosya Kontrolü

```bash
# Delete route'un var olduğunu kontrol et
ls -la app/api/uploads/delete/route.ts

# Fotolar sayfasını kontrol et
ls -la "app/(public)/fotolar/page.tsx"

# İçeriğini kontrol et (delete butonu var mı?)
grep -n "handleDelete" "app/(public)/fotolar/page.tsx"
```

## 4. Tarayıcı Cache Temizle

- Tarayıcıda `Ctrl + Shift + R` (hard refresh)
- Veya `Ctrl + F5`
- Veya Developer Tools > Network > "Disable cache" işaretle

## 5. PM2 Log Kontrolü

```bash
# Hata var mı kontrol et
pm2 logs foto-ugur-app --err --lines 100

# Son 50 satır
pm2 logs foto-ugur-app --lines 50
```
