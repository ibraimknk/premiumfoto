# Foto Uğur - Premium Fotoğraf Stüdyosu Web Sitesi

Modern, premium görünümlü, yüksek performanslı fotoğraf stüdyosu web sitesi ve admin paneli.

## Teknolojiler

- **Framework**: Next.js 14 (App Router)
- **Dil**: TypeScript
- **Stil**: Tailwind CSS
- **UI Kit**: shadcn/ui
- **ORM**: Prisma
- **Veritabanı**: SQLite (dev) / PostgreSQL (prod)
- **Auth**: NextAuth.js
- **i18n**: next-intl

## Kurulum

1. Bağımlılıkları yükleyin:
```bash
npm install
```

2. Ortam değişkenlerini ayarlayın:
```bash
cp .env.example .env
```

3. Veritabanını oluşturun:
```bash
npm run db:push
```

4. Seed verilerini yükleyin:
```bash
npm run db:seed
```

5. Geliştirme sunucusunu başlatın:
```bash
npm run dev
```

## Admin Panel

Admin paneline `/admin` adresinden erişebilirsiniz.

Varsayılan giriş bilgileri `.env` dosyasındaki `ADMIN_EMAIL` ve `ADMIN_PASSWORD` değerleridir.

## Proje Yapısı

```
├── app/
│   ├── (public)/          # Public sayfalar
│   ├── (admin)/           # Admin paneli
│   ├── api/               # API routes
│   └── layout.tsx
├── components/
│   ├── ui/                # shadcn/ui bileşenleri
│   ├── layout/            # Header, Footer, vb.
│   └── features/          # Özellik bazlı bileşenler
├── lib/
│   ├── prisma.ts          # Prisma client
│   ├── auth.ts            # Auth yapılandırması
│   └── utils.ts           # Yardımcı fonksiyonlar
├── prisma/
│   ├── schema.prisma      # Veritabanı şeması
│   └── seed.ts            # Seed verileri
└── public/
    └── uploads/           # Yüklenen medya dosyaları
```

## Özellikler

- ✅ Tam yönetilebilir içerik (admin panel)
- ✅ SEO optimizasyonu
- ✅ Yapılandırılmış veri (Schema.org)
- ✅ Responsive tasarım
- ✅ Fotoğraf ve video portfolyo
- ✅ Blog sistemi
- ✅ İletişim formu
- ✅ Çoklu dil desteği (TR/EN)

