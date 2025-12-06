#!/usr/bin/env node

/**
 * Sitemap'i arama motorlarına gönderen script
 * Kullanım: npm run submit-sitemap
 * Veya cron job olarak: 0 2 * * * (her gün saat 02:00'de)
 */

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000"
const SITEMAP_URL = `${SITE_URL}/sitemap.xml`
const TOKEN = process.env.SITEMAP_SUBMIT_TOKEN || "your-secret-token"

async function submitSitemap() {
  try {
    const response = await fetch(`${SITE_URL}/api/sitemap-submit`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${TOKEN}`,
      },
    })

    const data = await response.json()
    console.log("Sitemap submission result:", JSON.stringify(data, null, 2))
    return data
  } catch (error) {
    console.error("Error submitting sitemap:", error)
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

