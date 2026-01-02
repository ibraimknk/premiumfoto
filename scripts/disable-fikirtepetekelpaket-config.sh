#!/bin/bash

# fikirtepetekelpaket.com config'ini devre dışı bırak

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FIKIRTEPETEKELPAKET_CONFIG="/etc/nginx/sites-available/fikirtepetekelpaket.com"
FIKIRTEPETEKELPAKET_ENABLED="/etc/nginx/sites-enabled/fikirtepetekelpaket.com"

echo -e "${YELLOW}🔧 fikirtepetekelpaket.com config'i devre dışı bırakılıyor...${NC}"

# Config'i devre dışı bırak
if [ -L "$FIKIRTEPETEKELPAKET_ENABLED" ]; then
    echo -e "${YELLOW}🗑️  Config devre dışı bırakılıyor...${NC}"
    sudo rm -f "$FIKIRTEPETEKELPAKET_ENABLED"
    echo -e "${GREEN}✅ Config devre dışı bırakıldı${NC}"
else
    echo -e "${YELLOW}⚠️  Config zaten devre dışı${NC}"
fi

# Sertifika referanslarını yorum satırı yap (opsiyonel)
if [ -f "$FIKIRTEPETEKELPAKET_CONFIG" ]; then
    echo -e "${YELLOW}📝 Sertifika referansları yorum satırı yapılıyor...${NC}"
    
    sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/fikirtepetekelpaket.com"

try:
    with open(config_file, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # SSL sertifika satırlarını yorum satırı yap
    patterns = [
        (r'(\s+)(ssl_certificate\s+/etc/letsencrypt/live/fikirtepetekelpaket\.com/[^;]+;)', r'\1# \2 # disabled - certificate not accessible'),
        (r'(\s+)(ssl_certificate_key\s+/etc/letsencrypt/live/fikirtepetekelpaket\.com/[^;]+;)', r'\1# \2 # disabled - certificate not accessible'),
    ]
    
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    # Eğer değişiklik yapıldıysa kaydet
    if content != original_content:
        with open(config_file, 'w') as f:
            f.write(content)
        print("✅ Sertifika referansları yorum satırı yapıldı")
    else:
        print("ℹ️  Değişiklik yapılmadı")
        
except Exception as e:
    print(f"❌ Hata: {e}")
PYEOF
fi

# Nginx test
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ fikirtepetekelpaket.com config'i devre dışı bırakıldı!${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol:${NC}"
echo "   ls -la /etc/nginx/sites-enabled/ | grep fikirtepetekelpaket"
echo "   nginx -t"

