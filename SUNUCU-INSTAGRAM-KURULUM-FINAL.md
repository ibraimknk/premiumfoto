# 📥 Instagram İçerik İndirme Kurulumu (Final)

## ❌ Sorun

Ubuntu'nun yeni versiyonlarında `externally-managed-environment` hatası alınıyor.
`--user` flag'i bile çalışmıyor.

## ✅ Çözüm 1: pipx ile Kurulum (Önerilen)

```bash
# pipx kur
sudo apt install pipx -y

# pipx'i PATH'e ekle
pipx ensurepath

# Yeni shell'de PATH'i yükle
source ~/.bashrc

# Instaloader'ı pipx ile kur
pipx install instaloader

# Kurulumu doğrula
instaloader --version
```

## ✅ Çözüm 2: --break-system-packages (Hızlı)

```bash
# Direkt kur (sistem paketlerini bozma riski var ama genelde sorun olmaz)
pip3 install --break-system-packages instaloader

# Kurulumu doğrula
instaloader --version
```

## ✅ Çözüm 3: Virtual Environment (Güvenli)

```bash
# Virtual environment oluştur
python3 -m venv ~/instagram-env

# Aktif et
source ~/instagram-env/bin/activate

# Instaloader kur
pip install instaloader

# Kurulumu doğrula
instaloader --version

# PATH'e ekle (kalıcı için)
echo 'export PATH="$HOME/instagram-env/bin:$PATH"' >> ~/.bashrc
```

## 🚀 Önerilen: pipx (En Güvenli)

```bash
sudo apt install pipx -y && \
pipx ensurepath && \
source ~/.bashrc && \
pipx install instaloader && \
instaloader --version
```

## 📝 API Route Güncellemesi

API route'u otomatik olarak şu yolları kontrol eder:
- `~/.local/bin/instaloader` (pipx ile kurulduysa)
- `instaloader` (sistem PATH'inde)
- `~/instagram-env/bin/instaloader` (virtual environment)

