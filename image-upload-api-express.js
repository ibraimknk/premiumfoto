// Standalone Express.js Image Upload API
// npm install express multer cors dotenv
// node image-upload-api-express.js

const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// İsteğe bağlı: API Key ile koruma
const API_KEY = process.env.UPLOAD_API_KEY || null;

// API Key kontrolü middleware
const checkApiKey = (req, res, next) => {
  if (API_KEY) {
    const apiKey = req.headers['x-api-key'];
    if (apiKey !== API_KEY) {
      return res.status(401).json({ error: 'Unauthorized - Geçersiz API Key' });
    }
  }
  next();
};

// Upload klasörünü oluştur
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Multer yapılandırması
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Dosya adını güvenli hale getir
    const timestamp = Date.now();
    const randomString = Math.random().toString(36).substring(2, 15);
    const originalName = file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_');
    const fileName = `${timestamp}-${randomString}-${originalName}`;
    cb(null, fileName);
  }
});

// Dosya filtresi (sadece resim)
const fileFilter = (req, file, cb) => {
  const allowedTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/svg+xml'
  ];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Sadece resim dosyaları yüklenebilir'), false);
  }
};

// Multer middleware (10MB limit)
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

// Upload endpoint
app.post('/api/upload', checkApiKey, upload.single('file'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Dosya bulunamadı' });
    }

    // URL'yi oluştur (domain'inizi buraya ekleyin)
    const baseUrl = process.env.BASE_URL || `http://localhost:${PORT}`;
    const url = `${baseUrl}/uploads/${req.file.filename}`;

    res.json({
      success: true,
      url: url,
      fileName: req.file.filename,
      size: req.file.size,
      type: req.file.mimetype,
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Dosya yükleme hatası',
    });
  }
});

// Yüklenen dosyaları servis et (opsiyonel)
app.use('/uploads', express.static(uploadDir));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Image Upload API çalışıyor' });
});

// Hata yakalama
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(413).json({
        error: 'Dosya çok büyük. Maksimum dosya boyutu: 10MB',
      });
    }
  }
  
  res.status(500).json({
    success: false,
    error: error.message || 'Sunucu hatası',
  });
});

// Sunucuyu başlat
app.listen(PORT, () => {
  console.log(`🚀 Image Upload API çalışıyor: http://localhost:${PORT}`);
  console.log(`📁 Upload klasörü: ${uploadDir}`);
  if (API_KEY) {
    console.log(`🔐 API Key koruması aktif`);
  }
});

