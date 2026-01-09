# Image Upload API Kullanım Kılavuzu

## 📋 İki Versiyon Mevcut

### 1. Next.js API Route
- Dosya: `image-upload-api-nextjs.ts`
- Next.js projeleri için
- `app/api/upload/route.ts` olarak kullanın

### 2. Standalone Express.js API
- Dosya: `image-upload-api-express.js`
- Bağımsız Node.js projeleri için
- Kendi başına çalışır

---

## 🚀 Next.js Versiyonu Kurulumu

### 1. Dosyayı Kopyalayın
```bash
# image-upload-api-nextjs.ts dosyasını şuraya kopyalayın:
app/api/upload/route.ts
```

### 2. Ortam Değişkenleri (.env)
```env
# İsteğe bağlı: API Key koruması için
UPLOAD_API_KEY=your-secret-api-key-here

# Base URL (production'da domain'inizi yazın)
NEXT_PUBLIC_BASE_URL=https://yourdomain.com
```

### 3. Uploads Klasörünü Oluşturun
```bash
mkdir -p public/uploads
```

### 4. Kullanım Örneği (Frontend)
```typescript
async function uploadImage(file: File) {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch('/api/upload', {
    method: 'POST',
    headers: {
      // İsteğe bağlı: API Key varsa
      'x-api-key': 'your-secret-api-key-here'
    },
    body: formData,
  });

  const data = await response.json();
  
  if (data.success) {
    console.log('Yüklenen resim URL:', data.url);
    return data.url;
  } else {
    console.error('Hata:', data.error);
  }
}
```

---

## 🚀 Express.js Versiyonu Kurulumu

### 1. Bağımlılıkları Yükleyin
```bash
npm init -y
npm install express multer cors dotenv
```

### 2. Dosyayı Kopyalayın
```bash
# image-upload-api-express.js dosyasını projenize kopyalayın
```

### 3. Ortam Değişkenleri (.env)
```env
PORT=3001
UPLOAD_API_KEY=your-secret-api-key-here
BASE_URL=http://localhost:3001
```

### 4. Sunucuyu Başlatın
```bash
node image-upload-api-express.js
```

### 5. Kullanım Örneği (Frontend)
```javascript
async function uploadImage(file) {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch('http://localhost:3001/api/upload', {
    method: 'POST',
    headers: {
      // İsteğe bağlı: API Key varsa
      'x-api-key': 'your-secret-api-key-here'
    },
    body: formData,
  });

  const data = await response.json();
  
  if (data.success) {
    console.log('Yüklenen resim URL:', data.url);
    return data.url;
  } else {
    console.error('Hata:', data.error);
  }
}
```

---

## 📝 API Endpoint Detayları

### POST /api/upload

**Request:**
- Method: `POST`
- Content-Type: `multipart/form-data`
- Body: `file` (FormData)
- Headers (opsiyonel): `x-api-key`

**Response (Başarılı):**
```json
{
  "success": true,
  "url": "https://yourdomain.com/uploads/1234567890-abc123-image.jpg",
  "fileName": "1234567890-abc123-image.jpg",
  "size": 1024000,
  "type": "image/jpeg"
}
```

**Response (Hata):**
```json
{
  "success": false,
  "error": "Hata mesajı"
}
```

---

## 🔒 Güvenlik Özellikleri

1. **API Key Koruması** (İsteğe bağlı)
   - `.env` dosyasında `UPLOAD_API_KEY` tanımlayın
   - İsteklerde `x-api-key` header'ı gönderin

2. **Dosya Tipi Kontrolü**
   - Sadece resim dosyaları kabul edilir
   - İzin verilen tipler: jpeg, jpg, png, gif, webp, svg

3. **Dosya Boyutu Limiti**
   - Varsayılan: 10MB
   - Kod içinde değiştirilebilir

4. **Güvenli Dosya Adlandırma**
   - Timestamp + random string + orijinal ad
   - Özel karakterler temizlenir

---

## ⚙️ Özelleştirme

### Dosya Boyutu Limiti Değiştirme

**Next.js:**
```typescript
const maxFileSize = 20 * 1024 * 1024 // 20MB
```

**Express.js:**
```javascript
limits: {
  fileSize: 20 * 1024 * 1024 // 20MB
}
```

### İzin Verilen Dosya Tipleri Değiştirme

```typescript
// Next.js
const allowedTypes = [
  "image/jpeg",
  "image/png",
  // Yeni tipler ekleyin
]

// Express.js
const allowedTypes = [
  'image/jpeg',
  'image/png',
  // Yeni tipler ekleyin
]
```

### Upload Klasörü Değiştirme

**Next.js:**
```typescript
const uploadDir = join(process.cwd(), "public", "images") // images klasörü
```

**Express.js:**
```javascript
const uploadDir = path.join(__dirname, 'images') // images klasörü
```

---

## 🧪 Test Etme

### cURL ile Test
```bash
curl -X POST http://localhost:3001/api/upload \
  -H "x-api-key: your-secret-api-key-here" \
  -F "file=@/path/to/your/image.jpg"
```

### Postman ile Test
1. Method: POST
2. URL: `http://localhost:3001/api/upload`
3. Headers: `x-api-key: your-secret-api-key-here`
4. Body: form-data
5. Key: `file` (type: File)
6. Value: Bir resim dosyası seçin

---

## 📦 Production Deployment

### Next.js
- Vercel, Netlify gibi platformlarda otomatik çalışır
- `.env` dosyasını production ortamında ayarlayın

### Express.js
- PM2 ile çalıştırın:
```bash
npm install -g pm2
pm2 start image-upload-api-express.js --name image-upload-api
pm2 save
pm2 startup
```

### Nginx Reverse Proxy (Express.js için)
```nginx
location /api/upload {
    proxy_pass http://localhost:3001;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

---

## ❓ Sorun Giderme

### "Dosya bulunamadı" Hatası
- FormData'da `file` key'ini kullandığınızdan emin olun
- Dosya seçildiğinden emin olun

### "Dosya çok büyük" Hatası
- Dosya boyutu limitini artırın veya dosyayı küçültün

### "Sadece resim dosyaları" Hatası
- Dosya tipinin desteklenen formatta olduğundan emin olun

### "Unauthorized" Hatası
- API Key'i doğru gönderdiğinizden emin olun
- `.env` dosyasında `UPLOAD_API_KEY` tanımlı mı kontrol edin

---

## 📄 Lisans

Bu kod örnek amaçlıdır, istediğiniz gibi kullanabilirsiniz.

