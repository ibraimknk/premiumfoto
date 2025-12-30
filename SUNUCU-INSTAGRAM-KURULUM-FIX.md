# 📥 Instagram İçerik İndirme Kurulumu (Düzeltilmiş)

## ❌ Sorun

Ubuntu'nun yeni versiyonlarında `externally-managed-environment` hatası alınıyor.

## ✅ Çözüm 1: --user Flag'i ile Kurulum (Önerilen)

```bash
# pip3 zaten kurulu, direkt --user ile kur
pip3 install --user instaloader

# PATH'e ekle (eğer gerekirse)
export PATH="$HOME/.local/bin:$PATH"

# Kurulumu doğrula
~/.local/bin/instaloader --version
```

## ✅ Çözüm 2: pipx ile Kurulum (Alternatif)

```bash
# pipx kur
sudo apt install pipx -y

# pipx'i PATH'e ekle
pipx ensurepath

# Instaloader'ı pipx ile kur
pipx install instaloader

# Kurulumu doğrula
instaloader --version
```

## ✅ Çözüm 3: Virtual Environment (Alternatif)

```bash
# Virtual environment oluştur
python3 -m venv ~/instagram-env

# Aktif et
source ~/instagram-env/bin/activate

# Instaloader kur
pip install instaloader

# Kurulumu doğrula
instaloader --version
```

## 🚀 Önerilen: --user Flag'i

En basit ve güvenli yöntem:

```bash
pip3 install --user instaloader

# PATH kontrolü
echo $PATH | grep -q "$HOME/.local/bin" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Test
instaloader --version
```

## 📝 API Route Güncellemesi

API route'unda `instaloader` komutunu `~/.local/bin/instaloader` olarak güncellemek gerekebilir.

