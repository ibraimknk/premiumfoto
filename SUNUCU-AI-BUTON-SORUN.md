# 🔧 AI ile Oluştur Butonu Görünmüyor - Çözüm

## ❌ Sorun

- Paket kurulu ✅ (`@google/generative-ai@0.24.1`)
- PM2 restart edildi ✅
- Ama "AI ile Oluştur" butonu görünmüyor ❌

## ✅ Çözüm

### 1. Build Cache'i Temizle ve Yeniden Build Et

```bash
cd ~/premiumfoto

# Build cache'i temizle
rm -rf .next node_modules/.cache

# Yeniden build et
npm run build

# PM2'yi restart et
pm2 restart foto-ugur-app
```

### 2. Tarayıcı Cache'i Temizle

- **Chrome/Edge:** `Ctrl + Shift + Delete` → Cache'i temizle
- **Firefox:** `Ctrl + Shift + Delete` → Cache'i temizle
- Veya **Hard Refresh:** `Ctrl + F5` veya `Ctrl + Shift + R`

### 3. Sayfayı Yeniden Yükle

- Admin panelinde `/admin/blog` sayfasına gidin
- Sayfayı yenileyin (`F5` veya `Ctrl + R`)

## 🔥 Tek Komutla Çözüm

```bash
cd ~/premiumfoto && \
rm -rf .next node_modules/.cache && \
npm run build && \
pm2 restart foto-ugur-app && \
pm2 logs foto-ugur-app --lines 10
```

## ✅ Doğrulama

1. Admin paneline giriş yapın
2. **Blog Yazıları** sayfasına gidin (`/admin/blog`)
3. Sağ üstte **"AI ile Oluştur"** butonunu görmelisiniz
4. Butona tıklayın → `/admin/blog/ai-generate` sayfasına yönlendirilmeli

## 🐛 Hala Görünmüyorsa

### Dosya Kontrolü

```bash
# Sayfa dosyası var mı?
ls -la app/(admin)/admin/blog/ai-generate/page.tsx

# Component dosyası var mı?
ls -la components/features/AIBlogGenerator.tsx

# Blog sayfası güncel mi?
cat app/(admin)/admin/blog/page.tsx | grep "AI ile"
```

### Build Log Kontrolü

```bash
# Son build loglarını kontrol et
pm2 logs foto-ugur-app --lines 50 | grep -i "error\|warn"
```

### Manuel Kontrol

```bash
# Git'ten dosyaların geldiğini kontrol et
cd ~/premiumfoto
git status
git log --oneline -5

# Dosyaların varlığını kontrol et
find . -name "AIBlogGenerator.tsx"
find . -name "ai-generate" -type d
```

