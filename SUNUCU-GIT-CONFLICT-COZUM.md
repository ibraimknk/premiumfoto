# 🔧 Git Merge Conflict Çözümü

## ❌ Sorun
```
error: Birleştirme ile aşağıdaki izlenmeyen çalışma ağacı dosyalarının üzerine yazılacak:
        app/api/upload/route.ts
```

## ✅ Çözüm

### Sunucuda:

```bash
cd ~/premiumfoto

# Mevcut değişiklikleri sakla (backup)
cp app/api/upload/route.ts app/api/upload/route.ts.backup

# Git'ten gelen değişiklikleri kabul et
git checkout --theirs app/api/upload/route.ts

# Veya mevcut dosyayı koru
# git checkout --ours app/api/upload/route.ts

# Sonra pull yap
git pull

# Eğer hala conflict varsa
git add app/api/upload/route.ts
git commit -m "Resolve merge conflict in upload route"
```

### Veya Daha Basit:

```bash
cd ~/premiumfoto

# Mevcut dosyayı sil ve git'ten çek
rm app/api/upload/route.ts
git pull

# Dosya gelmediyse Windows'tan tekrar push edin
```

## 📋 API Endpoint'lerini Ekle

Windows'ta:

```powershell
cd "C:\Users\DELL\Desktop\premium foto"
git add "app/api/uploads/list/route.ts" "app/api/upload/route.ts"
git commit -m "Add upload API endpoints"
git push
```

Sonra sunucuda:
```bash
git pull
npm run build
pm2 restart foto-ugur-app
```

