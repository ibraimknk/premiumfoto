# 🔧 Sunucu Sorun Çözüm Kılavuzu

## ❌ Tespit Edilen Sorunlar

1. **SSH Bağlantı Sorunu:** `Permission denied (publickey)`
2. **Dizin Yok:** `/home/ibrahim/premiumfoto` dizini yok
3. **Git Repository Yok:** Proje klonlanmamış
4. **SSL DNS Sorunları:** Domain'ler DNS'e kayıtlı değil

## 🔧 Çözüm Adımları

### 1. SSH Bağlantısı Düzeltme

**Seçenek 1: Şifre ile Bağlan (Eğer mümkünse)**
```bash
ssh ibrahim@192.168.1.120
# Şifre isteyecek
```

**Seçenek 2: SSH Key Ekleme**
```bash
# Yerel bilgisayarda SSH key oluştur (eğer yoksa)
ssh-keygen -t rsa -b 4096

# SSH key'i sunucuya kopyala
ssh-copy-id ibrahim@192.168.1.120
```

**Seçenek 3: Root ile Bağlan (Eğer mümkünse)**
```bash
ssh root@192.168.1.120
```

### 2. Sunucuda Projeyi Hazırlama

Sunucuya bağlandıktan sonra:

```bash
# Dizini oluştur
mkdir -p ~/premiumfoto
cd ~/premiumfoto

# Git repository'den klonla
git clone https://github.com/ibraimknk/premiumfoto.git .

# Deploy script'ini çalıştır
sudo bash deploy.sh fotougur.com.tr dugunkarem.com dugunkarem.com.tr
```

### 3. DNS Kayıtlarını Kontrol Etme

SSL sertifikası için domain'lerin DNS kayıtları olmalı:

**Gerekli DNS Kayıtları:**
- `fotougur.com.tr` → A kaydı → `95.70.203.118`
- `www.fotougur.com.tr` → A kaydı → `95.70.203.118`
- `dugunkarem.com` → A kaydı → `95.70.203.118`
- `www.dugunkarem.com` → A kaydı → `95.70.203.118`
- `dugunkarem.com.tr` → A kaydı → `95.70.203.118`
- `www.dugunkarem.com.tr` → A kaydı → `95.70.203.118`

**DNS Kontrol Komutları:**
```bash
# DNS kayıtlarını kontrol et
nslookup fotougur.com.tr
nslookup www.fotougur.com.tr
nslookup dugunkarem.com
nslookup www.dugunkarem.com
nslookup dugunkarem.com.tr
nslookup www.dugunkarem.com.tr
```

### 4. SSL Sertifikası Kurulumu (DNS Hazır Olduktan Sonra)

DNS kayıtları hazır olduktan sonra (genellikle 24 saat içinde):

```bash
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d www.fotougur.com.tr \
  -d dugunkarem.com \
  -d www.dugunkarem.com \
  -d dugunkarem.com.tr \
  -d www.dugunkarem.com.tr
```

**Not:** Eğer `www` kayıtları yoksa, önce ana domain'ler için SSL alın:

```bash
sudo certbot --nginx \
  -d fotougur.com.tr \
  -d dugunkarem.com \
  -d dugunkarem.com.tr
```

## 🚀 Hızlı Kurulum (Tüm Adımlar)

Sunucuya bağlandıktan sonra tek seferde:

```bash
# Dizini oluştur ve projeyi klonla
mkdir -p ~/premiumfoto && cd ~/premiumfoto
git clone https://github.com/ibraimknk/premiumfoto.git .

# Deploy script'ini çalıştır
sudo bash deploy.sh fotougur.com.tr dugunkarem.com dugunkarem.com.tr

# DNS kayıtlarını kontrol et (sunucu IP'si: 95.70.203.118)
echo "DNS kayıtlarını kontrol edin:"
echo "fotougur.com.tr → 95.70.203.118"
echo "dugunkarem.com → 95.70.203.118"
echo "dugunkarem.com.tr → 95.70.203.118"
echo "www versiyonları da aynı IP'ye yönlendirilmeli"
```

## ⚠️ Önemli Notlar

1. **DNS Yayılımı:** DNS kayıtları değiştiğinde 24-48 saat içinde yayılır
2. **SSL Sertifikası:** DNS hazır olmadan SSL sertifikası alınamaz
3. **www Kayıtları:** Eğer `www` kayıtları yoksa, önce ana domain'ler için SSL alın
4. **Firewall:** Port 80 ve 443'in açık olduğundan emin olun

## 🔍 Sorun Giderme

### SSH Bağlantı Sorunu
```bash
# SSH key'i kontrol et
ls -la ~/.ssh/

# SSH key oluştur
ssh-keygen -t rsa -b 4096

# Sunucuya kopyala
ssh-copy-id ibrahim@192.168.1.120
```

### DNS Kontrolü
```bash
# DNS kayıtlarını kontrol et
dig fotougur.com.tr +short
dig www.fotougur.com.tr +short
dig dugunkarem.com +short
dig www.dugunkarem.com +short
```

### Nginx Test
```bash
# Nginx konfigürasyonunu test et
sudo nginx -t

# Nginx durumunu kontrol et
sudo systemctl status nginx
```

