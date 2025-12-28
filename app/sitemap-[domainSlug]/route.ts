import { NextResponse } from "next/server"
import { getAllDomains, generateSitemapUrls } from "@/lib/sitemap-utils"

export const dynamic = 'force-dynamic'

// Her domain için ayrı sitemap oluştur
// URL format: /sitemap-fotougur-com-tr.xml
export async function GET(
  request: Request,
  { params }: { params: { domainSlug: string } }
) {
  const domains = getAllDomains()
  
  // Domain slug'ını gerçek domain'e çevir (fotougur-com-tr -> fotougur.com.tr)
  const domainSlug = params.domainSlug
  const domain = domains.find(d => {
    const dSlug = d.replace(/https?:\/\//, '').replace(/\./g, '-').replace(/\//g, '')
    return dSlug === domainSlug
  })
  
  if (!domain) {
    return new NextResponse('Domain not found', { status: 404 })
  }
  
  // Bu domain için URL'leri oluştur
  const urls = await generateSitemapUrls(domain)
  
  // XML sitemap oluştur
  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map(url => `  <url>
    <loc>${url.url}</loc>
    <lastmod>${url.lastModified?.toISOString() || new Date().toISOString()}</lastmod>
    <changefreq>${url.changeFrequency || 'monthly'}</changefreq>
    <priority>${url.priority || 0.8}</priority>
  </url>`).join('\n')}
</urlset>`

  return new NextResponse(sitemap, {
    headers: {
      'Content-Type': 'application/xml',
    },
  })
}

