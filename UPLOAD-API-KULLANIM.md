# 📸 Fotoğraf Upload API - fotougur.com.tr

## 🚀 Endpoint Bilgileri

**URL:** `https://fotougur.com.tr/api/upload`  
**Method:** `POST`  
**Content-Type:** `multipart/form-data`

## 📋 Özellikler

- ✅ Sadece resim dosyaları (JPEG, PNG, GIF, WebP, SVG)
- ✅ Maksimum dosya boyutu: 20MB
- ✅ Güvenli dosya adlandırma (timestamp + random string)
- ✅ API Key koruması (opsiyonel)
- ✅ Otomatik URL oluşturma
- ✅ Yüklenen fotoğraflar otomatik görüntülenebilir

## 🔧 Kurulum

### 1. Ortam Değişkenleri (.env)

```env
# Base URL (production'da otomatik olarak fotougur.com.tr kullanılır)
NEXT_PUBLIC_BASE_URL=https://fotougur.com.tr

# İsteğe bağlı: API Key koruması
UPLOAD_API_KEY=your-secret-api-key-here
```

### 2. Uploads Klasörü

Uploads klasörü otomatik olarak oluşturulur, ancak manuel oluşturmak isterseniz:

```bash
mkdir -p public/uploads
chmod 755 public/uploads
```

### 3. Nginx Yapılandırması

Nginx zaten `/uploads` klasörünü servis ediyor. Eğer sorun varsa kontrol edin:

```bash
sudo cat /etc/nginx/sites-available/foto-ugur | grep -A 5 "location /uploads"
```

Şöyle olmalı:
```nginx
location /uploads/ {
    alias /home/ibrahim/premiumfoto/public/uploads/;
    expires 30d;
    add_header Cache-Control "public, immutable";
    try_files $uri =404;
}
```

## 📝 Kullanım Örnekleri

### JavaScript/Fetch

```javascript
async function uploadImage(file) {
  const formData = new FormData();
  formData.append('file', file);

  const headers = {};
  // API Key varsa ekleyin
  if (process.env.UPLOAD_API_KEY) {
    headers['x-api-key'] = process.env.UPLOAD_API_KEY;
  }

  const response = await fetch('https://fotougur.com.tr/api/upload', {
    method: 'POST',
    headers: headers,
    body: formData
  });

  const data = await response.json();
  
  if (data.success) {
    console.log('Yüklenen fotoğraf URL:', data.url);
    return data.url;
  } else {
    console.error('Hata:', data.error);
    throw new Error(data.error);
  }
}

// Kullanım
const fileInput = document.querySelector('input[type="file"]');
fileInput.addEventListener('change', async (e) => {
  const file = e.target.files[0];
  if (file) {
    try {
      const url = await uploadImage(file);
      console.log('Fotoğraf yüklendi:', url);
    } catch (error) {
      console.error('Yükleme hatası:', error);
    }
  }
});
```

### cURL

```bash
# API Key olmadan
curl -X POST https://fotougur.com.tr/api/upload \
  -F "file=@/path/to/image.jpg"

# API Key ile
curl -X POST https://fotougur.com.tr/api/upload \
  -H "x-api-key: your-secret-api-key-here" \
  -F "file=@/path/to/image.jpg"
```

### Axios

```javascript
import axios from 'axios';

async function uploadImage(file) {
  const formData = new FormData();
  formData.append('file', file);

  const config = {
    headers: {
      'Content-Type': 'multipart/form-data',
      // API Key varsa
      // 'x-api-key': 'your-secret-api-key-here'
    }
  };

  try {
    const response = await axios.post(
      'https://fotougur.com.tr/api/upload',
      formData,
      config
    );

    if (response.data.success) {
      return response.data.url;
    }
  } catch (error) {
    console.error('Upload error:', error.response?.data || error.message);
    throw error;
  }
}
```

### React Örneği

```tsx
import { useState } from 'react';

function ImageUpload() {
  const [uploading, setUploading] = useState(false);
  const [imageUrl, setImageUrl] = useState('');

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData,
      });

      const data = await response.json();
      
      if (data.success) {
        setImageUrl(data.url);
        console.log('Fotoğraf yüklendi:', data.url);
      } else {
        alert('Hata: ' + data.error);
      }
    } catch (error) {
      console.error('Upload error:', error);
      alert('Yükleme hatası');
    } finally {
      setUploading(false);
    }
  };

  return (
    <div>
      <input
        type="file"
        accept="image/*"
        onChange={handleUpload}
        disabled={uploading}
      />
      {uploading && <p>Yükleniyor...</p>}
      {imageUrl && (
        <div>
          <p>Yüklenen fotoğraf:</p>
          <img src={imageUrl} alt="Uploaded" style={{ maxWidth: '300px' }} />
          <p>{imageUrl}</p>
        </div>
      )}
    </div>
  );
}
```

