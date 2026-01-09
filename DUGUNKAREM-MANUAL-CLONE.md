# 🔧 Dugunkarem Manuel Clone ve Deploy

## ❌ Sorun
Script git clone aşamasında takılıyor.

## ✅ Çözüm: Manuel Clone

### 1. Manuel Clone Yapın

```bash
cd /home/ibrahim

# Eğer dizin varsa sil
rm -rf dugunkarem

# Manuel clone
git clone https://github.com/ibraimknk/dugunkarem.git dugunkarem

# Clone başarılı mı kontrol et
ls -la dugunkarem
```

### 2. Deploy Script'ini Çalıştırın

Proje zaten klonlandığı için script sadece kurulum yapacak:

```bash
cd ~/premiumfoto
bash deploy-dugunkarem.sh
```

## 🔍 Clone Başarısız Olursa

### Repository Public mi Kontrol Edin

```bash
# Repository'yi tarayıcıda açın
# https://github.com/ibraimknk/dugunkarem
# Settings → Danger Zone → Change visibility → Make public
```

### Alternatif: SSH ile Clone

```bash
# SSH key oluştur (eğer yoksa)
ssh-keygen -t ed25519 -C "your_email@example.com"
# Enter'a basın (şifre istemezse boş bırakın)

# Public key'i göster
cat ~/.ssh/id_ed25519.pub

# GitHub → Settings → SSH and GPG keys → New SSH key
# Public key'i ekleyin

# SSH ile clone
cd /home/ibrahim
git clone git@github.com:ibraimknk/dugunkarem.git dugunkarem
```

## ✅ Doğrulama

```bash
# Proje dizini var mı?
ls -la /home/ibrahim/dugunkarem

# Git durumu
cd /home/ibrahim/dugunkarem
git status

# Deploy script'ini çalıştır
cd ~/premiumfoto
bash deploy-dugunkarem.sh
```

