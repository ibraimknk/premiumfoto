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
  // API route body size limit (Next.js App Router için)
  api: {
    bodyParser: {
      sizeLimit: '50mb',
    },
    responseLimit: '50mb',
  },
}

module.exports = nextConfig

