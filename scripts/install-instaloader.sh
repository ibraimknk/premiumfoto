#!/bin/bash

# Instaloader kurulum scripti
# Kullanım: bash scripts/install-instaloader.sh

echo "📦 Instaloader kuruluyor..."
echo ""

# Python kontrolü
echo "1️⃣ Python kontrol ediliyor..."
if ! command -v python3 &> /dev/null; then
    echo "   ❌ Python3 bulunamadı! Kuruluyor..."
    sudo apt update
    sudo apt install -y python3 python3-pip
else
    PYTHON_VERSION=$(python3 --version)
    echo "   ✅ $PYTHON_VERSION bulundu"
fi

# pip kontrolü
echo ""
echo "2️⃣ pip kontrol ediliyor..."
if ! command -v pip3 &> /dev/null; then
    echo "   ❌ pip3 bulunamadı! Kuruluyor..."
    sudo apt install -y python3-pip
else
    PIP_VERSION=$(pip3 --version)
    echo "   ✅ $PIP_VERSION bulundu"
fi

# pipx kurulumu (önerilen yöntem)
echo ""
echo "3️⃣ pipx kurulumu kontrol ediliyor..."
if ! command -v pipx &> /dev/null; then
    echo "   📦 pipx kuruluyor..."
    sudo apt update
    sudo apt install -y pipx
    pipx ensurepath
    echo "   ✅ pipx kuruldu"
    
    # PATH'e ekle
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
else
    echo "   ✅ pipx zaten kurulu"
fi

# Instaloader kurulumu
echo ""
echo "4️⃣ Instaloader kurulumu..."

# Önce mevcut kurulumu kontrol et
if command -v instaloader &> /dev/null; then
    INSTALOADER_VERSION=$(instaloader --version 2>&1 | head -1)
    echo "   ✅ Instaloader zaten kurulu: $INSTALOADER_VERSION"
else
    echo "   📦 Instaloader kuruluyor..."
    
    # pipx ile kur (önerilen)
    if command -v pipx &> /dev/null; then
        pipx install instaloader
        echo "   ✅ Instaloader pipx ile kuruldu"
    else
        # pip3 ile kur (alternatif)
        echo "   📦 pip3 ile kuruluyor..."
        pip3 install --user instaloader
        
        # PATH'e ekle
        export PATH="$HOME/.local/bin:$PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        source ~/.bashrc
        echo "   ✅ Instaloader pip3 ile kuruldu"
    fi
fi

# PATH kontrolü
echo ""
echo "5️⃣ PATH kontrolü..."
export PATH="$HOME/.local/bin:$PATH"
if command -v instaloader &> /dev/null; then
    INSTALOADER_PATH=$(which instaloader)
    INSTALOADER_VERSION=$(instaloader --version 2>&1 | head -1)
    echo "   ✅ Instaloader bulundu: $INSTALOADER_PATH"
    echo "   📋 Versiyon: $INSTALOADER_VERSION"
else
    echo "   ⚠️ Instaloader PATH'te bulunamadı"
    echo "   💡 Manuel PATH ekleme:"
    echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "      echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
fi

# Test
echo ""
echo "6️⃣ Instaloader test ediliyor..."
if instaloader --version &> /dev/null; then
    echo "   ✅ Instaloader çalışıyor!"
else
    echo "   ❌ Instaloader test başarısız"
    echo "   💡 PATH'i kontrol edin:"
    echo "      echo \$PATH"
    echo "      which instaloader"
fi

echo ""
echo "✅ Kurulum tamamlandı!"
echo ""
echo "💡 Kullanım:"
echo "   instaloader --version"
echo "   instaloader USERNAME"

