#!/bin/bash

# Foto Uğur - Sunucu Kurulum Script'i
# Port: 3040
# Kullanım: bash deploy.sh

set -e  # Hata durumunda dur

echo "🚀 Foto Uğur Sunucu Kurulumu Başlatılıyor..."
echo "=========================================="

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Değişkenler
APP_NAME="foto-ugur"
APP_PORT=3040
# Mevcut dizini kullan (script'in çalıştığı dizin)
APP_DIR="${APP_DIR:-$(pwd)}"
NODE_VERSION="20"
PM2_APP_NAME="foto-ugur-app"

# Domain'leri parametre veya environment variable'dan al (3 domain)
# Kullanım: sudo bash deploy.sh domain1.com domain2.com domain3.com
if [ $# -eq 3 ]; then
    # Parametre olarak verilmiş
    DOMAIN1="$1"
    DOMAIN2="$2"
    DOMAIN3="$3"
    echo -e "${GREEN}✅ Domain'ler parametre olarak alındı${NC}"
elif [ -n "$DOMAIN1" ] && [ -n "$DOMAIN2" ] && [ -n "$DOMAIN3" ]; then
    # Environment variable'dan alınmış
    echo -e "${GREEN}✅ Domain'ler environment variable'dan alındı${NC}"
else
    # Kullanıcıdan sor
    echo -e "${YELLOW}📝 Lütfen 3 domain adresi girin:${NC}"
    echo -e "${YELLOW}💡 İpucu: Tek komutla kurulum için: sudo bash deploy.sh domain1.com domain2.com domain3.com${NC}"
    read -p "Domain 1 (örn: fotougur.com.tr): " DOMAIN1
    read -p "Domain 2 (örn: dugunkarem.com): " DOMAIN2
    read -p "Domain 3 (örn: dugunkarem.com.tr): " DOMAIN3
    
    # Boş domain kontrolü
    if [ -z "$DOMAIN1" ] || [ -z "$DOMAIN2" ] || [ -z "$DOMAIN3" ]; then
        echo -e "${RED}❌ Tüm domain'ler girilmelidir!${NC}"
        exit 1
    fi
fi

# Domain'leri temizle (www, http, https kaldır)
DOMAIN1_CLEAN=$(echo "$DOMAIN1" | sed 's|^https\?://||' | sed 's|^www\.||')
DOMAIN2_CLEAN=$(echo "$DOMAIN2" | sed 's|^https\?://||' | sed 's|^www\.||')
DOMAIN3_CLEAN=$(echo "$DOMAIN3" | sed 's|^https\?://||' | sed 's|^www\.||')

# Nginx server_name için domain listesi
NGINX_SERVER_NAMES="${DOMAIN1_CLEAN} www.${DOMAIN1_CLEAN} ${DOMAIN2_CLEAN} www.${DOMAIN2_CLEAN} ${DOMAIN3_CLEAN} www.${DOMAIN3_CLEAN}"

# NEXT_PUBLIC_SITE_URLS için format (https:// ile)
SITE_URLS="https://${DOMAIN1_CLEAN},https://www.${DOMAIN1_CLEAN},https://${DOMAIN2_CLEAN},https://www.${DOMAIN2_CLEAN},https://${DOMAIN3_CLEAN},https://www.${DOMAIN3_CLEAN}"

echo -e "${GREEN}✅ Domain'ler ayarlandı:${NC}"
echo "  • Domain 1: ${DOMAIN1_CLEAN}"
echo "  • Domain 2: ${DOMAIN2_CLEAN}"
echo "  • Domain 3: ${DOMAIN3_CLEAN}"

# Root kontrolü
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Bu script root yetkisi ile çalıştırılmalıdır.${NC}"
    echo "Kullanım: sudo bash deploy.sh"
    exit 1
fi

echo -e "${GREEN}✅ Root yetkisi kontrol edildi${NC}"

# Sistem güncellemesi
echo -e "${YELLOW}📦 Sistem paketleri güncelleniyor...${NC}"
apt-get update -qq
apt-get upgrade -y -qq

# Gerekli paketlerin kurulumu
echo -e "${YELLOW}📦 Gerekli paketler kuruluyor...${NC}"
apt-get install -y -qq \
    curl \
    wget \
    git \
    build-essential \
    nginx \
    certbot \
    python3-certbot-nginx \
    sqlite3 \
    libsqlite3-dev

# Node.js kurulumu (eğer yoksa)
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}📦 Node.js kuruluyor...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt-get install -y -qq nodejs
fi

NODE_VERSION_INSTALLED=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
echo -e "${GREEN}✅ Node.js v${NODE_VERSION_INSTALLED} kurulu${NC}"

# PM2 kurulumu (eğer yoksa)
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}📦 PM2 kuruluyor...${NC}"
    npm install -g pm2
    pm2 startup systemd -u root --hp /root
