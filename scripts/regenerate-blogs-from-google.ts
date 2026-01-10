/**
 * Google'da indexlenen blog sayfalarını bulup,
 * aynı URL ve konuyla otomatik blog oluşturma scripti
 */

import { prisma } from '../lib/prisma'
import { GoogleGenerativeAI } from '@google/generative-ai'
import * as cheerio from 'cheerio'

// Gemini API Key
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY)

// Google Custom Search API (opsiyonel - eğer API key varsa)
const GOOGLE_SEARCH_API_KEY = process.env.GOOGLE_SEARCH_API_KEY || ""
const GOOGLE_SEARCH_ENGINE_ID = process.env.GOOGLE_SEARCH_ENGINE_ID || ""

/**
 * Google Custom Search API ile blog URL'lerini bul
 */
async function findBlogUrlsFromGoogle(query: string = "site:fotougur.com.tr/blog"): Promise<string[]> {
  const urls: string[] = []

  if (!GOOGLE_SEARCH_API_KEY || !GOOGLE_SEARCH_ENGINE_ID) {
    console.log("⚠️  Google Custom Search API key bulunamadı, alternatif yöntem kullanılıyor...")
    return findBlogUrlsAlternative()
  }

  try {
    const searchUrl = `https://www.googleapis.com/customsearch/v1?key=${GOOGLE_SEARCH_API_KEY}&cx=${GOOGLE_SEARCH_ENGINE_ID}&q=${encodeURIComponent(query)}&num=100`
    
    const response = await fetch(searchUrl)
    const data = await response.json()

    if (data.items) {
      for (const item of data.items) {
        if (item.link && item.link.includes('/blog/')) {
          urls.push(item.link)
        }
      }
    }

    console.log(`✅ Google'dan ${urls.length} blog URL'i bulundu`)
  } catch (error: any) {
    console.error("❌ Google Custom Search API hatası:", error.message)
    console.log("🔄 Alternatif yöntem deneniyor...")
    return findBlogUrlsAlternative()
  }

  return urls
}

/**
 * CSV dosyasından blog URL'lerini oku
 */
async function findBlogUrlsFromCSV(csvPath: string = "blog_urls_only.csv"): Promise<string[]> {
  const urls: string[] = []
  const fs = await import('fs/promises')
  const path = await import('path')

  try {
    const csvContent = await fs.readFile(csvPath, 'utf-8')
    const lines = csvContent.split('\n').filter(line => line.trim())
    
    // İlk satır başlık, atla
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i].trim()
      if (!line) continue
      
      // CSV formatı: url,verdict,coverageState,lastCrawlTime
      const parts = line.split(',')
      if (parts.length > 0) {
        const url = parts[0].trim().replace(/^"|"$/g, '') // Tırnak işaretlerini kaldır
        if (url && url.includes('/blog/')) {
          urls.push(url)
        }
      }
    }

    console.log(`✅ CSV'den ${urls.length} blog URL'i bulundu`)
  } catch (error: any) {
    if (error.code === 'ENOENT') {
      console.log(`⚠️  CSV dosyası bulunamadı: ${csvPath}`)
    } else {
      console.error("❌ CSV okuma hatası:", error.message)
    }
  }

  return urls
}

/**
 * Alternatif yöntem: Sitemap.xml veya manuel URL listesi
 */
async function findBlogUrlsAlternative(): Promise<string[]> {
  const urls: string[] = []

  // Önce CSV dosyasını kontrol et (google.py script'inden gelen)
  const csvUrls = await findBlogUrlsFromCSV()
  if (csvUrls.length > 0) {
    return csvUrls
  }

  try {
    // Sitemap.xml'den blog URL'lerini çek
    const sitemapUrl = "https://fotougur.com.tr/sitemap.xml"
    const response = await fetch(sitemapUrl)
    const text = await response.text()
    
    // XML'den blog URL'lerini çıkar
    const blogUrlRegex = /<loc>(https?:\/\/[^<]*\/blog\/[^<]*)<\/loc>/g
    let match
    while ((match = blogUrlRegex.exec(text)) !== null) {
      urls.push(match[1])
    }

    console.log(`✅ Sitemap'ten ${urls.length} blog URL'i bulundu`)
  } catch (error: any) {
    console.error("❌ Sitemap okuma hatası:", error.message)
    console.log("💡 Manuel URL listesi kullanılabilir")
  }

  // Eğer sitemap'ten bulunamazsa, örnek URL'ler ekle
  if (urls.length === 0) {
    console.log("⚠️  Sitemap'ten URL bulunamadı, örnek URL'ler kullanılıyor...")
    // Buraya manuel olarak bilinen blog URL'lerini ekleyebilirsiniz
    urls.push(
      "https://fotougur.com.tr/blog/dugun-fotografciligi",
      "https://fotougur.com.tr/blog/urun-fotografciligi",
      "https://fotougur.com.tr/blog/dis-mekan-cekimi"
    )
  }

  return urls
}

