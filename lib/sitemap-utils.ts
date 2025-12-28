import { prisma } from "./prisma"

/**
 * Tüm domain'leri environment variable'dan alır
 * Format: DOMAIN1,DOMAIN2,DOMAIN3 veya tek domain
 */
export function getAllDomains(): string[] {
  const domainsEnv = process.env.NEXT_PUBLIC_SITE_URLS || process.env.NEXT_PUBLIC_SITE_URL || ""
  
  if (!domainsEnv) {
    // Fallback yok - kullanıcı domain'leri .env dosyasında tanımlamalı
    console.warn("⚠️ NEXT_PUBLIC_SITE_URLS veya NEXT_PUBLIC_SITE_URL tanımlı değil. Lütfen .env dosyasına domain'lerinizi ekleyin.")
    return []
  }

  // Virgülle ayrılmış domain'leri parse et
  const domains = domainsEnv
    .split(",")
    .map((d) => d.trim())
    .filter((d) => d.length > 0)
    .map((d) => {
      // http/https kontrolü
      if (!d.startsWith("http://") && !d.startsWith("https://")) {
        return `https://${d}`
      }
      return d
    })

  return domains
}

/**
 * Ana domain'i döndürür (ilk domain)
 */
export function getPrimaryDomain(): string {
  const domains = getAllDomains()
  return domains[0]
}

/**
 * Sitemap URL'lerini oluşturur
 */
export async function generateSitemapUrls(baseUrl: string) {
  // Static pages
  const staticPages = [
    "",
    "/hakkimizda",
    "/hizmetler",
    "/galeri",
    "/blog",
    "/iletisim",
    "/sss",
    "/kvkk",
    "/gizlilik-politikasi",
    "/cerez-politikasi",
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
    changeFrequency: "monthly" as const,
    priority: 0.8,
  }))

  const blogPages = blogPosts.map((post) => ({
    url: `${baseUrl}/blog/${post.slug}`,
    lastModified: post.updatedAt,
    changeFrequency: "weekly" as const,
    priority: 0.7,
  }))

  const staticSitemap = staticPages.map((page) => ({
    url: `${baseUrl}${page}`,
    lastModified: new Date(),
    changeFrequency: "monthly" as const,
    priority: page === "" ? 1.0 : 0.9,
  }))

  return [...staticSitemap, ...servicePages, ...blogPages]
}

