# 🔧 Git Conflict Çözümü

## ❌ Sorun

- Git pull sırasında `deploy.sh` dosyasında yerel değişiklikler var
- `package.json` hala port 3041 gösteriyor (3040 olmalı)

## 🚀 Çözüm

### Seçenek 1: Yerel Değişiklikleri Discard Et (Önerilen)

```bash
cd ~/premiumfoto

# Yerel değişiklikleri at
git checkout -- deploy.sh

# Güncellemeleri çek
git pull origin main

# package.json kontrolü
cat package.json | grep '"start"'
# Çıktı: "start": "next start -p 3040", olmalı

# Eğer hala 3041 ise, manuel düzelt
nano package.json
# "start": "next start -p 3041", satırını bul
# "start": "next start -p 3040", olarak değiştir
# Kaydet: Ctrl+O, Enter, Ctrl+X

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app

# Durumu kontrol et
pm2 status
```

### Seçenek 2: Yerel Değişiklikleri Stash Et

```bash
cd ~/premiumfoto

# Yerel değişiklikleri stash et
git stash

# Güncellemeleri çek
git pull origin main

# package.json kontrolü
cat package.json | grep '"start"'

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app
```

### Seçenek 3: Force Pull (Dikkatli!)

```bash
cd ~/premiumfoto

# Yerel değişiklikleri at ve force pull
git fetch origin
git reset --hard origin/main

# package.json kontrolü
cat package.json | grep '"start"'

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app
```

## 🔥 Tek Komutla Çözüm

```bash
cd ~/premiumfoto && \
git checkout -- deploy.sh && \
git pull origin main && \
sed -i 's/"start": "next start -p 3041"/"start": "next start -p 3040"/' package.json && \
cat package.json | grep '"start"' && \
pm2 restart foto-ugur-app && \
pm2 status
```

## ✅ Doğrulama

```bash
# package.json kontrolü
cat package.json | grep '"start"'
# Çıktı: "start": "next start -p 3040", olmalı

# Port 3040 kontrolü
sudo lsof -i:3040
# node process görünmeli

# PM2 durumu
pm2 status
# foto-ugur-app "online" olmalı

# Uygulama erişilebilir mi?
curl -I http://localhost:3040
# HTTP 200 dönmeli
```

