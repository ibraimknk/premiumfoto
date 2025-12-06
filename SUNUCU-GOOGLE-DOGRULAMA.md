# Sunucuda Google Doğrulama Dosyası Oluşturma

## 🚀 Tek Komutla Oluşturma

```bash
cd ~/premiumfoto && echo "google-site-verification: googlebc2e5d61f8ae55be" > public/googlebc2e5d61f8ae55be.html
```

## 📝 Adım Adım (Nano ile)

### 1. Proje Dizinine Git
```bash
cd ~/premiumfoto
```

### 2. Public Klasörüne Git
```bash
cd public
```

### 3. Nano ile Dosya Oluştur
```bash
nano googlebc2e5d61f8ae55be.html
```

### 4. İçeriğe Şunu Yazın
```
google-site-verification: googlebc2e5d61f8ae55be
```

### 5. Kaydet ve Çık
- `Ctrl + O` (Kaydet)
- `Enter` (Dosya adını onayla)
- `Ctrl + X` (Çık)

### 6. Üst Dizine Dön
```bash
cd ..
```

## ✅ Doğrulama

### Dosyanın Varlığını Kontrol Et
```bash
ls -la public/googlebc2e5d61f8ae55be.html
```

### Dosya İçeriğini Kontrol Et
```bash
cat public/googlebc2e5d61f8ae55be.html
```

### PM2'yi Yeniden Başlat (Gerekirse)
```bash
pm2 restart foto-ugur-app
```

## 🌐 Tarayıcıda Test Et

Şu URL'leri açın:
- `https://fotougur.com.tr/googlebc2e5d61f8ae55be.html`
- `https://dugunkarem.com/googlebc2e5d61f8ae55be.html`
- `https://dugunkarem.com.tr/googlebc2e5d61f8ae55be.html`

Dosya içeriğini görmelisiniz: `google-site-verification: googlebc2e5d61f8ae55be`

