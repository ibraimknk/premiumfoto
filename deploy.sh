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
# Eğer APP_DIR mevcut dizinden farklıysa, oluştur ve git clone yap
if [ "$(pwd)" != "${APP_DIR}" ] && [ "${APP_DIR}" != "$(pwd)" ]; then
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
else
    # Mevcut dizinde çalış
    APP_DIR="$(pwd)"
    echo -e "${GREEN}✅ Mevcut dizin kullanılıyor: ${APP_DIR}${NC}"
fi

# Git repository kontrolü
if [ -d ".git" ]; then
    echo -e "${YELLOW}🔄 Git repository güncelleniyor...${NC}"
    git pull origin main || git pull origin master || echo -e "${YELLOW}⚠️  Git pull atlandı (zaten güncel olabilir)${NC}"
else
    echo -e "${YELLOW}⚠️  Git repository bulunamadı. Mevcut dosyalar kullanılacak.${NC}"
fi

# .env dosyası kontrolü ve oluşturma
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 .env dosyası oluşturuluyor...${NC}"
    cat > .env << EOF
# Database
DATABASE_URL="file:./prisma/dev.db"

# NextAuth
NEXTAUTH_URL="http://localhost:${APP_PORT}"
NEXTAUTH_SECRET="$(openssl rand -base64 32)"

# Node Environment
NODE_ENV=production
PORT=${APP_PORT}
EOF
    echo -e "${GREEN}✅ .env dosyası oluşturuldu${NC}"
    echo -e "${YELLOW}⚠️  Lütfen .env dosyasını düzenleyerek gerekli değerleri güncelleyin!${NC}"
else
    echo -e "${GREEN}✅ .env dosyası mevcut${NC}"
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
npm run build

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

# PM2 logları
pm2 logs ${PM2_APP_NAME} --lines 10

# Nginx konfigürasyonu
echo -e "${YELLOW}🌐 Nginx konfigürasyonu oluşturuluyor...${NC}"
cat > /etc/nginx/sites-available/${APP_NAME} << EOF
server {
    listen 80;
    server_name _;  # Domain adresinizi buraya yazın

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
echo "  1. .env dosyasını düzenleyin: nano ${APP_DIR}/.env"
echo "  2. Domain adresinizi Nginx config'e ekleyin"
echo "  3. SSL sertifikası için: certbot --nginx -d yourdomain.com"
echo "  4. Uygulama loglarını kontrol edin: pm2 logs ${PM2_APP_NAME}"
echo ""
echo -e "${YELLOW}⚠️  Önemli: .env dosyasındaki NEXTAUTH_SECRET ve NEXTAUTH_URL değerlerini güncelleyin!${NC}"
echo ""

