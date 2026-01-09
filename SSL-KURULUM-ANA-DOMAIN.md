# 🔒 SSL Sertifikası Kurulumu (Ana Domain'ler)

## ❌ Sorun

- ✅ Ana domain'ler çalışıyor (fotougur.com.tr, dugunkarem.com, dugunkarem.com.tr)
- ❌ `www` versiyonları için DNS kayıtları yok
- ❌ SSL sertifikası kurulumu başarısız

## 🚀 Çözüm

### Seçenek 1: Sadece Ana Domain'ler İçin SSL Kur (Önerilen)

```bash
# Sadece ana domain'ler için SSL sertifikası kur
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d dugunkarem.com \
  -d dugunkarem.com.tr
```

### Seçenek 2: www DNS Kayıtlarını Ekle ve Sonra SSL Kur

1. **DNS kayıtlarını ekle:**
   - `www.fotougur.com.tr` → A → 95.70.203.118
   - `www.dugunkarem.com` → A → 95.70.203.118
   - `www.dugunkarem.com.tr` → A → 95.70.203.118

2. **DNS yayılımını bekle (24-48 saat)**

3. **SSL sertifikası kur:**
   ```bash
   sudo certbot --nginx \
     -d fotougur.com.tr \
     -d www.fotougur.com.tr \
     -d dugunkarem.com \
     -d www.dugunkarem.com \
     -d dugunkarem.com.tr \
     -d www.dugunkarem.com.tr
   ```

## ✅ Doğrulama

```bash
# SSL sertifikası kontrolü
sudo certbot certificates

# Domain'lerin HTTPS üzerinden erişilebilirliği
curl -I https://fotougur.com.tr
curl -I https://dugunkarem.com
curl -I https://dugunkarem.com.tr
```

## 📝 Notlar

1. **www DNS Kayıtları:** Eğer `www` versiyonlarını kullanmayacaksanız, sadece ana domain'ler için SSL kurun
2. **Otomatik Yönlendirme:** Certbot otomatik olarak HTTP'den HTTPS'e yönlendirme ekler
3. **Otomatik Yenileme:** Certbot otomatik olarak sertifikaları yeniler (90 günde bir)

## 🔄 www Versiyonlarını Sonra Ekleme

Eğer `www` DNS kayıtlarını sonra eklerseniz:

```bash
# Mevcut sertifikayı genişlet
sudo certbot --nginx --expand \
  -d fotougur.com.tr \
  -d www.fotougur.com.tr \
  -d dugunkarem.com \
  -d www.dugunkarem.com \
  -d dugunkarem.com.tr \
  -d www.dugunkarem.com.tr
```


