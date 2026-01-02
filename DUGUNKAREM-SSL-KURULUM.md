# 🔒 dugunkarem.com ve dugunkarem.com.tr SSL Kurulumu

## 🚀 Hızlı Kurulum

Sunucuda şu komutu çalıştırın:

```bash
cd ~/premiumfoto
git pull origin main
chmod +x scripts/setup-dugunkarem-ssl.sh
sudo bash scripts/setup-dugunkarem-ssl.sh
```

## 📋 Gereksinimler

1. **Domain'ler DNS'de kayıtlı olmalı:**
   - `dugunkarem.com` → A → 95.70.203.118
   - `dugunkarem.com.tr` → A → 95.70.203.118

2. **Nginx çalışıyor olmalı**

3. **Port 80 ve 443 açık olmalı**

## 🔧 Script Ne Yapar?

1. **Certbot Kurulumu**: Eğer yoksa certbot kurar
2. **Domain Kontrolü**: Domain'lerin erişilebilirliğini kontrol eder
3. **SSL Sertifikası**: Let's Encrypt'ten SSL sertifikası alır
4. **Nginx Yapılandırması**: Nginx config'e SSL yapılandırması ekler
5. **HTTP → HTTPS Yönlendirme**: HTTP trafiğini HTTPS'e yönlendirir
6. **Nginx Reload**: Nginx'i yeniden yükler

## ✅ Doğrulama

### SSL Sertifikası Kontrolü

```bash
sudo certbot certificates
```

Çıktıda `dugunkarem.com` ve `dugunkarem.com.tr` için sertifika görünmeli.

### HTTPS Erişim Testi

```bash
curl -I https://dugunkarem.com
curl -I https://dugunkarem.com.tr
```

Her iki domain için `200 OK` veya `301 Moved Permanently` dönmeli.

### Tarayıcı Testi

Tarayıcıda şu URL'leri açın:
- `https://dugunkarem.com`
- `https://dugunkarem.com.tr`

Her ikisi de güvenli bağlantı (🔒) göstermeli.

## 🔄 Otomatik Yenileme

Certbot otomatik olarak sertifikaları yeniler (90 günde bir). Manuel yenileme için:

```bash
sudo certbot renew
```

## ⚠️ Sorun Giderme

### "Domain does not point to this server" hatası

**Sorun:** DNS kayıtları henüz yayılmamış veya yanlış IP'ye işaret ediyor.

**Çözüm:**
1. DNS kayıtlarını kontrol edin:
   ```bash
   dig dugunkarem.com
   dig dugunkarem.com.tr
   ```
2. Her ikisi de `95.70.203.118` IP'sine işaret etmeli
3. DNS yayılımı için 24-48 saat bekleyin

### "Port 80 is already in use" hatası

**Sorun:** Port 80 başka bir servis tarafından kullanılıyor.

**Çözüm:**
```bash
sudo lsof -i:80
sudo systemctl stop apache2  # Eğer Apache çalışıyorsa
```

### "Nginx config test failed" hatası

**Sorun:** Nginx config'de syntax hatası var.

**Çözüm:**
```bash
sudo nginx -t
# Hata mesajını kontrol edin ve düzeltin
```

### SSL Sertifikası Alınamıyor

**Sorun:** Certbot domain doğrulamasını yapamıyor.

**Çözüm:**
1. Firewall'da port 80 ve 443 açık olmalı:
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```
2. Domain'lerin DNS kayıtlarını kontrol edin
3. Nginx'in çalıştığından emin olun:
   ```bash
   sudo systemctl status nginx
   ```

## 📝 Notlar

1. **www Versiyonları**: Eğer `www.dugunkarem.com` ve `www.dugunkarem.com.tr` için de SSL istiyorsanız, önce DNS kayıtlarını ekleyin, sonra:
   ```bash
   sudo certbot --nginx --expand \
     -d dugunkarem.com \
     -d www.dugunkarem.com \
     -d dugunkarem.com.tr \
     -d www.dugunkarem.com.tr
   ```

2. **Email Bildirimleri**: Certbot sertifika yenileme zamanı geldiğinde `info@fotougur.com.tr` adresine email gönderir.

3. **Sertifika Konumu**: Sertifikalar `/etc/letsencrypt/live/dugunkarem.com/` dizininde saklanır.

## 🔍 İlgili Dosyalar

- `scripts/setup-dugunkarem-ssl.sh` - Ana kurulum scripti
- `/etc/nginx/sites-available/foto-ugur` - Nginx config dosyası
- `/etc/letsencrypt/live/dugunkarem.com/` - SSL sertifikaları

