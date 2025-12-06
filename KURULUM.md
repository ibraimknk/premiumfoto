# Foto Uğur - Kurulum ve Kullanım Kılavuzu

## Kurulum

### 1. Bağımlılıkları Yükleyin

```bash
npm install
```

### 2. Ortam Değişkenlerini Ayarlayın

`.env` dosyasını oluşturun ve aşağıdaki değişkenleri ekleyin:

```env
DATABASE_URL="file:./prisma/dev.db"
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here-change-in-production
ADMIN_EMAIL=admin@fotougur.com
ADMIN_PASSWORD=admin123
```

**Önemli:** Production ortamında `NEXTAUTH_SECRET` için güçlü bir değer kullanın!

### 3. Veritabanını Oluşturun

```bash
npm run db:push
```

### 4. Seed Verilerini Yükleyin

```bash
npm run db:seed
```

Bu komut şunları oluşturur:
- Admin kullanıcı (email: admin@fotougur.com, şifre: admin123)
- Site ayarları
- 6 örnek hizmet
- 4 müşteri yorumu
- 6 SSS maddesi
- Hakkımızda sayfası
- 5 blog yazısı

### 5. Geliştirme Sunucusunu Başlatın

```bash
npm run dev
```

Tarayıcınızda [http://localhost:3000](http://localhost:3000) adresine gidin.

## Admin Paneli

Admin paneline erişmek için:

1. [http://localhost:3000/admin/login](http://localhost:3000/admin/login) adresine gidin
2. Varsayılan giriş bilgileri:
   - **Email:** admin@fotougur.com
   - **Şifre:** admin123

**Güvenlik:** İlk girişten sonra admin şifresini değiştirmeniz önerilir.

## Özellikler

### ✅ Tamamlanan Özellikler

- ✅ Next.js 14 App Router
- ✅ TypeScript
- ✅ Tailwind CSS + shadcn/ui
- ✅ Prisma ORM (SQLite dev, PostgreSQL prod)
- ✅ NextAuth.js ile kimlik doğrulama
- ✅ Admin paneli
- ✅ SEO optimizasyonu (meta tags, structured data, sitemap)
- ✅ Responsive tasarım
- ✅ İletişim formu
- ✅ Blog sistemi
- ✅ Galeri/Portfolyo
- ✅ Hizmet yönetimi
- ✅ SSS yönetimi
- ✅ Müşteri yorumları

### 🔄 Gelecek Güncellemeler

- [ ] i18n çoklu dil desteği (TR/EN)
- [ ] Medya yükleme sistemi (S3 entegrasyonu)
- [ ] Rich text editor (Tiptap veya benzeri)
- [ ] Gelişmiş admin formları
- [ ] Email bildirimleri
- [ ] Analytics entegrasyonu

## Proje Yapısı

```
├── app/
│   ├── (public)/          # Public sayfalar
│   │   ├── page.tsx       # Ana sayfa
│   │   ├── hakkimizda/    # Hakkımızda
│   │   ├── hizmetler/     # Hizmetler listesi ve detay
│   │   ├── galeri/        # Galeri/Portfolyo
│   │   ├── blog/          # Blog listesi ve detay
│   │   ├── iletisim/      # İletişim sayfası
│   │   └── sss/           # Sıkça Sorulan Sorular
│   ├── (admin)/           # Admin paneli
│   │   └── admin/         # Admin sayfaları
│   └── api/              # API routes
├── components/
│   ├── ui/               # shadcn/ui bileşenleri
│   ├── layout/           # Header, Footer, AdminSidebar
│   └── features/        # Özellik bazlı bileşenler
├── lib/
│   ├── prisma.ts        # Prisma client
│   ├── auth.ts          # NextAuth yapılandırması
│   ├── seo.ts           # SEO yardımcı fonksiyonları
│   └── utils.ts         # Genel yardımcı fonksiyonlar
└── prisma/
    ├── schema.prisma    # Veritabanı şeması
    └── seed.ts          # Seed verileri
```

## Production Deployment

### Veritabanı

Production ortamında PostgreSQL kullanmanız önerilir:

1. `.env` dosyasında `DATABASE_URL` değişkenini PostgreSQL connection string ile güncelleyin:
   ```env
   DATABASE_URL="postgresql://user:password@host:port/database"
   ```

2. Veritabanını migrate edin:
   ```bash
   npx prisma migrate deploy
   ```

3. Seed verilerini yükleyin:
   ```bash
   npm run db:seed
   ```

### Ortam Değişkenleri

Production ortamında aşağıdaki değişkenleri ayarlayın:

- `DATABASE_URL` - PostgreSQL connection string
- `NEXTAUTH_URL` - Production URL (örn: https://fotougur.com)
- `NEXTAUTH_SECRET` - Güçlü bir secret key
- `NEXT_PUBLIC_SITE_URL` - Site URL (SEO için)

### Build

```bash
npm run build
npm start
```

## Sorun Giderme

### Veritabanı Hataları

Eğer veritabanı ile ilgili hatalar alıyorsanız:

```bash
# Veritabanını sıfırlayın
rm prisma/dev.db
npm run db:push
npm run db:seed
```

### NextAuth Hataları

`NEXTAUTH_SECRET` değişkeninin ayarlandığından emin olun.

### Build Hataları

TypeScript hataları için:

```bash
npm run lint
```

## Destek

Sorularınız için issue açabilir veya iletişime geçebilirsiniz.

