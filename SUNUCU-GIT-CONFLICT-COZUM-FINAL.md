# 🔧 Git Merge Conflict Çözümü - Final

## ❌ Sorun
```
error: Birleştirme ile aşağıdaki izlenmeyen çalışma ağacı dosyalarının üzerine yazılacak:
        app/api/upload/route.ts
```

## ✅ Çözüm (Sunucuda)

### Yöntem 1: Dosyayı Sil ve Git'ten Çek

```bash
cd ~/premiumfoto

# Mevcut dosyayı sil
rm app/api/upload/route.ts

# Git pull yap
git pull

# Eğer dosya gelmediyse, Windows'tan tekrar push edin
```

### Yöntem 2: Dosyayı Taşı ve Pull Yap

```bash
cd ~/premiumfoto

# Mevcut dosyayı başka yere taşı
mv app/api/upload/route.ts /tmp/upload-route-backup.ts

# Git pull yap
git pull

# Eğer gerekirse dosyayı geri al
# cp /tmp/upload-route-backup.ts app/api/upload/route.ts
```

### Yöntem 3: Force Pull (Dikkatli!)

```bash
cd ~/premiumfoto

# Mevcut değişiklikleri at
git reset --hard HEAD

# Remote'dan çek
git fetch origin
git reset --hard origin/main

# Veya
git pull --force
```

## 📋 Sonraki Adımlar

1. **API endpoint'lerini kontrol et:**
```bash
ls -la app/api/upload/route.ts
ls -la app/api/uploads/list/route.ts
ls -la app/(public)/fotolar/
```

2. **Build yap:**
```bash
npm run build
```

3. **PM2 restart:**
```bash
pm2 restart foto-ugur-app
```

