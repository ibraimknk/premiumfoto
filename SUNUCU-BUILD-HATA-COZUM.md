# Build Hatası Çözümü - trendyol-manager

## 🔴 Sorun

Build sırasında şu hata oluşuyor:
```
Type error: Cannot find module '@/components/layout/Sidebar' or its corresponding type declarations.
./trendyol-manager/frontend/app/accounting/page.tsx:5:21
```

## ✅ Çözüm 1: trendyol-manager Klasörünü Taşı (Önerilen)

Sunucuda şu komutları çalıştırın:

```bash
cd ~/premiumfoto

# trendyol-manager klasörünü geçici olarak taşı
if [ -d "trendyol-manager" ]; then
    mv trendyol-manager trendyol-manager.backup
    echo "✅ trendyol-manager klasörü taşındı"
fi

# Git pull yap
git pull

# Build yap
npm run build

# PM2 restart
pm2 restart foto-ugur-app
```

## ✅ Çözüm 2: Script ile Otomatik Düzeltme

```bash
cd ~/premiumfoto
git pull
bash scripts/fix-build-trendyol.sh
npm run build
pm2 restart foto-ugur-app
```

## ✅ Çözüm 3: Manuel Silme (Eğer Gereksizse)

```bash
cd ~/premiumfoto

# trendyol-manager klasörünü sil (eğer gereksizse)
rm -rf trendyol-manager

# Git pull yap
git pull

# Build yap
npm run build

# PM2 restart
pm2 restart foto-ugur-app
```

## 🔍 Kontrol

Build sonrası kontrol:

```bash
# Build başarılı mı?
pm2 logs foto-ugur-app --lines 20

# trendyol-manager klasörü var mı?
ls -la ~/premiumfoto/ | grep trendyol
```

## 📝 Notlar

1. **trendyol-manager klasörü**: Bu klasör projeye ait değil, başka bir projeden kalmış olabilir
2. **Yedekleme**: Eğer bu klasörü kullanıyorsanız, önce yedek alın
3. **Git**: Bu klasör `.gitignore`'a eklendi, artık Git'e commit edilmeyecek

## 🚀 Hızlı Çözüm (Tek Komut)

```bash
cd ~/premiumfoto && \
[ -d "trendyol-manager" ] && mv trendyol-manager trendyol-manager.backup && \
git pull && \
npm run build && \
pm2 restart foto-ugur-app
```