/**
 * URL'den slug çıkar
 */
function extractSlugFromUrl(url: string): string {
  try {
    const urlObj = new URL(url)
    const pathParts = urlObj.pathname.split('/').filter(p => p)
    const blogIndex = pathParts.indexOf('blog')
    
    if (blogIndex !== -1 && pathParts.length > blogIndex + 1) {
      return pathParts[blogIndex + 1]
    }
    
    // Eğer /blog/ sonrası yoksa, URL'nin son kısmını al
    return pathParts[pathParts.length - 1] || 'blog-post'
  } catch {
    return 'blog-post'
  }
}

/**
 * URL'den içeriği çek ve konuyu çıkar
 */
async function extractTopicFromUrl(url: string): Promise<string | null> {
  try {
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      }
    })
    const html = await response.text()
    const $ = cheerio.load(html)

    // Başlıktan konuyu çıkar
    const title = $('h1').first().text().trim() || 
                  $('title').text().trim() ||
                  $('meta[property="og:title"]').attr('content') ||
                  ''

    if (title) {
      return title
    }

    // Meta description'dan konuyu çıkar
    const description = $('meta[name="description"]').attr('content') ||
                       $('meta[property="og:description"]').attr('content') ||
                       ''

    return description || null
  } catch (error: any) {
    console.error(`❌ URL içerik çekme hatası (${url}):`, error.message)
    return null
  }
}

/**
 * Gemini API ile blog oluştur
 */
async function generateBlogFromTopic(topic: string, originalUrl: string, originalSlug: string): Promise<any> {
  try {
    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' })

    const prompt = `Sen bir profesyonel SEO uzmanı ve içerik yazarısın. Fotoğrafçılık ve düğün fotoğrafçılığı konusunda uzmanlaşmış bir web sitesi için SEO uyumlu, kaliteli bir blog yazısı oluştur.

Orijinal Konu/Başlık: ${topic}
Orijinal URL: ${originalUrl}
Orijinal Slug: ${originalSlug}

Lütfen aynı konuda, aynı slug ile (${originalSlug}) ama tamamen yeni ve özgün bir içerik oluştur. İçerik benzer konuda olmalı ama aynı olmamalı.

Lütfen aşağıdaki formatta JSON yanıt ver:

{
  "title": "SEO uyumlu, çekici başlık (50-60 karakter, konuyla ilgili)",
  "slug": "${originalSlug}",
  "excerpt": "Kısa açıklama (150-160 karakter, SEO için optimize edilmiş)",
  "category": "Kategori adı (örn: Düğün Fotoğrafçılığı, Ürün Fotoğrafçılığı, Teknik İpuçları)",
  "seoTitle": "SEO başlığı (50-60 karakter, title'dan biraz farklı olabilir)",
  "seoDescription": "Meta açıklama (150-160 karakter, arama motorları için optimize edilmiş)",
  "seoKeywords": "anahtar,kelimeler,virgülle,ayrılmış (5-10 anahtar kelime)",
  "content": "HTML formatında zengin içerik. En az 1000 kelime. H1, H2, H3 başlıkları kullan. Paragraflar <p> etiketi ile. Liste varsa <ul><li> kullan. SEO için optimize edilmiş, doğal dilde, değerli bilgiler içeren içerik. İçerik Türkçe olmalı. Görseller için <img> etiketi kullan ve alt attribute'u ekle (SEO için önemli).",
  "coverImageAlt": "Blog görseli için SEO uyumlu alt text (80-100 karakter, anahtar kelimeler içermeli)"
}

Önemli kurallar:
1. Slug "${originalSlug}" olmalı (değiştirme)
2. İçerik tamamen Türkçe olmalı
3. SEO için optimize edilmiş olmalı (anahtar kelimeler doğal şekilde kullanılmalı)
4. İçerik en az 1000 kelime olmalı
5. H1, H2, H3 başlıkları kullanılmalı
6. Değerli, bilgilendirici içerik olmalı
7. JSON formatında yanıt ver, başka açıklama ekleme`

    const result = await model.generateContent(prompt)
    const response = await result.response
    const text = response.text()

    // JSON'u temizle
    let jsonText = text.trim()
    if (jsonText.startsWith("```json")) {
      jsonText = jsonText.replace(/^```json\s*/, "").replace(/\s*```$/, "")
    } else if (jsonText.startsWith("```")) {
      jsonText = jsonText.replace(/^```\s*/, "").replace(/\s*```$/, "")
    }

    // JSON parse
    const blogData = JSON.parse(jsonText)

    // Slug'ı temizle
    blogData.slug = blogData.slug
      .toLowerCase()
      .replace(/ş/g, "s")
      .replace(/ç/g, "c")
      .replace(/ğ/g, "g")
      .replace(/ı/g, "i")
      .replace(/ö/g, "o")
      .replace(/ü/g, "u")
      .replace(/[^a-z0-9-]/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-|-$/g, "")

    return blogData
  } catch (error: any) {
    console.error("❌ Gemini API hatası:", error.message)
    throw error
  }
}

