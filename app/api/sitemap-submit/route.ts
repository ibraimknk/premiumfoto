import { NextResponse } from "next/server"

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
    return { searchEngine, status: response.status, ok: response.ok }
  } catch (error) {
    return { searchEngine, error: String(error) }
  }
}

export async function GET(request: Request) {
  const authHeader = request.headers.get("authorization")
  const expectedToken = process.env.SITEMAP_SUBMIT_TOKEN

  // Basit token kontrolü (production'da daha güvenli bir yöntem kullanın)
  if (!expectedToken || authHeader !== `Bearer ${expectedToken}`) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
  }

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com"
  const sitemapUrl = `${baseUrl}/sitemap.xml`

  const results = await Promise.all([
    submitSitemap("google", sitemapUrl),
    submitSitemap("bing", sitemapUrl),
    submitSitemap("yandex", sitemapUrl),
  ])

  return NextResponse.json({
    success: true,
    sitemapUrl,
    results: results.filter(Boolean),
    timestamp: new Date().toISOString(),
  })
}

