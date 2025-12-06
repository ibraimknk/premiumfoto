#!/usr/bin/env node

/**
 * Sitemap'i arama motorlarına gönderen script
 * Kullanım: npm run submit-sitemap
 * Veya cron job olarak: 0 2 * * * (her gün saat 02:00'de)
 */

// Site URL'ini belirle - çoklu domain varsa ilkini kullan
function getSiteUrl(): string {
  // Önce NEXT_PUBLIC_SITE_URLS kontrol et (çoklu domain)
  if (process.env.NEXT_PUBLIC_SITE_URLS) {
    const domains = process.env.NEXT_PUBLIC_SITE_URLS.split(",").map((d) => d.trim())
    if (domains.length > 0) {
      let url = domains[0]
      // http/https kontrolü
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = `https://${url}`
      }
      return url
    }
  }
  
  // Tek domain veya fallback
  const url = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000"
  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    return `https://${url}`
  }
  return url
}

const SITE_URL = getSiteUrl()
const SITEMAP_URL = `${SITE_URL}/sitemap.xml`
const TOKEN = process.env.SITEMAP_SUBMIT_TOKEN || "your-secret-token"

async function submitSitemap() {
  try {
    console.log(`📤 Sitemap gönderiliyor: ${SITE_URL}/api/sitemap-submit`)
    
    const response = await fetch(`${SITE_URL}/api/sitemap-submit`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${TOKEN}`,
      },
    })

    // Önce response text olarak al
    const text = await response.text()
    
    // Response'un JSON olup olmadığını kontrol et
    const contentType = response.headers.get("content-type")
    if (!contentType || !contentType.includes("application/json")) {
      console.error("❌ API yanıtı JSON değil. Status:", response.status)
      console.error("Content-Type:", contentType)
      console.error("Response (ilk 500 karakter):", text.substring(0, 500))
      throw new Error(`API yanıtı JSON değil. Status: ${response.status}`)
    }

    if (!response.ok) {
      try {
        const errorData = JSON.parse(text)
        throw new Error(errorData.error || `HTTP ${response.status}`)
      } catch (parseError) {
        throw new Error(`HTTP ${response.status}: ${text.substring(0, 200)}`)
      }
    }

    const data = JSON.parse(text)
    console.log("✅ Sitemap submission result:", JSON.stringify(data, null, 2))
    return data
  } catch (error: any) {
    console.error("❌ Error submitting sitemap:", error.message || error)
    throw error
  }
}

if (require.main === module) {
  submitSitemap()
    .then(() => {
      console.log("✅ Sitemap submitted successfully")
      process.exit(0)
    })
    .catch((error) => {
      console.error("❌ Failed to submit sitemap:", error)
      process.exit(1)
    })
}

export { submitSitemap }