/**
 * Blog'u veritabanına kaydet
 */
async function saveBlogToDatabase(blogData: any, originalUrl: string): Promise<any> {
  try {
    // Slug'ın benzersiz olduğundan emin ol
    let slug = blogData.slug
    let existingPost = await prisma.blogPost.findUnique({
      where: { slug },
    })

    // Eğer aynı slug varsa, güncelle
    if (existingPost) {
      console.log(`🔄 Mevcut blog güncelleniyor: ${slug}`)
      const updatedPost = await prisma.blogPost.update({
        where: { slug },
        data: {
          title: blogData.title,
          excerpt: blogData.excerpt,
          content: blogData.content,
          category: blogData.category,
          seoTitle: blogData.seoTitle,
          seoDescription: blogData.seoDescription,
          seoKeywords: blogData.seoKeywords,
          isPublished: true,
          publishedAt: new Date(),
        },
      })
      return updatedPost
    }

    // Yeni blog oluştur
    console.log(`✅ Yeni blog oluşturuluyor: ${slug}`)
    const newPost = await prisma.blogPost.create({
      data: {
        title: blogData.title,
        slug,
        excerpt: blogData.excerpt,
        content: blogData.content,
        category: blogData.category,
        seoTitle: blogData.seoTitle,
        seoDescription: blogData.seoDescription,
        seoKeywords: blogData.seoKeywords,
        isPublished: true,
        publishedAt: new Date(),
      },
    })

    return newPost
  } catch (error: any) {
    console.error("❌ Veritabanı kayıt hatası:", error.message)
    throw error
  }
}

/**
 * Ana fonksiyon
 */