fi
echo -e "${GREEN}✅ PM2 kurulu${NC}"

# Uygulama dizini kontrolü
echo -e "${YELLOW}📁 Uygulama dizini kontrol ediliyor...${NC}"

# Eğer mevcut dizinde .git yoksa ve APP_DIR farklıysa
if [ ! -d ".git" ] && [ "$(pwd)" != "${APP_DIR}" ]; then
    # APP_DIR dizinini oluştur
    mkdir -p ${APP_DIR}
    if [ ! -d "${APP_DIR}/.git" ]; then
        echo -e "${YELLOW}📥 Git repository'den klonlanıyor...${NC}"
        cd /tmp
        git clone https://github.com/ibraimknk/premiumfoto.git ${APP_DIR} || {
            echo -e "${RED}❌ Git clone başarısız! Lütfen repository URL'ini kontrol edin.${NC}"
            exit 1
        }
    fi
    cd ${APP_DIR}
elif [ ! -d ".git" ]; then
    # Mevcut dizinde .git yoksa, klonla
    echo -e "${YELLOW}📥 Mevcut dizinde Git repository bulunamadı, klonlanıyor...${NC}"
    APP_DIR="$(pwd)"
    if [ "$(ls -A ${APP_DIR} 2>/dev/null)" ]; then
        echo -e "${YELLOW}⚠️  Dizin dolu, içeriği yedekliyoruz...${NC}"
        cd /tmp
        git clone https://github.com/ibraimknk/premiumfoto.git ${APP_DIR}-new || {
            echo -e "${RED}❌ Git clone başarısız!${NC}"
            exit 1
        }
        APP_DIR="${APP_DIR}-new"
    else
        git clone https://github.com/ibraimknk/premiumfoto.git . || {
            echo -e "${RED}❌ Git clone başarısız!${NC}"
            exit 1
        }
    fi
    cd ${APP_DIR}
else
    # Mevcut dizinde çalış
    APP_DIR="$(pwd)"
    echo -e "${GREEN}✅ Mevcut dizin kullanılıyor: ${APP_DIR}${NC}"
fi

# Git repository kontrolü ve güncelleme
if [ -d ".git" ]; then
    echo -e "${YELLOW}🔄 Git repository güncelleniyor...${NC}"
    git pull origin main || git pull origin master || echo -e "${YELLOW}⚠️  Git pull atlandı (zaten güncel olabilir)${NC}"
else
    echo -e "${RED}❌ Git repository bulunamadı!${NC}"
    exit 1
fi

# .env dosyası kontrolü ve oluşturma
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 .env dosyası oluşturuluyor...${NC}"
    cat > .env << EOF
# Database
DATABASE_URL="file:./prisma/dev.db"

# NextAuth
NEXTAUTH_URL="https://${DOMAIN1_CLEAN}"
NEXTAUTH_SECRET="$(openssl rand -base64 32)"

# Node Environment
NODE_ENV=production
PORT=${APP_PORT}

# Multi-Domain Support (3 domain)
NEXT_PUBLIC_SITE_URLS="${SITE_URLS}"
EOF
    echo -e "${GREEN}✅ .env dosyası oluşturuldu${NC}"
    echo -e "${GREEN}✅ NEXT_PUBLIC_SITE_URLS ayarlandı: ${SITE_URLS}${NC}"
else
    echo -e "${GREEN}✅ .env dosyası mevcut${NC}"
    # NEXT_PUBLIC_SITE_URLS'i güncelle (varsa)
    if grep -q "NEXT_PUBLIC_SITE_URLS" .env; then
        sed -i "s|NEXT_PUBLIC_SITE_URLS=.*|NEXT_PUBLIC_SITE_URLS=\"${SITE_URLS}\"|" .env
        echo -e "${GREEN}✅ NEXT_PUBLIC_SITE_URLS güncellendi${NC}"
    else
        echo "NEXT_PUBLIC_SITE_URLS=\"${SITE_URLS}\"" >> .env
        echo -e "${GREEN}✅ NEXT_PUBLIC_SITE_URLS eklendi${NC}"
    fi
    # NEXTAUTH_URL'i güncelle
    if grep -q "NEXTAUTH_URL" .env; then
        sed -i "s|NEXTAUTH_URL=.*|NEXTAUTH_URL=\"https://${DOMAIN1_CLEAN}\"|" .env
        echo -e "${GREEN}✅ NEXTAUTH_URL güncellendi${NC}"
    fi
fi

# Bağımlılıkların kurulumu
echo -e "${YELLOW}📦 NPM paketleri kuruluyor...${NC}"
npm ci --production=false

# Prisma client oluşturma
echo -e "${YELLOW}🗄️  Prisma client oluşturuluyor...${NC}"
npx prisma generate

# Veritabanı oluşturma ve migration
echo -e "${YELLOW}🗄️  Veritabanı oluşturuluyor...${NC}"
npx prisma db push --accept-data-loss

