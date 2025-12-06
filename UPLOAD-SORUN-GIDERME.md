# Upload Sorunu Giderme Kılavuzu

## ✅ Yapılan İyileştirmeler

1. **Detaylı Hata Mesajları**: Artık gerçek hata mesajını göreceksiniz
2. **Response Kontrolü**: API response'unun doğru formatını kontrol ediyor
3. **İzin Kontrolü**: Dosya yazma izni hatalarını tespit ediyor

## 🔧 Sunucuda Yapılacaklar

### 1. Güncellemeleri Çek (ÖNEMLİ!)

```bash
cd ~/premiumfoto && rm public/googlebc2e5d61f8ae55be.html && git pull origin main && npm run build && pm2 restart foto-ugur-app
```

### 2. Upload Klasörü İzinlerini Kontrol Et

```bash
# Klasörün varlığını kontrol et
ls -la ~/premiumfoto/public/uploads

# İzinleri düzelt (gerekirse)
chmod 755 ~/premiumfoto/public/uploads
chown -R $USER:$USER ~/premiumfoto/public/uploads

# Klasör yoksa oluştur
mkdir -p ~/premiumfoto/public/uploads
chmod 755 ~/premiumfoto/public/uploads
```

### 3. PM2 Loglarını Kontrol Et

```bash
# Son 50 satır log
pm2 logs foto-ugur-app --lines 50

# Upload hatalarını filtrele
pm2 logs foto-ugur-app --lines 100 | grep -i "upload\|error"
```

### 4. Test Et

Admin panelinde dosya yüklemeyi tekrar deneyin. Artık daha açıklayıcı hata mesajı göreceksiniz.

## 🔍 Olası Hata Mesajları ve Çözümleri

### "Unauthorized"
- **Sorun**: Oturum sorunu
- **Çözüm**: Admin panelinden çıkış yapıp tekrar giriş yapın

### "Dosya bulunamadı"
- **Sorun**: FormData sorunu
- **Çözüm**: Tarayıcıyı yenileyin ve tekrar deneyin

### "Upload klasörü oluşturulamadı"
- **Sorun**: İzin sorunu
- **Çözüm**: 
  ```bash
  mkdir -p ~/premiumfoto/public/uploads
  chmod 755 ~/premiumfoto/public/uploads
  chown -R $USER:$USER ~/premiumfoto/public/uploads
  ```

### "Dosya yazma izni yok"
- **Sorun**: İzin sorunu
- **Çözüm**: 
  ```bash
  chmod 755 ~/premiumfoto/public/uploads
  chown -R $USER:$USER ~/premiumfoto/public/uploads
  ```

### "Disk dolu"
- **Sorun**: Disk alanı yetersiz
- **Çözüm**: Disk alanını temizleyin

## 📊 Disk Durumu

Mevcut durumunuz:
- **Kullanılan**: 27G
- **Boş**: 30G
- **Toplam**: 59G
- **Kullanım**: %48

Disk alanı yeterli görünüyor, sorun muhtemelen izinlerde.

## ✅ Kontrol Listesi

- [ ] Git pull yapıldı
- [ ] npm run build yapıldı
- [ ] PM2 restart yapıldı
- [ ] Upload klasörü izinleri kontrol edildi
- [ ] PM2 logları kontrol edildi
- [ ] Admin panelinde tekrar test edildi

## 🚀 Hızlı Çözüm (Tüm Adımlar)

```bash
# 1. Git çakışmasını çöz ve güncellemeleri çek
cd ~/premiumfoto && rm public/googlebc2e5d61f8ae55be.html && git pull origin main

# 2. Upload klasörünü oluştur ve izinleri düzelt
mkdir -p ~/premiumfoto/public/uploads
chmod 755 ~/premiumfoto/public/uploads
chown -R $USER:$USER ~/premiumfoto/public/uploads

# 3. Build ve restart
npm run build
pm2 restart foto-ugur-app

# 4. Logları kontrol et
pm2 logs foto-ugur-app --lines 20
```

