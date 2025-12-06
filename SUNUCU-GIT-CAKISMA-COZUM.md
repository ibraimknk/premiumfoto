# Git Çakışma Çözümü

## 🔧 Hızlı Çözüm

Sunucuda şu komutu çalıştırın:

```bash
cd ~/premiumfoto && rm public/googlebc2e5d61f8ae55be.html && git pull origin main && npm run build && pm2 restart foto-ugur-app
```

## 📝 Adım Adım

### 1. Mevcut Dosyayı Sil
```bash
rm ~/premiumfoto/public/googlebc2e5d61f8ae55be.html
```

### 2. Git Pull Yap
```bash
cd ~/premiumfoto
git pull origin main
```

### 3. Build ve Restart
```bash
npm run build
pm2 restart foto-ugur-app
```

## ✅ Alternatif: Dosyayı Yedekle

Eğer dosyayı silmek istemiyorsanız:

```bash
# Dosyayı yedekle
mv ~/premiumfoto/public/googlebc2e5d61f8ae55be.html ~/premiumfoto/public/googlebc2e5d61f8ae55be.html.backup

# Git pull yap
cd ~/premiumfoto
git pull origin main

# Build ve restart
npm run build
pm2 restart foto-ugur-app
```

## 🔍 Dosya Kontrolü

Pull işleminden sonra dosyanın geldiğini kontrol edin:

```bash
cat ~/premiumfoto/public/googlebc2e5d61f8ae55be.html
```

Çıktı şöyle olmalı:
```
google-site-verification: googlebc2e5d61f8ae55be
```

