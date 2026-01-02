#!/bin/bash

# Git conflict'i çöz (script çalışmadan önce)

set -e

echo "🔧 Git conflict çözülüyor..."

cd ~/premiumfoto

# Agresif çözüm
git stash
git reset --hard origin/main
git pull origin main

echo "✅ Git conflict çözüldü!"
echo ""
echo "Şimdi şu komutu çalıştırın:"
echo "   sudo bash scripts/fix-dugunkarem-final-working.sh"

