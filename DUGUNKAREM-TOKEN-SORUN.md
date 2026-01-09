# 🔐 Dugunkarem Token Sorunu

## ❌ Sorun
Token'ın "repo" yetkisi yok veya token geçersiz.

## ✅ Çözüm Seçenekleri

### Seçenek 1: Yeni Token Oluştur (Repo Yetkisi ile)

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token (classic)"
3. **"repo"** yetkisini işaretleyin (tüm repo yetkileri)
4. Token'ı kopyalayın
5. Clone yapın:

```bash
cd /home/ibrahim
rm -rf dugunkarem
git clone https://YENI_TOKEN@github.com/ibraimknk/dugunkarem.git dugunkarem
```

### Seçenek 2: SSH Key Kullan (Önerilen)

```bash
# SSH key oluştur (eğer yoksa)
ssh-keygen -t ed25519 -C "your_email@example.com"
# Enter'a basın (şifre istemezse boş bırakın)

# Public key'i göster
cat ~/.ssh/id_ed25519.pub
```

GitHub'da:
1. Settings → SSH and GPG keys → New SSH key
2. Public key'i yapıştırın

Sonra:
```bash
cd /home/ibrahim
rm -rf dugunkarem
git clone git@github.com:ibraimknk/dugunkarem.git dugunkarem
```

### Seçenek 3: Repository'yi Public Yap

1. GitHub → Repository Settings → Danger Zone → Change visibility → Make public
2. Sonra normal clone:

```bash
cd /home/ibrahim
rm -rf dugunkarem
git clone https://github.com/ibraimknk/dugunkarem.git dugunkarem
```

## 🚀 Deploy

Clone başarılı olduktan sonra:

```bash
cd ~/premiumfoto
bash deploy-dugunkarem.sh
```

