#!/bin/bash

# Dugunkarem.com için ayrı proje kurulum scripti
# Kullanım: bash deploy-dugunkarem.sh

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Proje ayarları
PROJECT_NAME="dugunkarem"
GIT_REPO="https://github.com/ibraimknk/dugunkarem.git"
APP_DIR="/home/ibrahim/${PROJECT_NAME}"
APP_PORT=3041
PM2_APP_NAME="dugunkarem-app"
DOMAIN="dugunkarem.com"

echo -e "${GREEN}🚀 Dugunkarem.com projesi kuruluyor...${NC}"
echo ""

# Root kontrolü
if [ "$EUID" -eq 0 ]; then 
   echo -e "${RED}❌ Bu script root olarak çalıştırılmamalı!${NC}"
   exit 1
fi

# Sistem paketlerinin kurulumu
echo -e "${YELLOW}📦 Sistem paketleri kontrol ediliyor...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js kuruluyor...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}PM2 kuruluyor...${NC}"
    sudo npm install -g pm2
fi

if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}Nginx kuruluyor...${NC}"
    sudo apt-get update
    sudo apt-get install -y nginx
fi

# Proje dizinini oluştur veya güncelle
echo -e "${YELLOW}📁 Proje dizini hazırlanıyor...${NC}"
if [ -d "$APP_DIR" ]; then
    echo -e "${YELLOW}Mevcut proje güncelleniyor...${NC}"
    cd "$APP_DIR"
    git pull origin main || git pull origin master
else
    echo -e "${YELLOW}Proje klonlanıyor...${NC}"
    cd /home/ibrahim
    git clone "$GIT_REPO" "$APP_DIR"
    cd "$APP_DIR"
fi

# .env dosyası kontrolü
echo -e "${YELLOW}⚙️  .env dosyası kontrol ediliyor...${NC}"
if [ ! -f "$APP_DIR/.env" ]; then
    echo -e "${YELLOW}.env dosyası oluşturuluyor...${NC}"
    cat > "$APP_DIR/.env" << EOF
# Database
DATABASE_URL="file:./prisma/dev.db"

# NextAuth
NEXTAUTH_URL="https://${DOMAIN}"
NEXTAUTH_SECRET="$(openssl rand -base64 32)"

# Node Environment
NODE_ENV=production
PORT=${APP_PORT}

# Site URL
NEXT_PUBLIC_SITE_URL="https://${DOMAIN}"
EOF
    echo -e "${GREEN}✅ .env dosyası oluşturuldu${NC}"
else
    echo -e "${GREEN}✅ .env dosyası mevcut${NC}"
    # PORT'u güncelle
    if ! grep -q "PORT=" "$APP_DIR/.env"; then
        echo "PORT=${APP_PORT}" >> "$APP_DIR/.env"
    fi
    # NEXTAUTH_URL'i güncelle
    sed -i "s|NEXTAUTH_URL=.*|NEXTAUTH_URL=\"https://${DOMAIN}\"|g" "$APP_DIR/.env"
    # NEXT_PUBLIC_SITE_URL'i güncelle
    if ! grep -q "NEXT_PUBLIC_SITE_URL=" "$APP_DIR/.env"; then
        echo "NEXT_PUBLIC_SITE_URL=\"https://${DOMAIN}\"" >> "$APP_DIR/.env"
    else
        sed -i "s|NEXT_PUBLIC_SITE_URL=.*|NEXT_PUBLIC_SITE_URL=\"https://${DOMAIN}\"|g" "$APP_DIR/.env"
    fi
fi

# Bağımlılıkların kurulumu
echo -e "${YELLOW}📦 NPM paketleri kuruluyor...${NC}"
cd "$APP_DIR"
npm ci --production=false

# Prisma client oluşturma
echo -e "${YELLOW}🗄️  Prisma client oluşturuluyor...${NC}"
npx prisma generate || echo -e "${YELLOW}⚠️ Prisma schema bulunamadı, atlanıyor${NC}"

# Veritabanı oluşturma ve migration
if [ -f "$APP_DIR/prisma/schema.prisma" ]; then
    echo -e "${YELLOW}🗄️  Veritabanı oluşturuluyor...${NC}"
    npx prisma db push --accept-data-loss || echo -e "${YELLOW}⚠️ Veritabanı hatası, atlanıyor${NC}"
fi