## 📤 API Response

### Başarılı Response

```json
{
  "success": true,
  "url": "https://fotougur.com.tr/uploads/1704643200000-abc123def456.jpg",
  "fileName": "1704643200000-abc123def456.jpg",
  "size": 1024000,
  "type": "image/jpeg",
  "message": "Fotoğraf başarıyla yüklendi"
}
```

### Hata Response

```json
{
  "success": false,
  "error": "Hata mesajı"
}
```

## 🔒 Güvenlik

### API Key Koruması

Eğer `.env` dosyasında `UPLOAD_API_KEY` tanımlarsanız, tüm isteklerde bu key'i göndermeniz gerekir:

```javascript
headers: {
  'x-api-key': 'your-secret-api-key-here'
}
```

### Dosya Tipi Kontrolü

Sadece şu dosya tipleri kabul edilir:
- `image/jpeg`
- `image/jpg`
- `image/png`
- `image/gif`
- `image/webp`
- `image/svg+xml`

### Dosya Boyutu Limiti

Maksimum dosya boyutu: **20MB**

## 🧪 Test Etme

### 1. HTML Test Sayfası

`upload-test.html` dosyasını tarayıcıda açarak test edebilirsiniz:

```bash
# Development'ta
open upload-test.html

# Veya Next.js ile
# public/ klasörüne kopyalayın ve https://fotougur.com.tr/upload-test.html adresinden erişin
```

### 2. API Bilgilerini Görüntüleme

```bash
curl https://fotougur.com.tr/api/upload
```

Bu endpoint API hakkında bilgi döndürür.

## 📁 Dosya Yapısı

```
app/
  api/
    upload/
      route.ts          # Upload endpoint
public/
  uploads/             # Yüklenen fotoğraflar (otomatik oluşturulur)
    [timestamp]-[random]-[filename].jpg
```

## 🌐 Fotoğraf Görüntüleme

Yüklenen fotoğraflar otomatik olarak şu URL'den erişilebilir:

```
https://fotougur.com.tr/uploads/[filename]
```

Örnek:
```
https://fotougur.com.tr/uploads/1704643200000-abc123def456.jpg
```

Bu URL'yi doğrudan tarayıcıda açabilir, `<img>` tag'inde kullanabilir veya başka yerlerde paylaşabilirsiniz.

## ⚙️ Özelleştirme

### Dosya Boyutu Limiti Değiştirme

`app/api/upload/route.ts` dosyasında:

```typescript
const maxFileSize = 30 * 1024 * 1024 // 30MB
```

### İzin Verilen Dosya Tipleri

```typescript
const allowedTypes = [
  "image/jpeg",
  "image/png",
  // Yeni tipler ekleyin
]
```

### Domain Değiştirme

`.env` dosyasında:

```env
NEXT_PUBLIC_BASE_URL=https://yeni-domain.com
```

## ❓ Sorun Giderme

### "Dosya bulunamadı" Hatası
- FormData'da `file` key'ini kullandığınızdan emin olun
- Dosya seçildiğinden emin olun

### "Dosya çok büyük" Hatası
- Dosya boyutu 20MB'dan küçük olmalı
- Dosyayı sıkıştırın veya boyutunu küçültün

### "Sadece resim dosyaları" Hatası
- Dosya tipinin desteklenen formatta olduğundan emin olun

### "Unauthorized" Hatası
- API Key'i doğru gönderdiğinizden emin olun
- `.env` dosyasında `UPLOAD_API_KEY` tanımlı mı kontrol edin

### Fotoğraf Görüntülenmiyor
- Nginx config'ini kontrol edin
- Dosya izinlerini kontrol edin: `ls -la public/uploads`
- Nginx'i yeniden yükleyin: `sudo systemctl reload nginx`

## 📞 Destek

Sorun yaşarsanız:
1. Console loglarını kontrol edin
2. Nginx loglarını kontrol edin: `sudo tail -f /var/log/nginx/error.log`
3. Next.js loglarını kontrol edin

---

**Endpoint Hazır!** 🎉

Artık `https://fotougur.com.tr/api/upload` adresine POST isteği göndererek fotoğraf yükleyebilir ve dönen URL ile fotoğrafları görüntüleyebilirsiniz.

