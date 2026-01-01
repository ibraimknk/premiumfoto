#!/bin/bash

# Git conflict çözüm scripti
# Kullanım: bash scripts/fix-git-conflict.sh

echo "🔧 Git conflict çözülüyor..."
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# Yerel değişiklikleri stash et
echo "1️⃣ Yerel değişiklikler stash ediliyor..."
git stash

# Güncellemeleri çek
echo ""
echo "2️⃣ Güncellemeler çekiliyor..."
git pull origin main

# Stash'ten değişiklikleri geri al (eğer varsa)
echo ""
echo "3️⃣ Stash kontrol ediliyor..."
if git stash list | grep -q "stash@{0}"; then
    echo "   ⚠️ Stash'te değişiklikler var, manuel kontrol gerekebilir"
    echo "   💡 Stash'i görmek için: git stash show"
    echo "   💡 Stash'i uygulamak için: git stash pop"
else
    echo "   ✅ Stash boş"
fi

echo ""
echo "✅ Git conflict çözüldü!"

