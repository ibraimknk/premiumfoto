# 🔧 Git Pull Conflict Çözümü

## ❌ Sorun

Git pull yaparken yerel değişiklikler var ve merge conflict oluşuyor.

## ✅ Çözüm

### Seçenek 1: Yerel Değişiklikleri Stash Et (Önerilen)

```bash
cd ~/premiumfoto

# Yerel değişiklikleri geçici olarak kaydet
git stash

# Pull yap
git pull origin main

# Stash'i geri al (eğer gerekirse)
# git stash pop
```

### Seçenek 2: Yerel Değişiklikleri Discard Et

```bash
cd ~/premiumfoto

# Yerel değişiklikleri at
git checkout -- app/(admin)/admin/blog/page.tsx
git checkout -- deploy-update.sh
git checkout -- package.json

# Pull yap
git pull origin main
```

### Seçenek 3: Force Pull (Dikkatli!)

```bash
cd ~/premiumfoto

# Yerel değişiklikleri at ve force pull
git fetch origin
git reset --hard origin/main
```

## 🔥 Tek Komutla Çözüm (Stash ile)

```bash
cd ~/premiumfoto && \
git stash && \
git pull origin main && \
rm -rf .next node_modules/.cache && \
npm run build && \
pm2 restart foto-ugur-app
```

## 🔥 Tek Komutla Çözüm (Discard ile)

```bash
cd ~/premiumfoto && \
git checkout -- app/(admin)/admin/blog/page.tsx deploy-update.sh package.json && \
git pull origin main && \
rm -rf .next node_modules/.cache && \
npm run build && \
pm2 restart foto-ugur-app
```

