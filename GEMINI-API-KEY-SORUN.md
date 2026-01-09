# 🔑 Gemini API Key Sorunu - Çözüm

## ❌ Sorun

Tüm Gemini modelleri 404 hatası veriyor. Bu, API key'in geçersiz olduğu veya modellere erişimi olmadığı anlamına gelir.

## ✅ Çözüm

### 1. Yeni API Key Oluştur

1. **Google AI Studio'ya gidin**: https://aistudio.google.com/
2. **Giriş yapın** (Google hesabınızla)
3. **"Get API Key"** butonuna tıklayın
4. **Yeni bir proje oluşturun** veya mevcut bir projeyi seçin
5. **API key'i kopyalayın**

### 2. API Key'i Sunucuya Ekleyin

```bash
cd ~/premiumfoto

# .env dosyasını düzenle
nano .env

# GEMINI_API_KEY satırını bulun ve yeni API key ile değiştirin
GEMINI_API_KEY="YENİ_API_KEY_BURAYA"

# Kaydedin: Ctrl+O, Enter, Ctrl+X
```

### 3. PM2'yi Restart Et

```bash
pm2 restart foto-ugur-app

# Logları kontrol et
pm2 logs foto-ugur-app --lines 30
```

## 🔍 API Key Kontrolü

### Sunucuda API Key'i Kontrol Et

```bash
cd ~/premiumfoto

# .env dosyasındaki API key'i kontrol et (sadece ilk 10 karakteri gösterir)
cat .env | grep GEMINI_API_KEY | cut -c1-30
```

### API Key Geçerliliğini Test Et

```bash
# Basit bir test (curl ile)
curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_API_KEY"
```

Eğer geçerli bir API key ise, model listesi döner.

## 📝 Notlar

1. **API Key Güvenliği**: API key'inizi asla GitHub'a commit etmeyin
2. **Rate Limits**: Ücretsiz API key'lerin rate limit'i olabilir
3. **Model Erişimi**: Bazı API key'ler sadece belirli modellere erişim sağlar
4. **Bölge Kısıtlamaları**: Bazı bölgelerde Gemini API kullanılamayabilir

## 🆘 Hala Çalışmıyorsa

1. **API Key'in aktif olduğundan emin olun**
2. **Google Cloud Console'da API'yi etkinleştirin** (gerekirse)
3. **Farklı bir Google hesabı ile deneyin**
4. **VPN kullanıyorsanız kapatın** (bazı bölgelerde kısıtlama olabilir)

