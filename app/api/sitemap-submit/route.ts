import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { getAllDomains } from "@/lib/sitemap-utils"

export const dynamic = 'force-dynamic'

// Sitemap'i arama motorlarına gönder
async function submitSitemap(searchEngine: string, sitemapUrl: string) {
  const endpoints: { [key: string]: string } = {
    google: `https://www.google.com/ping?sitemap=${encodeURIComponent(sitemapUrl)}`,
    bing: `https://www.bing.com/ping?sitemap=${encodeURIComponent(sitemapUrl)}`,
    yandex: `https://webmaster.yandex.com/ping?sitemap=${encodeURIComponent(sitemapUrl)}`,
  }

  const endpoint = endpoints[searchEngine]
  if (!endpoint) return null

  try {
    const response = await fetch(endpoint, {
      method: "GET",
      headers: {
        "User-Agent": "Foto-Ugur-Sitemap-Bot/1.0",
      },
    })
    return { searchEngine, status: response.status, ok: response.ok, sitemapUrl }
  } catch (error) {
    return { searchEngine, error: String(error), sitemapUrl }
  }
}

export async function GET(request: Request) {
  // Admin session kontrolü
  const session = await getServerSession(authOptions)
  if (!session) {
    // Alternatif olarak token kontrolü (cron job için)
    const authHeader = request.headers.get("authorization")
    const expectedToken = process.env.SITEMAP_SUBMIT_TOKEN

    if (!expectedToken || authHeader !== `Bearer ${expectedToken}`) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }
  }

  const domains = getAllDomains()
  const allResults: any[] = []

  // Her domain için sitemap gönder
  for (const domain of domains) {
    const sitemapUrl = `${domain}/sitemap.xml`
    
    const results = await Promise.all([
      submitSitemap("google", sitemapUrl),
      submitSitemap("bing", sitemapUrl),
      submitSitemap("yandex", sitemapUrl),
    ])

    allResults.push({
      domain,
      sitemapUrl,
      results: results.filter(Boolean),
    })
  }

  return NextResponse.json({
    success: true,
    domains: domains.length,
    sitemaps: allResults,
    timestamp: new Date().toISOString(),
  })
}

export async function POST(request: Request) {
  // Admin session kontrolü
  const session = await getServerSession(authOptions)
  if (!session) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
  }

  const domains = getAllDomains()
  const allResults: any[] = []

  // Her domain için sitemap gönder
  for (const domain of domains) {
    const sitemapUrl = `${domain}/sitemap.xml`
    
    const results = await Promise.all([
      submitSitemap("google", sitemapUrl),
      submitSitemap("bing", sitemapUrl),
      submitSitemap("yandex", sitemapUrl),
    ])

    allResults.push({
      domain,
      sitemapUrl,
      results: results.filter(Boolean),
    })
  }

  return NextResponse.json({
    success: true,
    domains: domains.length,
    sitemaps: allResults,
    timestamp: new Date().toISOString(),
  })
}

