#!/bin/bash

# Git merge conflict çözümü

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Git merge conflict çözülüyor...${NC}"

# Yerel değişiklikleri stash et
echo -e "${YELLOW}📦 Yerel değişiklikler stash ediliyor...${NC}"
git stash || echo -e "${YELLOW}⚠️  Stash yapılamadı (değişiklik yok olabilir)${NC}"

# Pull yap
echo -e "${YELLOW}📥 Git pull yapılıyor...${NC}"
git pull origin main

echo -e "${GREEN}✅ Git merge conflict çözüldü${NC}"

