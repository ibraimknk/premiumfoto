#!/bin/bash

# FTP bilgilerini göster

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FTP_USER="ftp"
FTP_PORT=21

echo -e "${BLUE}🔍 FTP Bilgileri Kontrol Ediliyor...${NC}"
echo ""

# 1. vsftpd kurulu mu kontrol et
echo -e "${YELLOW}1️⃣ vsftpd durumu kontrol ediliyor...${NC}"
if command -v vsftpd &> /dev/null; then
    echo -e "${GREEN}✅ vsftpd kurulu${NC}"
    vsftpd --version | head -1
else
    echo -e "${RED}❌ vsftpd kurulu değil!${NC}"
    echo -e "${YELLOW}💡 Kurulum için: sudo bash scripts/setup-ftp-server.sh${NC}"
    exit 1
fi
echo ""

# 2. FTP kullanıcısı var mı kontrol et
echo -e "${YELLOW}2️⃣ FTP kullanıcısı kontrol ediliyor...${NC}"
if id "$FTP_USER" &>/dev/null; then
    echo -e "${GREEN}✅ FTP kullanıcısı mevcut: $FTP_USER${NC}"
else
    echo -e "${RED}❌ FTP kullanıcısı bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Kullanıcı oluşturmak için: sudo bash scripts/setup-ftp-server.sh${NC}"
    exit 1
fi
echo ""

# 3. vsftpd çalışıyor mu kontrol et
echo -e "${YELLOW}3️⃣ vsftpd servisi kontrol ediliyor...${NC}"
if sudo systemctl is-active --quiet vsftpd; then
    echo -e "${GREEN}✅ vsftpd çalışıyor${NC}"
else
    echo -e "${YELLOW}⚠️  vsftpd çalışmıyor, başlatılıyor...${NC}"
    sudo systemctl start vsftpd
    sleep 2
    if sudo systemctl is-active --quiet vsftpd; then
        echo -e "${GREEN}✅ vsftpd başlatıldı${NC}"
    else
        echo -e "${RED}❌ vsftpd başlatılamadı!${NC}"
        sudo systemctl status vsftpd
        exit 1
    fi
fi
echo ""

# 4. Sunucu IP adresini bul
echo -e "${YELLOW}4️⃣ Sunucu IP adresi bulunuyor...${NC}"
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}' || echo "BULUNAMADI")
if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" = "BULUNAMADI" ]; then
    SERVER_IP=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}' || echo "BULUNAMADI")
fi
echo -e "${GREEN}✅ Sunucu IP: $SERVER_IP${NC}"
echo ""

# 5. FTP şifresini göster (eğer shadow dosyasından okuyabiliyorsak)
echo -e "${YELLOW}5️⃣ FTP bilgileri hazırlanıyor...${NC}"
FTP_HOME=$(eval echo ~$FTP_USER)
echo ""

# 6. Bilgileri göster
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ FTP Sunucu Bilgileri${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 FTP Bağlantı Bilgileri:${NC}"
echo -e "   ${BLUE}FTP Server (Host):${NC} $SERVER_IP"
echo -e "   ${BLUE}FTP Port:${NC} $FTP_PORT"
echo -e "   ${BLUE}FTP User (Username):${NC} $FTP_USER"
echo -e "   ${BLUE}FTP Home Directory:${NC} $FTP_HOME"
echo ""
echo -e "${YELLOW}🔐 FTP Şifresi:${NC}"
echo -e "${RED}   ⚠️  Şifre güvenlik nedeniyle gösterilemiyor${NC}"
echo -e "${YELLOW}   💡 Şifreyi görmek veya değiştirmek için:${NC}"
echo -e "      ${BLUE}sudo passwd $FTP_USER${NC}"
echo ""
echo -e "${YELLOW}📋 Pasif Mod Port Aralığı:${NC}"
echo -e "   ${BLUE}Min Port:${NC} 40000"
echo -e "   ${BLUE}Max Port:${NC} 50000"
echo ""
echo -e "${YELLOW}💡 FTP İstemci Ayarları:${NC}"
echo -e "   ${BLUE}Host/Server:${NC} $SERVER_IP"
echo -e "   ${BLUE}Port:${NC} $FTP_PORT"
echo -e "   ${BLUE}Username/User:${NC} $FTP_USER"
echo -e "   ${BLUE}Password:${NC} (yukarıdaki komutla görebilirsiniz)"
echo -e "   ${BLUE}Pasif Mod:${NC} Aktif"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📝 Şifre İşlemleri:${NC}"
echo -e "   ${BLUE}Şifreyi görmek:${NC} sudo passwd -S $FTP_USER"
echo -e "   ${BLUE}Şifreyi değiştirmek:${NC} sudo passwd $FTP_USER"
echo -e "   ${BLUE}Yeni şifre oluşturmak:${NC} echo '$FTP_USER:YENI_SIFRE' | sudo chpasswd"
echo ""
echo -e "${YELLOW}📝 Diğer Komutlar:${NC}"
echo -e "   ${BLUE}vsftpd durumu:${NC} sudo systemctl status vsftpd"
echo -e "   ${BLUE}vsftpd logları:${NC} sudo tail -f /var/log/vsftpd.log"
echo -e "   ${BLUE}FTP dizinini değiştirmek:${NC} sudo usermod -d /yeni/dizin $FTP_USER"
echo ""