# Production build
echo -e "${YELLOW}🏗️  Production build oluşturuluyor...${NC}"
if [ -d "$APP_DIR/.next" ]; then
    rm -rf "$APP_DIR/.next"
fi

# package.json'da start script'i kontrol et ve güncelle
if [ -f "$APP_DIR/package.json" ]; then
    # PORT'u package.json'da güncelle (eğer start script'i varsa)
    if grep -q '"start"' "$APP_DIR/package.json"; then
        # start script'inde port varsa güncelle, yoksa ekle
        if grep -q '"start".*"-p"' "$APP_DIR/package.json"; then
            sed -i "s|\"start\".*\"-p\"[^,]*|\"start\": \"next start -p ${APP_PORT}\"|g" "$APP_DIR/package.json"
        else
            sed -i "s|\"start\":[^,]*|\"start\": \"next start -p ${APP_PORT}\"|g" "$APP_DIR/package.json"
        fi
    fi
fi

npm run build

# Uploads dizini oluşturma
echo -e "${YELLOW}📁 Uploads dizini oluşturuluyor...${NC}"
mkdir -p "$APP_DIR/public/uploads"
chmod 755 "$APP_DIR/public/uploads"

# PM2 ile uygulamayı başlatma/durdurma
cd "$APP_DIR"
if pm2 list | grep -q "${PM2_APP_NAME}"; then
    echo -e "${YELLOW}🔄 PM2 uygulaması yeniden başlatılıyor...${NC}"
    pm2 restart "${PM2_APP_NAME}" --update-env
else
    echo -e "${YELLOW}🚀 PM2 uygulaması başlatılıyor...${NC}"
    # PM2 ecosystem dosyası oluştur (PORT environment variable ile)
    cat > "$APP_DIR/ecosystem.config.js" << PM2EOF
module.exports = {
  apps: [{
    name: '${PM2_APP_NAME}',
    script: 'npm',
    args: 'start',
    cwd: '${APP_DIR}',
    env: {
      NODE_ENV: 'production',
      PORT: ${APP_PORT},
      PATH: process.env.PATH
    },
    error_file: '$HOME/.pm2/logs/${PM2_APP_NAME}-error.log',
    out_file: '$HOME/.pm2/logs/${PM2_APP_NAME}-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    instances: 1,
    exec_mode: 'fork'
  }]
}
PM2EOF
    pm2 start "$APP_DIR/ecosystem.config.js"
    pm2 save
fi

# PM2 durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status
echo -e "${GREEN}✅ PM2 uygulaması başlatıldı${NC}"

# Nginx konfigürasyonu
echo -e "${YELLOW}🌐 Nginx konfigürasyonu oluşturuluyor...${NC}"

# Mevcut foto-ugur config'ini kontrol et
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
if [ -f "$FOTO_UGUR_CONFIG" ]; then
    # foto-ugur config'inden dugunkarem.com'u çıkar
    sudo sed -i "s/dugunkarem\.com //g" "$FOTO_UGUR_CONFIG"
    sudo sed -i "s/www\.dugunkarem\.com //g" "$FOTO_UGUR_CONFIG"
fi

# Dugunkarem.com için yeni config oluştur
sudo tee /etc/nginx/sites-available/${PROJECT_NAME} > /dev/null << EOF
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};

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
if [ ! -L /etc/nginx/sites-enabled/${PROJECT_NAME} ]; then
    sudo ln -s /etc/nginx/sites-available/${PROJECT_NAME} /etc/nginx/sites-enabled/
fi

# Nginx test ve reload
echo -e "${YELLOW}🔍 Nginx config test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx konfigürasyonu tamamlandı${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

# Firewall kuralları
echo -e "${YELLOW}🔥 Firewall kuralları kontrol ediliyor...${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    echo -e "${GREEN}✅ Firewall kuralları eklendi${NC}"
fi

echo ""
echo -e "${GREEN}✅ Kurulum tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Özet:${NC}"
echo "   - Proje: ${APP_DIR}"
echo "   - Port: ${APP_PORT}"
echo "   - Domain: ${DOMAIN}"
echo "   - PM2 App: ${PM2_APP_NAME}"
echo ""
echo -e "${YELLOW}💡 Sonraki adımlar:${NC}"
echo "   1. SSL sertifikası kur: sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}"
echo "   2. PM2 logları: pm2 logs ${PM2_APP_NAME}"
echo "   3. Nginx durumu: sudo systemctl status nginx"

