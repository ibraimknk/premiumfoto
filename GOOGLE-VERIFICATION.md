# Google Search Console Doğrulama

## ✅ Dosya Oluşturuldu

Google doğrulama dosyası oluşturuldu:
- **Dosya:** `public/googlebc2e5d61f8ae55be.html`
- **URL:** `https://yourdomain.com/googlebc2e5d61f8ae55be.html`

## 📝 Sunucuda Kontrol

Dosya zaten projeye eklendi. Sunucuda şu adımları izleyin:

### 1. GitHub'dan Güncellemeleri Çekin

```bash
cd ~/premiumfoto
git pull origin main
```

### 2. Dosyanın Varlığını Kontrol Edin

```bash
ls -la public/googlebc2e5d61f8ae55be.html
```

### 3. Dosya İçeriğini Kontrol Edin

```bash
cat public/googlebc2e5d61f8ae55be.html
```

Çıktı şöyle olmalı:
```
google-site-verification: googlebc2e5d61f8ae55be
```

### 4. Eğer Dosya Yoksa (Nano ile Oluşturma)

```bash
nano public/googlebc2e5d61f8ae55be.html
```

İçeriğe şunu yazın:
```
google-site-verification: googlebc2e5d61f8ae55be
```

Kaydetmek için: `Ctrl + O`, Enter, `Ctrl + X`

## 🔍 Doğrulama

1. Tarayıcıda şu URL'leri açın:
   - `https://fotougur.com.tr/googlebc2e5d61f8ae55be.html`
   - `https://dugunkarem.com/googlebc2e5d61f8ae55be.html`
   - `https://dugunkarem.com.tr/googlebc2e5d61f8ae55be.html`

2. Dosya içeriğini görmelisiniz: `google-site-verification: googlebc2e5d61f8ae55be`

3. Google Search Console'da "Doğrula" butonuna tıklayın

## ⚠️ Notlar

- Dosya `public` klasöründe olmalı (Next.js otomatik olarak sunar)
- Dosya adı tam olarak `googlebc2e5d61f8ae55be.html` olmalı
- İçerik sadece doğrulama kodunu içermeli (dosya uzantısı olmadan)
- Her domain için aynı dosya kullanılabilir (tüm domain'ler aynı sunucuda)

## 🔄 PM2 Restart (Gerekirse)

Dosyayı ekledikten sonra uygulamayı yeniden başlatın:

```bash
pm2 restart foto-ugur-app
```

