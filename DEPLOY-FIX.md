# Deploy Script Düzeltmesi

## Sorun
Script `/var/www/foto-ugur` dizininde git repository arıyordu, ama siz `~/premiumfoto` dizinindesiniz.

## Çözüm

Script artık mevcut dizinde çalışacak şekilde güncellendi. İki seçeneğiniz var:

### Seçenek 1: Mevcut Dizinde Çalıştırma (Önerilen)

```bash
cd ~/premiumfoto
sudo bash deploy.sh
```

Script otomatik olarak mevcut dizini kullanacak.

### Seçenek 2: APP_DIR Environment Variable ile

```bash
cd ~/premiumfoto
sudo APP_DIR=$(pwd) bash deploy.sh
```

### Seçenek 3: /var/www/foto-ugur'a Taşıma

Eğer `/var/www/foto-ugur` dizininde çalışmasını istiyorsanız:

```bash
# Dizini oluştur
sudo mkdir -p /var/www/foto-ugur

# Dosyaları kopyala veya git clone yap
cd /var/www/foto-ugur
sudo git clone https://github.com/ibraimknk/premiumfoto.git .

# Script'i çalıştır
sudo bash deploy.sh
```

## Hızlı Çözüm (Şu An İçin)

Sunucuda şu komutları çalıştırın:

```bash
cd ~/premiumfoto
git pull origin main  # En son güncellemeleri al
sudo bash deploy.sh
```

Script artık mevcut dizinde çalışacak ve git repository'yi bulacak.

