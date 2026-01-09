# 🔧 Sunucuda Upload İzinlerini Düzeltme

## ❌ Hata
```
{"success":false,"error":"Dosya yazma izni yok"}
```

## ✅ Çözüm

### Sunucuda SSH ile bağlanın ve şu komutları çalıştırın:

```bash
# 1. Proje dizinine git
cd ~/premiumfoto

# 2. Uploads klasörünü oluştur (yoksa)
mkdir -p public/uploads

# 3. Klasör izinlerini düzelt (755 = rwxr-xr-x)
chmod 755 public/uploads

# 4. Tüm dosyalar için yazma izni ver (644 = rw-r--r--)
find public/uploads -type f -exec chmod 644 {} \; 2>/dev/null || true

# 5. Tüm klasörler için izin ver (755)
find public/uploads -type d -exec chmod 755 {} \; 2>/dev/null || true

# 6. Herkesin okuyabilmesi için
chmod -R a+r public/uploads

# 7. PM2 kullanıcısının yazabilmesi için (genellikle ibrahim kullanıcısı)
chown -R ibrahim:ibrahim public/uploads

# 8. Kontrol et
ls -la public/uploads
```

## 🔍 Hızlı Kontrol

```bash
# Klasör var mı?
ls -la public/ | grep uploads

# İzinler doğru mu?
stat -c "%a %n" public/uploads

# Yazma izni var mı?
touch public/uploads/test.txt && rm public/uploads/test.txt && echo "Yazma izni OK" || echo "Yazma izni YOK"
```

## 📋 Tek Komut (Hepsini Birden)

```bash
cd ~/premiumfoto && \
mkdir -p public/uploads && \
chmod 755 public/uploads && \
chmod -R a+r public/uploads && \
chown -R ibrahim:ibrahim public/uploads && \
echo "İzinler düzeltildi!"
```

## 🔄 PM2 Restart (İzinler değişti, restart gerekebilir)

```bash
pm2 restart foto-ugur-app
```

## ✅ Test

İzinleri düzelttikten sonra tekrar deneyin:

```powershell
# Windows'ta
curl.exe -X POST https://fotougur.com.tr/api/upload -F "file=@C:\Users\DELL\Desktop\ornek-resim.jpg"
```

## 🐛 Hala Çalışmazsa

```bash
# PM2 loglarını kontrol et
pm2 logs foto-ugur-app --lines 50

# Uploads klasörünün tam yolunu kontrol et
cd ~/premiumfoto
pwd
ls -la public/uploads
```


