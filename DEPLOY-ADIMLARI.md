# 📋 Deploy Adımları - Açıklamalı

## 🔍 Nerede Ne Yapılacak?

### 1️⃣ **Windows Bilgisayarınızda (Local) - PowerShell Script'leri**

PowerShell script'lerini **Windows bilgisayarınızda** çalıştıracaksınız:
- `test-upload-working.ps1`
- `test-upload-alternative.ps1`

**Bu script'ler fotoğrafı sunucuya gönderir.**

### 2️⃣ **Sunucuda (SSH ile) - API Endpoint**

API endpoint'i **sunucuda** deploy etmeniz gerekiyor.

---

## 🚀 Adım Adım Deploy

### ADIM 1: Windows'ta Git Commit

```powershell
# Windows PowerShell'de (C:\Users\DELL\Desktop\premium foto dizininde)
cd "C:\Users\DELL\Desktop\premium foto"

# Değişiklikleri kontrol et
git status

# Değişiklikleri ekle
git add app/api/upload/route.ts

# Commit yap
git commit -m "Add image upload API endpoint"

# Sunucuya gönder
git push
```

### ADIM 2: Sunucuya SSH ile Bağlan

```powershell
# Windows PowerShell'de
ssh ibrahim@192.168.1.120
```

### ADIM 3: Sunucuda Deploy

```bash
# Sunucuda (SSH bağlantısından sonra)
cd ~/premiumfoto

# Yeni dosyaları çek
git pull

# Build yap
npm run build

# PM2 restart
pm2 restart foto-ugur-app

# Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

### ADIM 4: Windows'ta Test Et

```powershell
# Windows PowerShell'de (SSH bağlantısını kapat, Windows'a dön)
.\test-upload-working.ps1 -FilePath "C:\Users\DELL\Desktop\ornek-resim.jpg"
```

---

## 📝 Özet

1. **Windows'ta**: Git commit + push
2. **Sunucuda (SSH)**: Git pull + build + restart
3. **Windows'ta**: PowerShell script çalıştır

---

## ❓ Hala "Failed to parse body as FormData" Hatası Alıyorsanız

Bu, multipart/form-data formatının Next.js tarafından parse edilemediği anlamına geliyor. 

**Çözüm**: Route dosyasını güncellememiz gerekiyor. Next.js'in body parser'ını bypass edip manuel parse yapalım.

