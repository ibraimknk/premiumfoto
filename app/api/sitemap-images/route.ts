import { NextResponse } from "next/server"
import { prisma } from "@/lib/prisma"
import { getPrimaryDomain } from "@/lib/sitemap-utils"

export const dynamic = 'force-dynamic'

// Image Sitemap - Tüm görselleri içerir
// URL: /api/sitemap-images
export async function GET() {
  const baseUrl = getPrimaryDomain()
  
  // Blog post images
  const blogPosts = await prisma.blogPost.findMany({
    where: {
      isPublished: true,
      publishedAt: { not: null },
      coverImage: { not: null },
    },
    select: {
      slug: true,
      coverImage: true,
      title: true,
      updatedAt: true,
    },
  })

  // Service images
  const services = await prisma.service.findMany({
    where: {
      isActive: true,
      OR: [
        { featuredImage: { not: null } },
        { images: { not: null } },
      ],
    },
    select: {
      slug: true,
      featuredImage: true,
      images: true,
      title: true,
      updatedAt: true,
    },
  })

  // Gallery images - using GalleryItem model
  const galleryItems = await prisma.galleryItem.findMany({
    where: {
      isActive: true,
      imageUrl: { not: null },
    },
    select: {
      id: true,
      imageUrl: true,
      title: true,
      updatedAt: true,
    },
  }).catch(() => []) // If model doesn't exist, return empty array

  // Image entries oluştur
  const imageEntries: string[] = []

  // Blog images
  blogPosts.forEach((post) => {
    if (post.coverImage) {
      const imageUrl = post.coverImage.startsWith('http') 
        ? post.coverImage 
        : `${baseUrl}${post.coverImage.startsWith('/') ? '' : '/'}${post.coverImage}`
      
      imageEntries.push(`  <url>
    <loc>${baseUrl}/blog/${post.slug}</loc>
    <lastmod>${post.updatedAt.toISOString()}</lastmod>
    <image:image>
      <image:loc>${imageUrl}</image:loc>
      <image:title>${escapeXml(post.title)} - Ataşehir fotoğrafçı Foto Uğur</image:title>
      <image:caption>${escapeXml(post.title)} - Foto Uğur blog yazısı</image:caption>
    </image:image>
  </url>`)
    }
  })

  // Service images
  services.forEach((service) => {
    // Featured image
    if (service.featuredImage) {
      const imageUrl = service.featuredImage.startsWith('http')
        ? service.featuredImage
        : `${baseUrl}${service.featuredImage.startsWith('/') ? '' : '/'}${service.featuredImage}`
      
      imageEntries.push(`  <url>
    <loc>${baseUrl}/hizmetler/${service.slug}</loc>
    <lastmod>${service.updatedAt.toISOString()}</lastmod>
    <image:image>
      <image:loc>${imageUrl}</image:loc>
      <image:title>${escapeXml(service.title)} - Ataşehir fotoğrafçı Foto Uğur</image:title>
      <image:caption>${escapeXml(service.title)} - Foto Uğur hizmet örneği</image:caption>
    </image:image>
  </url>`)
    }

    // Gallery images
    if (service.images) {
      try {
        const images = JSON.parse(service.images)
        if (Array.isArray(images)) {
          images.forEach((image: string, index: number) => {
            const imageUrl = image.startsWith('http')
              ? image
              : `${baseUrl}${image.startsWith('/') ? '' : '/'}${image}`
            
            imageEntries.push(`  <url>
    <loc>${baseUrl}/hizmetler/${service.slug}</loc>
    <lastmod>${service.updatedAt.toISOString()}</lastmod>
    <image:image>
      <image:loc>${imageUrl}</image:loc>
      <image:title>${escapeXml(service.title)} örneği ${index + 1} - Ataşehir fotoğrafçı Foto Uğur</image:title>
      <image:caption>${escapeXml(service.title)} çalışması ${index + 1} - Foto Uğur</image:caption>
    </image:image>
  </url>`)
          })
        }
      } catch (e) {
        // JSON parse hatası, görmezden gel
      }
    }
  })

  // Gallery images
  galleryItems.forEach((item) => {
    if (item.imageUrl) {
      const imageUrl = item.imageUrl.startsWith('http')
        ? item.imageUrl
        : `${baseUrl}${item.imageUrl.startsWith('/') ? '' : '/'}${item.imageUrl}`
      
      const title = item.title || 'Foto Uğur galeri çalışması'
      
      imageEntries.push(`  <url>
    <loc>${baseUrl}/galeri</loc>
    <lastmod>${item.updatedAt.toISOString()}</lastmod>
    <image:image>
      <image:loc>${imageUrl}</image:loc>
      <image:title>${escapeXml(title)} - Ataşehir fotoğrafçı Foto Uğur</image:title>
      <image:caption>${escapeXml(title)} - Foto Uğur galeri</image:caption>
    </image:image>
  </url>`)
    }
  })

  // XML oluştur
  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
${imageEntries.join('\n')}
</urlset>`

  return new NextResponse(sitemap, {
    headers: {
      'Content-Type': 'application/xml',
    },
  })
}

function escapeXml(unsafe: string): string {
  return unsafe
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;')
}

