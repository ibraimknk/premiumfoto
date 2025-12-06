import { MetadataRoute } from 'next'
import { prisma } from '@/lib/prisma'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://fotougur.com'

  // Static pages
  const staticPages = [
    '',
    '/hakkimizda',
    '/hizmetler',
    '/galeri',
    '/blog',
    '/iletisim',
    '/sss',
    '/kvkk',
    '/gizlilik-politikasi',
    '/cerez-politikasi',
  ]

  // Dynamic pages - Services
  const services = await prisma.service.findMany({
    where: { isActive: true },
    select: { slug: true, updatedAt: true },
  })

  // Dynamic pages - Blog posts
  const blogPosts = await prisma.blogPost.findMany({
    where: { isPublished: true },
    select: { slug: true, updatedAt: true },
  })

  const servicePages = services.map((service) => ({
    url: `${baseUrl}/hizmetler/${service.slug}`,
    lastModified: service.updatedAt,
    changeFrequency: 'monthly' as const,
    priority: 0.8,
  }))

  const blogPages = blogPosts.map((post) => ({
    url: `${baseUrl}/blog/${post.slug}`,
    lastModified: post.updatedAt,
    changeFrequency: 'weekly' as const,
    priority: 0.7,
  }))

  const staticSitemap = staticPages.map((page) => ({
    url: `${baseUrl}${page}`,
    lastModified: new Date(),
    changeFrequency: 'monthly' as const,
    priority: page === '' ? 1.0 : 0.9,
  }))

  return [...staticSitemap, ...servicePages, ...blogPages]
}

