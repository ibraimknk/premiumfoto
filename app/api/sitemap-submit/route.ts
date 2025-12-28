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
      // Timeout ekle
      signal: AbortSignal.timeout(10000), // 10 saniye timeout
    })
    
    // Google ve Bing genellikle 404/410 döndürür (ping endpoint'leri artık çalışmıyor)
    // Bu durumda manuel gönderim gerekiyor
    const status = response.status
    const ok = response.ok
    
    // 404 veya 410 durumunda özel mesaj
    if ((searchEngine === "google" || searchEngine === "bing") && (status === 404 || status === 410)) {
      return {
        searchEngine,
        status,
        ok: false,
        sitemapUrl,
        note: "Ping endpoint artık çalışmıyor. Google Search Console / Bing Webmaster Tools üzerinden manuel gönderim yapın.",
      }
    }
    
    return { searchEngine, status, ok, sitemapUrl }
  } catch (error: any) {
    // Timeout veya network hatası
    if (error.name === "TimeoutError" || error.name === "AbortError") {
      return {
        searchEngine,
        error: "Timeout - Endpoint yanıt vermedi",
        sitemapUrl,
        note: searchEngine === "google" || searchEngine === "bing"
          ? "Manuel gönderim önerilir (Google Search Console / Bing Webmaster Tools)"
          : undefined,
      }
    }
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
  
  // Domain kontrolü
  if (domains.length === 0) {
    return NextResponse.json({
      success: false,
      error: "Domain bulunamadı",
      message: "Lütfen .env dosyasına NEXT_PUBLIC_SITE_URLS veya NEXT_PUBLIC_SITE_URL ekleyin. Örnek: NEXT_PUBLIC_SITE_URLS=https://fotougur.com.tr,https://dugunkarem.com.tr,https://dugunkarem.com",
      domains: 0,
      sitemaps: [],
      timestamp: new Date().toISOString(),
    }, { status: 400 })
  }
  
  const allResults: any[] = []

  // Her domain için ayrı sitemap gönder
  for (const domain of domains) {
    const domainSlug = domain.replace(/https?:\/\//, '').replace(/\./g, '-').replace(/\//g, '')
    const sitemapUrl = `${domain}/api/sitemap/${domainSlug}`
    
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
  
  // Domain kontrolü
  if (domains.length === 0) {
    return NextResponse.json({
      success: false,
      error: "Domain bulunamadı",
      message: "Lütfen .env dosyasına NEXT_PUBLIC_SITE_URLS veya NEXT_PUBLIC_SITE_URL ekleyin. Örnek: NEXT_PUBLIC_SITE_URLS=https://fotougur.com.tr,https://dugunkarem.com.tr,https://dugunkarem.com",
      domains: 0,
      sitemaps: [],
      timestamp: new Date().toISOString(),
    }, { status: 400 })
  }
  
  const allResults: any[] = []

  // Her domain için ayrı sitemap gönder
  for (const domain of domains) {
    const domainSlug = domain.replace(/https?:\/\//, '').replace(/\./g, '-').replace(/\//g, '')
    const sitemapUrl = `${domain}/api/sitemap/${domainSlug}`
    
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

