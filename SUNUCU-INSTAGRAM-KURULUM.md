# 📥 Instagram İçerik İndirme Kurulumu

## 🔧 Gereksinimler

1. Python 3 (✅ Kurulu: Python 3.12.3)
2. pip3 (Kurulması gerekiyor)
3. Instaloader (pip3 ile kurulacak)

## 📝 Kurulum Adımları

### 1. pip3 Kurulumu

```bash
sudo apt update
sudo apt install python3-pip -y
```

### 2. pip3 Kurulumunu Doğrula

```bash
pip3 --version
```

### 3. Instaloader Kurulumu

```bash
pip3 install instaloader
```

### 4. Instaloader Kurulumunu Doğrula

```bash
instaloader --version
```

## 🚀 Kullanım

### Admin Panelinden

1. `/admin/gallery/instagram-import` sayfasına gidin
2. Instagram kullanıcı adını girin (örn: `dugunkaremcom`)
3. "Tüm İçerikleri Otomatik Çek" butonuna tıklayın

### Komut Satırından (Alternatif)

```bash
cd ~/premiumfoto

# Instagram içeriklerini indir
instaloader --no-videos --no-captions --no-metadata-json --no-profile-pic dugunkaremcom

# İndirilen dosyalar public/uploads/instagram-dugunkaremcom/ klasörüne kaydedilir
# Sonra admin panelinden toplu yükleme özelliğini kullanabilirsiniz
```

## ⚠️ Notlar

- Instaloader, Instagram'ın ToS'una göre kullanılabilir
- Profil gizliyse, giriş yapmanız gerekebilir: `instaloader --login YOUR_USERNAME`
- Rate limit nedeniyle çok fazla içerik varsa zaman alabilir
- İndirilen dosyalar otomatik olarak `public/uploads` klasörüne kaydedilir

## 🔍 Sorun Giderme

### pip3 bulunamıyor
```bash
sudo apt update
sudo apt install python3-pip -y
```

### Instaloader bulunamıyor
```bash
pip3 install --user instaloader
# Veya
python3 -m pip install instaloader
```

### Permission denied hatası
```bash
# User install kullan
pip3 install --user instaloader

# Veya sudo ile (önerilmez)
sudo pip3 install instaloader
```

