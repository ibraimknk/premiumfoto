#!/bin/bash

# fikirtepetekelpaket.com sertifika referanslarını Nginx config'lerinden kaldır

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 fikirtepetekelpaket.com sertifika referansları kaldırılıyor...${NC}"

# Python3 ile tüm Nginx config dosyalarını düzenle
python3 << 'PYEOF'
import os
import re
import glob

# Nginx config dizinleri
config_dirs = [
    "/etc/nginx/sites-available",
    "/etc/nginx/sites-enabled"
]

# fikirtepetekelpaket.com sertifika referanslarını bul ve kaldır
def fix_config_file(filepath):
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        
        original_content = content
        
        # fikirtepetekelpaket.com sertifika referanslarını bul
        # SSL certificate satırlarını kaldır veya yorum satırı yap
        patterns = [
            (r'ssl_certificate\s+/etc/letsencrypt/live/fikirtepetekelpaket\.com/[^;]+;', '# ssl_certificate removed (permission denied)'),
            (r'ssl_certificate_key\s+/etc/letsencrypt/live/fikirtepetekelpaket\.com/[^;]+;', '# ssl_certificate_key removed (permission denied)'),
        ]
        
        for pattern, replacement in patterns:
            content = re.sub(pattern, replacement, content)
        
        # Eğer değişiklik yapıldıysa kaydet
        if content != original_content:
            with open(filepath, 'w') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"❌ {filepath} işlenirken hata: {e}")
        return False

# Tüm config dosyalarını işle
fixed_files = []
for config_dir in config_dirs:
    if os.path.exists(config_dir):
        for config_file in glob.glob(os.path.join(config_dir, "*")):
            if os.path.isfile(config_file) and not os.path.islink(config_file):
                if "fikirtepetekelpaket.com" in open(config_file, 'r').read():
                    if fix_config_file(config_file):
                        fixed_files.append(config_file)

if fixed_files:
    print(f"✅ {len(fixed_files)} dosya güncellendi:")
    for f in fixed_files:
        print(f"   - {f}")
else:
    print("ℹ️  Güncellenecek dosya bulunamadı")

PYEOF

echo -e "${GREEN}✅ İşlem tamamlandı${NC}"
echo ""
echo -e "${YELLOW}🔄 Nginx test:${NC}"
echo "   nginx -t"
echo ""
echo -e "${YELLOW}💡 Eğer hala hata varsa, fikirtepetekelpaket.com config dosyasını kontrol edin:${NC}"
echo "   cat /etc/nginx/sites-available/fikirtepetekelpaket.com"

