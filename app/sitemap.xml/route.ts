import { NextResponse } from "next/server"
import { getAllDomains } from "@/lib/sitemap-utils"

export const dynamic = 'force-dynamic'

// Ana sitemap index - tüm domain sitemap'lerini listeler
export async function GET() {
  const domains = getAllDomains()
  
  // Sitemap index XML oluştur
  const sitemapIndex = `<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${domains.map(domain => {
  const domainSlug = domain.replace(/https?:\/\//, '').replace(/\./g, '-').replace(/\//g, '')
  return `  <sitemap>
    <loc>${domain}/sitemap-${domainSlug}.xml</loc>
    <lastmod>${new Date().toISOString()}</lastmod>
  </sitemap>`
}).join('\n')}
</sitemapindex>`

  return new NextResponse(sitemapIndex, {
    headers: {
      'Content-Type': 'application/xml',
    },
  })
}

