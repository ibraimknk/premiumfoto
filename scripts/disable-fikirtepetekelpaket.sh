#!/bin/bash

# fikirtepetekelpaket.com'u devre dışı bırak

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 fikirtepetekelpaket.com devre dışı bırakılıyor...${NC}"

# 1. PM2'de aktas-market'i durdur ve sil
echo -e "${YELLOW}🛑 PM2'de aktas-market durduruluyor...${NC}"
if pm2 list | grep -q "aktas-market"; then
    pm2 stop aktas-market || true
    pm2 delete aktas-market || true
    echo -e "${GREEN}✅ aktas-market PM2'den silindi${NC}"
else
    echo -e "${YELLOW}⚠️  aktas-market zaten PM2'de yok${NC}"
fi

# 2. Port 3001'i temizle
echo -e "${YELLOW}🧹 Port 3001 temizleniyor...${NC}"
if sudo lsof -i:3001 > /dev/null 2>&1; then
    sudo fuser -k 3001/tcp 2>/dev/null || true
    sudo lsof -ti:3001 | xargs sudo kill -9 2>/dev/null || true
    sleep 2
    echo -e "${GREEN}✅ Port 3001 temizlendi${NC}"
fi

# 3. Nginx config'lerinde fikirtepetekelpaket.com'u devre dışı bırak
echo -e "${YELLOW}📝 Nginx config'leri güncelleniyor...${NC}"

NGINX_CONFIGS=(
    "/etc/nginx/sites-available/foto-ugur"
    "/etc/nginx/sites-available/fikirtepetekelpaket"
)

for config in "${NGINX_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        # Yedek al (sudo ile)
        sudo cp "$config" "${config}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # fikirtepetekelpaket.com içeren server block'ları yorum satırına al
        # Python ile daha güvenli düzeltme (sudo ile)
        sudo python3 << PYEOF
import re

config_file = "$config"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# fikirtepetekelpaket.com içeren server block'ları bul ve yorum satırına al
lines = content.split('\n')
in_fikirtepe_block = False
in_server_block = False
block_start = -1
result_lines = []
i = 0

while i < len(lines):
    line = lines[i]
    
    # Server block başlangıcı
    if 'server {' in line or 'server{' in line:
        in_server_block = True
        block_start = i
        # Bu satırdan önce fikirtepetekelpaket.com var mı kontrol et
        check_lines = lines[max(0, i-10):i+1]
        if any('fikirtepetekelpaket.com' in l for l in check_lines):
            in_fikirtepe_block = True
    
    # Server block içinde fikirtepetekelpaket.com var mı?
    if in_server_block and 'fikirtepetekelpaket.com' in line:
        in_fikirtepe_block = True
    
    # Server block sonu
    if in_server_block and line.strip() == '}':
        if in_fikirtepe_block:
            # Bu block'u yorum satırına al
            for j in range(block_start, i + 1):
                if not lines[j].strip().startswith('#'):
                    result_lines.append('    # ' + lines[j])
                else:
                    result_lines.append(lines[j])
            in_fikirtepe_block = False
        else:
            # Normal block, olduğu gibi ekle
            for j in range(block_start, i + 1):
                result_lines.append(lines[j])
        in_server_block = False
        block_start = -1
        i += 1
        continue
    
    # Eğer fikirtepe block içindeysek ve henüz server block başlamadıysa
    if not in_server_block:
        if 'fikirtepetekelpaket.com' in line and not line.strip().startswith('#'):
            # Tek satırlık direktifleri de yorum satırına al
            result_lines.append('    # ' + line)
        else:
            result_lines.append(line)
    
    i += 1

# Eğer açık kalan server block varsa
if in_server_block and in_fikirtepe_block:
    for j in range(block_start, len(lines)):
        if not lines[j].strip().startswith('#'):
            result_lines.append('    # ' + lines[j])
        else:
            result_lines.append(lines[j])

content = '\n'.join(result_lines)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF
        
        echo -e "${GREEN}✅ $config güncellendi${NC}"
    else
        echo -e "${YELLOW}⚠️  Config bulunamadı: $config${NC}"
    fi
done

# 4. Nginx config'ini test et ve reload et
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}💡 Yedek dosyalardan geri yükleyin${NC}"
    exit 1
fi

# 5. PM2 durumu
echo ""
echo -e "${YELLOW}📊 PM2 durumu:${NC}"
pm2 status

# 6. Port durumları
echo ""
echo -e "${YELLOW}🔍 Port durumları:${NC}"
echo "Port 3040:"
sudo lsof -i:3040 | head -2 || echo "  Boş"
echo "Port 3001:"
sudo lsof -i:3001 | head -2 || echo "  Boş (devre dışı)"

echo ""
echo -e "${GREEN}✅ fikirtepetekelpaket.com devre dışı bırakıldı!${NC}"
echo ""
echo -e "${YELLOW}📋 Geri almak için:${NC}"
echo "   1. Nginx config'lerindeki yorum satırlarını kaldırın"
echo "   2. sudo nginx -t && sudo systemctl reload nginx"
echo "   3. pm2 start /var/www/fikirtepetekelpaket.com/ecosystem-aktas-market.config.cjs"

