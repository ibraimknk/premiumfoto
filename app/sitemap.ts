import { MetadataRoute } from 'next'
import { getAllDomains } from '@/lib/sitemap-utils'

// Ana sitemap index - tüm domain sitemap'lerini listeler
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const domains = getAllDomains()
  
  // Her domain için ayrı sitemap referansı oluştur
  return domains.map(domain => {
    const domainSlug = domain.replace(/https?:\/\//, '').replace(/\./g, '-').replace(/\//g, '')
    return {
      url: `${domain}/sitemap-${domainSlug}.xml`,
      lastModified: new Date(),
      changeFrequency: 'daily' as const,
      priority: 1.0,
    }
  })
}

