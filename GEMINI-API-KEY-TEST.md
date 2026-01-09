# 🔍 Gemini API Key Test

## API Key'i Test Et

Sunucuda şu komutu çalıştırın:

```bash
# API key'inizi test edin (YOUR_API_KEY yerine gerçek API key'inizi yazın)
curl "https://generativelanguage.googleapis.com/v1beta/models?key=AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"
```

### Beklenen Sonuç

Eğer API key geçerliyse, model listesi döner:
```json
{
  "models": [
    {
      "name": "models/gemini-pro",
      ...
    }
  ]
}
```

Eğer API key geçersizse, hata mesajı döner:
```json
{
  "error": {
    "code": 400,
    "message": "API key not valid..."
  }
}
```

## 🔧 Çözüm

### 1. Yeni API Key Oluştur

1. **Google AI Studio**: https://aistudio.google.com/
2. **Get API Key** butonuna tıklayın
3. **Yeni proje oluşturun** veya mevcut projeyi seçin
4. **API key'i kopyalayın**

### 2. API Key'i Güncelle

```bash
cd ~/premiumfoto

# .env dosyasını düzenle
nano .env

# GEMINI_API_KEY satırını yeni API key ile değiştirin
GEMINI_API_KEY="YENİ_API_KEY_BURAYA"

# PM2'yi restart et (--update-env ile environment variable'ları güncelle)
pm2 restart foto-ugur-app --update-env
```

### 3. Logları Kontrol Et

```bash
pm2 logs foto-ugur-app --lines 30
```

## ⚠️ Önemli Notlar

1. **PM2 Environment Variables**: PM2 restart edildiğinde environment variable'ları güncellemek için `--update-env` flag'i kullanın
2. **API Key Format**: API key tırnak işaretleri olmadan da çalışabilir
3. **Bölge Kısıtlaması**: Bazı bölgelerde Gemini API kullanılamayabilir

