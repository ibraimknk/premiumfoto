#!/bin/bash

# FTP sunucusu kurulumu ve yapılandırması

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FTP_USER="ftp"
FTP_PASSWORD=""
FTP_HOME="/home/ftp"
FTP_PORT=21

echo -e "${BLUE}🔧 FTP Sunucusu Kurulumu${NC}"
echo ""

# 1. vsftpd kurulu mu kontrol et
echo -e "${YELLOW}1️⃣ vsftpd kontrol ediliyor...${NC}"
if ! command -v vsftpd &> /dev/null; then
    echo -e "${YELLOW}📦 vsftpd kuruluyor...${NC}"
    sudo apt update
    sudo apt install -y vsftpd
    echo -e "${GREEN}✅ vsftpd kuruldu${NC}"
else
    echo -e "${GREEN}✅ vsftpd zaten kurulu${NC}"
    vsftpd --version
fi
echo ""

# 2. FTP kullanıcısı oluştur
echo -e "${YELLOW}2️⃣ FTP kullanıcısı oluşturuluyor...${NC}"
if id "$FTP_USER" &>/dev/null; then
    echo -e "${GREEN}✅ FTP kullanıcısı zaten mevcut: $FTP_USER${NC}"
else
    echo -e "${YELLOW}👤 Yeni FTP kullanıcısı oluşturuluyor...${NC}"
    sudo useradd -m -d "$FTP_HOME" -s /bin/bash "$FTP_USER"
    echo -e "${GREEN}✅ FTP kullanıcısı oluşturuldu: $FTP_USER${NC}"
fi

# FTP kullanıcısı için şifre oluştur
if [ -z "$FTP_PASSWORD" ]; then
    echo -e "${YELLOW}🔐 FTP şifresi oluşturuluyor...${NC}"
    FTP_PASSWORD=$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-12)
    echo "$FTP_USER:$FTP_PASSWORD" | sudo chpasswd
    echo -e "${GREEN}✅ FTP şifresi oluşturuldu${NC}"
else
    echo "$FTP_USER:$FTP_PASSWORD" | sudo chpasswd
    echo -e "${GREEN}✅ FTP şifresi güncellendi${NC}"
fi
echo ""

# 3. FTP dizinini yapılandır
echo -e "${YELLOW}3️⃣ FTP dizini yapılandırılıyor...${NC}"
sudo mkdir -p "$FTP_HOME"
sudo chown -R "$FTP_USER:$FTP_USER" "$FTP_HOME"
sudo chmod 755 "$FTP_HOME"
echo -e "${GREEN}✅ FTP dizini hazır: $FTP_HOME${NC}"
echo ""

# 4. vsftpd config dosyasını yedekle ve yapılandır
echo -e "${YELLOW}4️⃣ vsftpd yapılandırılıyor...${NC}"
VSFTPD_CONFIG="/etc/vsftpd.conf"
if [ -f "$VSFTPD_CONFIG" ]; then
    sudo cp "$VSFTPD_CONFIG" "${VSFTPD_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✅ Yedek alındı${NC}"
fi

# vsftpd config oluştur
sudo tee "$VSFTPD_CONFIG" > /dev/null << EOF
# FTP Sunucu Ayarları
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO

# Pasif mod ayarları
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000

# Kullanıcı ayarları
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO

# Log ayarları
xferlog_file=/var/log/vsftpd.log
log_ftp_protocol=YES

# Güvenlik ayarları
tcp_wrappers=YES
allow_writeable_chroot=YES
EOF

echo -e "${GREEN}✅ vsftpd config oluşturuldu${NC}"
echo ""

# 5. FTP kullanıcı listesi oluştur
echo -e "${YELLOW}5️⃣ FTP kullanıcı listesi oluşturuluyor...${NC}"
echo "$FTP_USER" | sudo tee /etc/vsftpd.userlist > /dev/null
echo -e "${GREEN}✅ FTP kullanıcı listesi oluşturuldu${NC}"
echo ""

# 6. Güvenlik duvarı ayarları
echo -e "${YELLOW}6️⃣ Güvenlik duvarı ayarları kontrol ediliyor...${NC}"
if command -v ufw &> /dev/null; then
    echo -e "${YELLOW}🔥 UFW kuralları ekleniyor...${NC}"
    sudo ufw allow $FTP_PORT/tcp
    sudo ufw allow 40000:50000/tcp
    echo -e "${GREEN}✅ UFW kuralları eklendi${NC}"
else
    echo -e "${YELLOW}⚠️  UFW bulunamadı, manuel olarak güvenlik duvarı ayarlarını yapın${NC}"
fi
echo ""

# 7. vsftpd servisini başlat
echo -e "${YELLOW}7️⃣ vsftpd servisi başlatılıyor...${NC}"
sudo systemctl enable vsftpd
sudo systemctl restart vsftpd
sleep 2

if sudo systemctl is-active --quiet vsftpd; then
    echo -e "${GREEN}✅ vsftpd çalışıyor${NC}"
else
    echo -e "${RED}❌ vsftpd başlatılamadı!${NC}"
    sudo systemctl status vsftpd
    exit 1
fi
echo ""

# 8. Sunucu IP adresini bul
echo -e "${YELLOW}8️⃣ Sunucu IP adresi bulunuyor...${NC}"
SERVER_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || hostname -I | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
fi
echo -e "${GREEN}✅ Sunucu IP: $SERVER_IP${NC}"
echo ""

# 9. Bilgileri göster
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ FTP Sunucu Bilgileri${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 FTP Bağlantı Bilgileri:${NC}"
echo -e "   ${BLUE}FTP Server:${NC} $SERVER_IP"
echo -e "   ${BLUE}FTP Port:${NC} $FTP_PORT"
echo -e "   ${BLUE}FTP User:${NC} $FTP_USER"
echo -e "   ${BLUE}FTP Password:${NC} $FTP_PASSWORD"
echo -e "   ${BLUE}FTP Home:${NC} $FTP_HOME"
echo ""
echo -e "${YELLOW}📋 Pasif Mod Port Aralığı:${NC}"
echo -e "   ${BLUE}Min Port:${NC} 40000"
echo -e "   ${BLUE}Max Port:${NC} 50000"
echo ""
echo -e "${YELLOW}📋 Güvenlik Duvarı:${NC}"
echo -e "   ${BLUE}Port ${FTP_PORT}/tcp${NC} açık olmalı"
echo -e "   ${BLUE}Port 40000-50000/tcp${NC} açık olmalı (pasif mod için)"
echo ""
echo -e "${YELLOW}💡 FTP İstemci Ayarları:${NC}"
echo -e "   ${BLUE}Host:${NC} $SERVER_IP"
echo -e "   ${BLUE}Port:${NC} $FTP_PORT"
echo -e "   ${BLUE}Username:${NC} $FTP_USER"
echo -e "   ${BLUE}Password:${NC} $FTP_PASSWORD"
echo -e "   ${BLUE}Pasif Mod:${NC} Aktif"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📝 Not:${NC}"
echo "   - FTP şifresini değiştirmek için: sudo passwd $FTP_USER"
echo "   - FTP dizinini değiştirmek için: sudo usermod -d /yeni/dizin $FTP_USER"
echo "   - vsftpd logları: sudo tail -f /var/log/vsftpd.log"
echo "   - vsftpd durumu: sudo systemctl status vsftpd"
echo ""

