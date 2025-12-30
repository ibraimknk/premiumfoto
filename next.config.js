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
}

module.exports = nextConfig

