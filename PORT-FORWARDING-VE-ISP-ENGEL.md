# 🔧 Port Forwarding ve ISP Engeli Çözümü

## ✅ Durum

- ✅ DNS kayıtları doğru (95.70.203.118)
- ✅ Nginx çalışıyor (port 80'de dinliyor)
- ✅ Uygulama çalışıyor (port 3041)
- ❌ Domain'lere erişilemiyor

## 🔍 Sorun Tespiti

### 1. Port Forwarding Kontrolü

Modem/router'da port forwarding yapılmış mı kontrol edin:

**Gerekli Port Forwarding:**
- Port 80 → 192.168.1.120
- Port 443 → 192.168.1.120

### 2. ISP Port Engeli

Bazı ISP'ler port 80'i engelleyebilir. Kontrol için:

```bash
# Dışarıdan port 80'e erişim testi
# Başka bir bilgisayardan veya online tool kullanın:
# https://www.yougetsignal.com/tools/open-ports/
# veya
# https://canyouseeme.org/
```

### 3. Modem Router Port Kullanımı

Bazı modem/router'lar port 80'i kendi yönetim paneli için kullanır. Kontrol:

```bash
# Modem/router yönetim paneli genellikle:
# http://192.168.1.1 veya http://192.168.0.1
# Eğer port 80 kullanılıyorsa, farklı bir port kullanın
```

## 🚀 Çözümler

### Çözüm 1: Port Forwarding Yapma

1. Modem/router yönetim paneline giriş yapın
2. Port Forwarding / Virtual Server bölümüne gidin
3. Şu kuralları ekleyin:
   - **HTTP:**
     - Dış Port: 80
     - İç Port: 80
     - İç IP: 192.168.1.120
     - Protokol: TCP
   - **HTTPS:**
     - Dış Port: 443
     - İç Port: 443
     - İç IP: 192.168.1.120
     - Protokol: TCP
4. Kaydedin ve modem'i yeniden başlatın

### Çözüm 2: Alternatif Port Kullanma (ISP Engeli Varsa)

Eğer ISP port 80'i engelliyorsa, alternatif port kullanın:

```bash
# Nginx config'i düzenle
sudo nano /etc/nginx/sites-available/foto-ugur
```

Şu şekilde değiştirin:
```nginx
server {
    listen 8080;  # Port 80 yerine 8080
    server_name fotougur.com.tr www.fotougur.com.tr dugunkarem.com www.dugunkarem.com dugunkarem.com.tr www.dugunkarem.com.tr;
    # ... geri kalan aynı
}
```

Port forwarding:
- Dış Port: 8080 → İç Port: 8080 → İç IP: 192.168.1.120

Domain erişimi: `http://fotougur.com.tr:8080`

### Çözüm 3: Cloudflare veya Reverse Proxy Kullanma

Eğer port forwarding yapamıyorsanız:

1. **Cloudflare Tunnel** kullanın
2. **ngrok** gibi bir reverse proxy kullanın
3. **VPS** kiralayın (sunucu dışarıdan erişilebilir olsun)

## 🔍 Test Komutları

### Local Test

```bash
# Local test
curl -I http://localhost:3041
# HTTP 200 dönmeli

# Nginx üzerinden test
curl -I http://localhost
# HTTP 200 dönmeli
```

### Dışarıdan Test

Port forwarding yapıldıktan sonra:

```bash
# Domain erişimini test et
curl -I http://fotougur.com.tr
curl -I http://dugunkarem.com
curl -I http://dugunkarem.com.tr

# Nginx loglarını kontrol et
sudo tail -f /var/log/nginx/access.log
# Dış IP'den istekler görünmeli
```

### Port Erişim Testi

Başka bir bilgisayardan veya online tool ile:
- https://www.yougetsignal.com/tools/open-ports/
- IP: 95.70.203.118
- Port: 80
- Test edin

## 📝 Önemli Notlar

1. **Port Forwarding:** Modem/router'da mutlaka yapılmalı
2. **ISP Engeli:** Bazı ISP'ler port 80'i engelleyebilir
3. **Modem Port:** Modem/router port 80'i kullanıyorsa, farklı port kullanın
4. **Firewall:** Modem/router firewall'u port'u engelliyor olabilir

## ✅ Doğrulama

Port forwarding yapıldıktan sonra:

```bash
# Domain erişimini test et
curl -I http://fotougur.com.tr
# HTTP 200 dönmeli

# Nginx loglarını kontrol et
sudo tail -f /var/log/nginx/access.log
# Dış IP'den (95.70.203.118) istekler görünmeli
```

