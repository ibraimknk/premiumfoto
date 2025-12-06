import { MetadataRoute } from 'next'
import { getPrimaryDomain } from '@/lib/sitemap-utils'

export default function robots(): MetadataRoute.Robots {
  const baseUrl = getPrimaryDomain()

  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/admin/', '/api/admin/'],
      },
    ],
    sitemap: `${baseUrl}/sitemap.xml`,
  }
}

