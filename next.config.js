/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
      {
        protocol: 'http',
        hostname: 'localhost',
        port: '3000',
      },
    ],
    unoptimized: false,
    // Local uploads klasörü için özel loader
    loader: 'default',
    loaderFile: undefined,
  },
  experimental: {
    serverActions: {
      bodySizeLimit: '50mb',
    },
  },
  // API routes için body size limit (App Router)
  // Not: Bu Next.js 14'te geçersiz, serverActions kullanılıyor
  
  // trendyol-manager klasörünü build'den hariç tut
  // Next.js otomatik olarak app/ klasörünü tarar, trendyol-manager'ı exclude etmek için
  // webpack config kullanıyoruz
  webpack: (config, { isServer }) => {
    // trendyol-manager klasöründeki dosyaları build'den hariç tut
    // Bu klasördeki dosyalar TypeScript type checking'den geçmeyecek
    config.module.rules.push({
      test: /trendyol-manager.*\.(tsx?|jsx?)$/,
      use: {
        loader: 'ignore-loader',
      },
    })
    
    return config
  },
}

export default nextConfig

