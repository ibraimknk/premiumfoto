import { MetadataRoute } from 'next'
import { getAllDomains, generateSitemapUrls } from '@/lib/sitemap-utils'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const domains = getAllDomains()
  const allUrls: MetadataRoute.Sitemap = []

  // Her domain için sitemap URL'lerini oluştur
  for (const domain of domains) {
    const urls = await generateSitemapUrls(domain)
    allUrls.push(...urls)
  }

  return allUrls
}