# Seed (veri doldurma)
echo -e "${YELLOW}🌱 Veritabanı seed ediliyor...${NC}"
npm run db:seed || npx tsx prisma/seed.ts

# Production build
echo -e "${YELLOW}🏗️  Production build oluşturuluyor...${NC}"
# .next dizinini temizle ve izinleri düzelt
if [ -d ".next" ]; then
    echo -e "${YELLOW}🧹 Eski build dosyaları temizleniyor...${NC}"
    rm -rf .next
fi
# Build yap
npm run build
# .next dizinine yazma izni ver
if [ -d ".next" ]; then
    chmod -R 755 .next
    echo -e "${GREEN}✅ Build tamamlandı ve izinler ayarlandı${NC}"
fi

# Uploads dizini oluşturma
echo -e "${YELLOW}📁 Uploads dizini oluşturuluyor...${NC}"
mkdir -p public/uploads
chmod 755 public/uploads

# PM2 ile uygulamayı başlatma/durdurma
cd ${APP_DIR}
if pm2 list | grep -q "${PM2_APP_NAME}"; then
    echo -e "${YELLOW}🔄 PM2 uygulaması yeniden başlatılıyor...${NC}"
    pm2 restart ${PM2_APP_NAME}
else
    echo -e "${YELLOW}🚀 PM2 uygulaması başlatılıyor...${NC}"
    pm2 start npm --name "${PM2_APP_NAME}" -- start
    pm2 save
fi

# PM2 durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status
echo -e "${GREEN}✅ PM2 uygulaması başlatıldı${NC}"
echo -e "${YELLOW}💡 Logları görmek için: pm2 logs ${PM2_APP_NAME}${NC}"

# Nginx konfigürasyonu (3 domain için)
echo -e "${YELLOW}🌐 Nginx konfigürasyonu oluşturuluyor (3 domain)...${NC}"
cat > /etc/nginx/sites-available/${APP_NAME} << EOF
server {
    listen 80;
    server_name ${NGINX_SERVER_NAMES};

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Uploads için statik dosya servisi
    location /uploads {
        alias ${APP_DIR}/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
}
EOF

# Nginx site'ı aktif etme
if [ ! -L /etc/nginx/sites-enabled/${APP_NAME} ]; then
    ln -s /etc/nginx/sites-available/${APP_NAME} /etc/nginx/sites-enabled/
fi

# Nginx test ve reload
nginx -t && systemctl reload nginx
echo -e "${GREEN}✅ Nginx konfigürasyonu tamamlandı${NC}"

# Firewall kuralları (eğer ufw aktifse)
if command -v ufw &> /dev/null; then
    echo -e "${YELLOW}🔥 Firewall kuralları ekleniyor...${NC}"
    ufw allow ${APP_PORT}/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    echo -e "${GREEN}✅ Firewall kuralları eklendi${NC}"
fi

# Özet
echo ""
echo -e "${GREEN}=========================================="
echo "✅ Kurulum Tamamlandı!"
echo "==========================================${NC}"
echo ""
echo "📋 Özet:"
echo "  • Uygulama Dizini: ${APP_DIR}"
echo "  • Port: ${APP_PORT}"
echo "  • PM2 App Name: ${PM2_APP_NAME}"
echo "  • Nginx Config: /etc/nginx/sites-available/${APP_NAME}"
echo ""
echo "🔧 Yönetim Komutları:"
echo "  • PM2 Logları: pm2 logs ${PM2_APP_NAME}"
echo "  • PM2 Durum: pm2 status"
echo "  • PM2 Yeniden Başlat: pm2 restart ${PM2_APP_NAME}"
echo "  • PM2 Durdur: pm2 stop ${PM2_APP_NAME}"
echo "  • Nginx Test: nginx -t"
echo "  • Nginx Reload: systemctl reload nginx"
echo ""
echo "📝 Sonraki Adımlar:"
echo "  1. SSL sertifikası için (3 domain):"
echo "     certbot --nginx -d ${DOMAIN1_CLEAN} -d www.${DOMAIN1_CLEAN} -d ${DOMAIN2_CLEAN} -d www.${DOMAIN2_CLEAN} -d ${DOMAIN3_CLEAN} -d www.${DOMAIN3_CLEAN}"
echo "  2. Uygulama loglarını kontrol edin: pm2 logs ${PM2_APP_NAME}"
echo "  3. Site haritasını göndermek için: Admin panel > Settings > SEO"
echo ""
echo "🌐 Yapılandırılan Domain'ler:"
echo "  • ${DOMAIN1_CLEAN} (ve www)"
echo "  • ${DOMAIN2_CLEAN} (ve www)"
echo "  • ${DOMAIN3_CLEAN} (ve www)"
echo ""
echo -e "${GREEN}✅ Tüm domain'ler Nginx'e eklendi ve .env dosyası yapılandırıldı!${NC}"
echo ""

