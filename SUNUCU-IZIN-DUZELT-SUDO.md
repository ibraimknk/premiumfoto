# 🔧 Sunucuda Upload İzinlerini Düzeltme (sudo gerekli)

## ❌ Sorun
- `public/uploads` klasörü `www-data` kullanıcısına ait
- Dosyalar `root` kullanıcısına ait
- `ibrahim` kullanıcısı izinleri değiştiremiyor

## ✅ Çözüm (sudo ile)

```bash
# Proje dizinine git
cd ~/premiumfoto

# Uploads klasörünü oluştur (yoksa)
sudo mkdir -p public/uploads

# Klasör sahipliğini ibrahim kullanıcısına ver
sudo chown -R ibrahim:ibrahim public/uploads

# Klasör izinlerini düzelt (755 = rwxr-xr-x)
sudo chmod 755 public/uploads

# Tüm dosyalar için yazma izni ver (644 = rw-r--r--)
sudo find public/uploads -type f -exec chmod 644 {} \;

# Tüm klasörler için izin ver (755)
sudo find public/uploads -type d -exec chmod 755 {} \;

# Herkesin okuyabilmesi için
sudo chmod -R a+r public/uploads

# PM2'nin yazabilmesi için (www-data veya ibrahim)
# Eğer PM2 ibrahim kullanıcısıyla çalışıyorsa:
sudo chown -R ibrahim:ibrahim public/uploads

# Eğer PM2 www-data kullanıcısıyla çalışıyorsa:
# sudo chown -R www-data:www-data public/uploads
# sudo chmod -R 775 public/uploads  # www-data grubuna yazma izni
```

## 📋 Tek Komut (Hepsini Birden)

```bash
cd ~/premiumfoto && \
sudo mkdir -p public/uploads && \
sudo chown -R ibrahim:ibrahim public/uploads && \
sudo chmod 755 public/uploads && \
sudo find public/uploads -type f -exec chmod 644 {} \; && \
sudo find public/uploads -type d -exec chmod 755 {} \; && \
sudo chmod -R a+r public/uploads && \
echo "İzinler düzeltildi!"
```

## 🔍 PM2 Kullanıcısını Kontrol Et

```bash
# PM2 hangi kullanıcıyla çalışıyor?
ps aux | grep "foto-ugur-app" | head -1

# PM2 process bilgisi
pm2 info foto-ugur-app
```

## 🎯 En İyi Çözüm (PM2 ibrahim ile çalışıyorsa)

```bash
cd ~/premiumfoto
sudo chown -R ibrahim:ibrahim public/uploads
sudo chmod -R 755 public/uploads
sudo find public/uploads -type f -exec chmod 644 {} \;
```

## 🔄 PM2 Restart

```bash
pm2 restart foto-ugur-app
```

## ✅ Test

```powershell
# Windows'ta
curl.exe -X POST https://fotougur.com.tr/api/upload -F "file=@C:\Users\DELL\Desktop\ornek-resim.jpg"
```


