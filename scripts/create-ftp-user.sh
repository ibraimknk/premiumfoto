#!/bin/bash

# FTP kullanıcısı oluştur ve şifre ata

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FTP_USER="ftp"
FTP_HOME="/home/ftp"
FTP_PORT=21

echo -e "${BLUE}🔧 FTP Kullanıcısı Oluşturuluyor...${NC}"
echo ""

# 1. FTP kullanıcısı oluştur
echo -e "${YELLOW}1️⃣ FTP kullanıcısı oluşturuluyor...${NC}"
if id "$FTP_USER" &>/dev/null; then
    echo -e "${GREEN}✅ FTP kullanıcısı zaten mevcut: $FTP_USER${NC}"
else
    echo -e "${YELLOW}👤 Yeni FTP kullanıcısı oluşturuluyor...${NC}"
    sudo useradd -m -d "$FTP_HOME" -s /bin/bash "$FTP_USER"
    echo -e "${GREEN}✅ FTP kullanıcısı oluşturuldu: $FTP_USER${NC}"
fi
echo ""

# 2. FTP dizinini yapılandır
echo -e "${YELLOW}2️⃣ FTP dizini yapılandırılıyor...${NC}"
sudo mkdir -p "$FTP_HOME"
sudo chown -R "$FTP_USER:$FTP_USER" "$FTP_HOME"
sudo chmod 755 "$FTP_HOME"
echo -e "${GREEN}✅ FTP dizini hazır: $FTP_HOME${NC}"
echo ""

# 3. Şifre oluştur
echo -e "${YELLOW}3️⃣ FTP şifresi oluşturuluyor...${NC}"
FTP_PASSWORD=$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-12)
echo "$FTP_USER:$FTP_PASSWORD" | sudo chpasswd
echo -e "${GREEN}✅ FTP şifresi oluşturuldu${NC}"
echo ""

# 4. vsftpd config kontrolü
echo -e "${YELLOW}4️⃣ vsftpd config kontrol ediliyor...${NC}"
VSFTPD_CONFIG="/etc/vsftpd.conf"
if [ -f "$VSFTPD_CONFIG" ]; then
    # Kullanıcı listesine ekle
    if ! sudo grep -q "^$FTP_USER$" /etc/vsftpd.userlist 2>/dev/null; then
        echo "$FTP_USER" | sudo tee -a /etc/vsftpd.userlist > /dev/null
        echo -e "${GREEN}✅ FTP kullanıcısı listeye eklendi${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  vsftpd config bulunamadı, oluşturuluyor...${NC}"
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
    echo "$FTP_USER" | sudo tee /etc/vsftpd.userlist > /dev/null
    echo -e "${GREEN}✅ vsftpd config oluşturuldu${NC}"
fi
echo ""

# 5. vsftpd servisini başlat
echo -e "${YELLOW}5️⃣ vsftpd servisi kontrol ediliyor...${NC}"
if command -v vsftpd &> /dev/null; then
    sudo systemctl enable vsftpd 2>/dev/null || true
    sudo systemctl restart vsftpd 2>/dev/null || true
    sleep 2
    if sudo systemctl is-active --quiet vsftpd 2>/dev/null; then
        echo -e "${GREEN}✅ vsftpd çalışıyor${NC}"
    else
        echo -e "${YELLOW}⚠️  vsftpd başlatılamadı (normal olabilir, henüz kurulmamış olabilir)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  vsftpd kurulu değil${NC}"
    echo -e "${YELLOW}💡 Kurulum için: sudo apt install -y vsftpd${NC}"
fi
echo ""

# 6. Sunucu IP adresini bul
echo -e "${YELLOW}6️⃣ Sunucu IP adresi bulunuyor...${NC}"
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}' || echo "BULUNAMADI")
fi
echo -e "${GREEN}✅ Sunucu IP: $SERVER_IP${NC}"
echo ""

# 7. Bilgileri göster
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ FTP Kullanıcısı Oluşturuldu${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 FTP Bağlantı Bilgileri:${NC}"
echo -e "   ${BLUE}FTP Server (Host):${NC} $SERVER_IP"
echo -e "   ${BLUE}FTP Port:${NC} $FTP_PORT"
echo -e "   ${BLUE}FTP User (Username):${NC} $FTP_USER"
echo -e "   ${BLUE}FTP Password:${NC} ${FTP_PASSWORD}"
echo -e "   ${BLUE}FTP Home Directory:${NC} $FTP_HOME"
echo ""
echo -e "${YELLOW}💡 FTP İstemci Ayarları:${NC}"
echo -e "   ${BLUE}Host/Server:${NC} $SERVER_IP"
echo -e "   ${BLUE}Port:${NC} $FTP_PORT"
echo -e "   ${BLUE}Username/User:${NC} $FTP_USER"
echo -e "   ${BLUE}Password:${NC} ${FTP_PASSWORD}"
echo -e "   ${BLUE}Pasif Mod:${NC} Aktif (Port: 40000-50000)"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📝 Not:${NC}"
echo "   - Bu bilgileri kaydedin, başka bir yerde kullanabilirsiniz"
echo "   - Şifreyi değiştirmek için: sudo passwd $FTP_USER"
echo "   - vsftpd kurulumu için: sudo apt install -y vsftpd"
echo ""