async function main() {
  console.log("🚀 Google'da indexlenen blog sayfaları bulunuyor...\n")

  try {
    // 1. Önce CSV dosyasını kontrol et (google.py script'inden gelen)
    let urls = await findBlogUrlsFromCSV("blog_urls_only.csv")
    
    // 2. CSV yoksa veya boşsa, Google'dan veya sitemap'ten bul
    if (urls.length === 0) {
      console.log("📋 CSV dosyası bulunamadı veya boş, alternatif yöntemler deneniyor...\n")
      urls = await findBlogUrlsFromGoogle("site:fotougur.com.tr/blog")
    }
    
    if (urls.length === 0) {
      console.log("❌ Hiç blog URL'i bulunamadı!")
      return
    }

    console.log(`\n📋 ${urls.length} blog URL'i bulundu:\n`)
    urls.forEach((url, index) => {
      console.log(`${index + 1}. ${url}`)
    })

    // Mevcut blog sayısını kontrol et
    const existingBlogs = await prisma.blogPost.findMany({
      select: { slug: true },
    })
    const existingSlugs = new Set(existingBlogs.map(b => b.slug))
    const missingUrls = urls.filter(url => {
      const slug = extractSlugFromUrl(url)
      return !existingSlugs.has(slug)
    })

    console.log(`\n📊 İstatistikler:`)
    console.log(`   Toplam URL: ${urls.length}`)
    console.log(`   Mevcut blog: ${existingBlogs.length}`)
    console.log(`   Eksik blog: ${missingUrls.length}`)

    if (missingUrls.length === 0) {
      console.log(`\n✅ Tüm blog'lar zaten mevcut!`)
      await prisma.$disconnect()
      return
    }

    console.log(`\n🔄 Eksik ${missingUrls.length} blog oluşturuluyor...\n`)
    
    // Sadece eksik URL'leri işle
    urls = missingUrls

    // 2. Her URL için blog oluştur
    const results = {
      success: [] as any[],
      failed: [] as { url: string; error: string }[],
    }

    for (let i = 0; i < urls.length; i++) {
      const url = urls[i]
      const slug = extractSlugFromUrl(url)

      try {
        console.log(`\n[${i + 1}/${urls.length}] İşleniyor: ${url}`)
        console.log(`   Slug: ${slug}`)

        // Önce mevcut blogu kontrol et
        const existingPost = await prisma.blogPost.findUnique({
          where: { slug },
        })

        if (existingPost) {
          console.log(`   ⏭️  Blog zaten mevcut, atlanıyor: ${existingPost.title}`)
          continue // Mevcut blog varsa, atla
        }

        // URL'den konuyu çıkar
        const topic = await extractTopicFromUrl(url)
        if (!topic) {
          console.log(`   ⚠️  Konu çıkarılamadı, slug'dan konu oluşturuluyor...`)
          // Slug'dan konu oluştur
          const topicFromSlug = slug
            .split('-')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ')
          await processBlog(url, slug, topicFromSlug, results)
        } else {
          console.log(`   📝 Konu: ${topic}`)
          await processBlog(url, slug, topic, results)
        }

        // Rate limit için bekleme
        if (i < urls.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 3000)) // 3 saniye bekle
        }
      } catch (error: any) {
        console.error(`   ❌ Hata: ${error.message}`)
        results.failed.push({ url, error: error.message })
      }
    }

    // 3. Sonuçları göster
    console.log("\n" + "=".repeat(60))
    console.log("📊 SONUÇLAR")
    console.log("=".repeat(60))
    console.log(`✅ Başarılı: ${results.success.length}`)
    console.log(`❌ Başarısız: ${results.failed.length}`)
    
    if (results.success.length > 0) {
      console.log("\n✅ Başarılı blog'lar:")
      results.success.forEach(post => {
        console.log(`   - ${post.title} (${post.slug})`)
      })
    }

    if (results.failed.length > 0) {
      console.log("\n❌ Başarısız blog'lar:")
      results.failed.forEach(({ url, error }) => {
        console.log(`   - ${url}: ${error}`)
      })
    }

  } catch (error: any) {
    console.error("❌ Genel hata:", error.message)
  } finally {
    await prisma.$disconnect()
  }
}

/**
 * Blog işleme fonksiyonu
 */
async function processBlog(
  url: string,
  slug: string,
  topic: string,
  results: { success: any[]; failed: { url: string; error: string }[] }
) {
  try {
    // Gemini ile blog oluştur
    const blogData = await generateBlogFromTopic(topic, url, slug)
    console.log(`   ✅ Blog içeriği oluşturuldu: ${blogData.title}`)

    // Veritabanına kaydet
    const savedPost = await saveBlogToDatabase(blogData, url)
    console.log(`   ✅ Veritabanına kaydedildi: ${savedPost.id}`)

    results.success.push(savedPost)
  } catch (error: any) {
    throw error
  }
}

// Script'i çalıştır
main().catch(console.error)

