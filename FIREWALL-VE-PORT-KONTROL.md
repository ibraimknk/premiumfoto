# 🔥 Firewall ve Port Kontrolü

## 🔍 Sorun Tespiti

DNS kayıtları ayarlı ama domain'lere erişilemiyor. Muhtemel nedenler:
1. Firewall port 80 ve 443'ü engelliyor
2. Modem/router'da port forwarding yapılmamış
3. Sunucu local network'te ve dışarıdan erişilemiyor

## 🚀 Çözüm Adımları

### 1. Firewall Kontrolü (Sunucuda)

```bash
# UFW durumunu kontrol et
sudo ufw status

# Eğer aktifse, port 80 ve 443'ü aç
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3041/tcp
sudo ufw reload

# veya iptables kontrolü
sudo iptables -L -n | grep -E "(80|443)"
```

### 2. Port Kontrolü

```bash
# Port 80 ve 443'ün dinlendiğini kontrol et
sudo lsof -i:80
sudo lsof -i:443

# Nginx'in port 80'de dinlediğini kontrol et
sudo netstat -tulpn | grep :80
sudo ss -tulpn | grep :80
```

### 3. Nginx Site Aktif Mi?

```bash
# Nginx site aktif mi kontrol et
ls -la /etc/nginx/sites-enabled/ | grep foto-ugur

# Eğer yoksa, aktif et
sudo ln -sf /etc/nginx/sites-available/foto-ugur /etc/nginx/sites-enabled/

# Nginx test
sudo nginx -t

# Nginx reload
sudo systemctl reload nginx
```

### 4. Modem/Router Port Forwarding

Eğer sunucu local network'teyse (192.168.x.x), modem/router'da port forwarding yapılmalı:

**Gerekli Port Forwarding:**
- Port 80 → Sunucu IP (örn: 192.168.1.120)
- Port 443 → Sunucu IP (örn: 192.168.1.120)

**Modem/Router'a giriş yapın ve:**
1. Port Forwarding / Virtual Server bölümüne gidin
2. Port 80 ve 443'ü sunucu IP'sine yönlendirin
3. Kaydedin ve modem'i yeniden başlatın

### 5. Sunucu IP Kontrolü

```bash
# Sunucu IP'sini kontrol et
ip addr show
# veya
hostname -I

# Dış IP'yi kontrol et
curl ifconfig.me
# veya
curl ipinfo.io/ip
```

### 6. Nginx Log Kontrolü

```bash
# Nginx access log'larını kontrol et
sudo tail -f /var/log/nginx/access.log

# Nginx error log'larını kontrol et
sudo tail -f /var/log/nginx/error.log
```

## 🔥 Tek Komutla Tüm Kontroller

```bash
# Firewall kontrolü ve port açma
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload

# Nginx site aktif et
sudo ln -sf /etc/nginx/sites-available/foto-ugur /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Port kontrolü
sudo lsof -i:80
sudo lsof -i:443

# Sunucu IP
hostname -I
curl ifconfig.me
```

## 🔍 Detaylı Kontrol

### Firewall Detaylı Kontrol

```bash
# UFW kuralları
sudo ufw status verbose

# iptables kuralları
sudo iptables -L -n -v

# Eğer iptables kullanıyorsanız:
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

### Nginx Detaylı Kontrol

```bash
# Nginx config test
sudo nginx -t

# Nginx durumu
sudo systemctl status nginx

# Nginx process'leri
ps aux | grep nginx

# Nginx port kontrolü
sudo netstat -tulpn | grep nginx
```

### Network Kontrolü

```bash
# Network interface'leri
ip addr show

# Routing table
ip route show

# DNS çözümleme
nslookup fotougur.com.tr
dig fotougur.com.tr +short
```

## ✅ Doğrulama

```bash
# 1. Firewall portları açık mı?
sudo ufw status | grep -E "(80|443)"
# Her ikisi de "ALLOW" olmalı

# 2. Nginx port 80'de dinliyor mu?
sudo lsof -i:80 | grep nginx
# nginx process görünmeli

# 3. Nginx site aktif mi?
ls -la /etc/nginx/sites-enabled/ | grep foto-ugur
# Link görünmeli

# 4. Sunucu IP doğru mu?
curl ifconfig.me
# Bu IP DNS kayıtlarında olmalı

# 5. Domain erişilebilir mi?
curl -I http://fotougur.com.tr
# HTTP 200 dönmeli
```

## 🐛 Yaygın Sorunlar

### "Connection refused" Hatası
- Firewall port'u engelliyor → Port'u açın
- Nginx çalışmıyor → `sudo systemctl start nginx`

### "Timeout" Hatası
- Port forwarding yapılmamış → Modem'de port forwarding yapın
- Sunucu local network'te → Dış IP'yi kontrol edin

### "502 Bad Gateway" Hatası
- Uygulama çalışmıyor → `pm2 status` kontrol edin
- Port 3041 kapalı → `curl http://localhost:3041` test edin

