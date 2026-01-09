# 📁 Sunucuda Dosya Kontrolü ve Git Pull

## ❌ Sorun

- Dosyalar GitHub'a push edildi ✅
- Ama sunucuda dosyalar yok ❌
- `git pull` yapılmamış olabilir

## ✅ Çözüm

### 1. Git Pull Yap

```bash
cd ~/premiumfoto
git pull origin main
```

### 2. Dosyaları Kontrol Et (Tırnak İçinde)

```bash
# AI Generate sayfası
ls -la "app/(admin)/admin/blog/ai-generate/page.tsx"

# AI Generator component
ls -la "components/features/AIBlogGenerator.tsx"

# Gemini utility
ls -la "lib/gemini.ts"

# Blog sayfasında buton var mı?
cat "app/(admin)/admin/blog/page.tsx" | grep "AI ile"
```

### 3. Eğer Dosyalar Yoksa

```bash
# Git durumunu kontrol et
cd ~/premiumfoto
git status

# Son commit'leri kontrol et
git log --oneline -5

# Tüm değişiklikleri çek
git fetch origin
git pull origin main
```

### 4. Dosyalar Geldikten Sonra

```bash
# Build cache'i temizle
rm -rf .next node_modules/.cache

# Build et
npm run build

# PM2'yi restart et
pm2 restart foto-ugur-app
```

## 🔥 Tek Komutla Tüm İşlemler

```bash
cd ~/premiumfoto && \
git pull origin main && \
ls -la "app/(admin)/admin/blog/ai-generate/page.tsx" && \
ls -la "components/features/AIBlogGenerator.tsx" && \
rm -rf .next node_modules/.cache && \
npm run build && \
pm2 restart foto-ugur-app
```

