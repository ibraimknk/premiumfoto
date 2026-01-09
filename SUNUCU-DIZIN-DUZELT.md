# 🔧 Sunucu Dizin Düzeltme

## ❌ Sorun

- Root kullanıcısı olarak giriş yapılmış
- Proje `/home/ibrahim/premiumfoto` dizininde
- Root kullanıcısı `/root/premiumfoto` dizinini arıyor

## 🚀 Çözüm

### Seçenek 1: ibrahim Kullanıcısına Geç

```bash
# ibrahim kullanıcısına geç
su - ibrahim

# Proje dizinine git
cd ~/premiumfoto

# Güncellemeleri çek
git pull origin main

# package.json kontrolü
cat package.json | grep '"start"'

# PM2'yi yeniden başlat
pm2 restart foto-ugur-app

# Durumu kontrol et
pm2 status
```

### Seçenek 2: Root'tan Direkt Erişim

```bash
# Proje dizinine git (ibrahim kullanıcısının dizini)
cd /home/ibrahim/premiumfoto

# Güncellemeleri çek (ibrahim kullanıcısı olarak)
su - ibrahim -c "cd ~/premiumfoto && git pull origin main"

# package.json kontrolü
cat package.json | grep '"start"'

# PM2'yi yeniden başlat (ibrahim kullanıcısı olarak)
su - ibrahim -c "pm2 restart foto-ugur-app"

# Durumu kontrol et
su - ibrahim -c "pm2 status"
```

### Seçenek 3: Tek Komutla (Root'tan)

```bash
# ibrahim kullanıcısı olarak tüm işlemleri yap
su - ibrahim -c "cd ~/premiumfoto && git pull origin main && cat package.json | grep '\"start\"' && pm2 restart foto-ugur-app && pm2 status"
```

## ✅ Doğrulama

```bash
# ibrahim kullanıcısına geç
su - ibrahim

# package.json kontrolü
cd ~/premiumfoto
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

## 📝 Önemli Notlar

1. **PM2:** PM2 ibrahim kullanıcısı altında çalışıyor, root'tan erişilemez
2. **Git:** Git repository ibrahim kullanıcısının dizininde
3. **Dizin:** Proje `/home/ibrahim/premiumfoto` dizininde

## 🔄 Önerilen Yöntem

En kolay yöntem ibrahim kullanıcısına geçmek:

```bash
su - ibrahim
cd ~/premiumfoto
git pull origin main
pm2 restart foto-ugur-app
pm2 status
```

