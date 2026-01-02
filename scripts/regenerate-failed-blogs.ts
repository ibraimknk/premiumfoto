/**
 * Başarısız olan blog'ları tekrar oluşturma scripti
 */

import { prisma } from '../lib/prisma'
import { GoogleGenerativeAI } from '@google/generative-ai'
import * as cheerio from 'cheerio'

// Gemini API Key
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY)

// Başarısız olan URL'ler
const FAILED_URLS = [
  'https://fotougur.com.tr/blog/dogal-isikta-dugun-fotografciligi-sirlari',
  'https://fotougur.com.tr/blog/her-ortamda-mukemmel-isigi-yakalayin-fotografcilikta-aydinlatma-sirlari'
]

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

    const title = $('h1').first().text().trim() || 
                  $('title').text().trim() ||
                  $('meta[property="og:title"]').attr('content') ||
                  ''

    if (title) {
      return title
    }

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
 * Gemini API ile blog oluştur (daha güvenli JSON parsing ile)
 */
async function generateBlogFromTopic(topic: string, originalUrl: string, originalSlug: string): Promise<any> {
  try {
    const modelsToTry = [
      "gemini-2.0-flash",
      "gemini-2.5-flash",
      "gemini-1.5-flash",
      "gemini-pro"
    ]
    
    let model = null
    for (const modelName of modelsToTry) {
      try {
        const testModel = genAI.getGenerativeModel({ model: modelName })
        await testModel.generateContent("Hi")
        model = testModel
        console.log(`   ✅ Model seçildi: ${modelName}`)
        break
      } catch {
        continue
      }
    }
    
    if (!model) {
      throw new Error("Çalışan Gemini modeli bulunamadı")
    }

    const prompt = `Sen bir profesyonel SEO uzmanı ve içerik yazarısın. Fotoğrafçılık ve düğün fotoğrafçılığı konusunda uzmanlaşmış bir web sitesi için SEO uyumlu, kaliteli bir blog yazısı oluştur.

Orijinal Konu/Başlık: ${topic}
Orijinal URL: ${originalUrl}
Orijinal Slug: ${originalSlug}

Lütfen aynı konuda, aynı slug ile (${originalSlug}) ama tamamen yeni ve özgün bir içerik oluştur.

ÖNEMLİ: JSON formatında yanıt ver, sadece JSON, başka açıklama ekleme. JSON içinde özel karakterler (tırnak, virgül, vb.) escape edilmeli.

{
  "title": "SEO uyumlu başlık (50-60 karakter)",
  "slug": "${originalSlug}",
  "excerpt": "Kısa açıklama (150-160 karakter)",
  "category": "Kategori adı",
  "seoTitle": "SEO başlığı (50-60 karakter)",
  "seoDescription": "Meta açıklama (150-160 karakter)",
  "seoKeywords": "anahtar,kelimeler,virgülle,ayrılmış",
  "content": "HTML formatında zengin içerik. En az 1000 kelime. H1, H2, H3 başlıkları kullan. Paragraflar <p> etiketi ile. Liste varsa <ul><li> kullan. İçerik Türkçe olmalı. JSON içinde özel karakterler escape edilmeli (\\" gibi).",
  "coverImageAlt": "Blog görseli için SEO uyumlu alt text"
}`

    const result = await model.generateContent(prompt)
    const response = await result.response
    let text = response.text()

    // JSON'u temizle
    let jsonText = text.trim()
    if (jsonText.startsWith("```json")) {
      jsonText = jsonText.replace(/^```json\s*/, "").replace(/\s*```$/, "")
    } else if (jsonText.startsWith("```")) {
      jsonText = jsonText.replace(/\s*```\s*/g, "")
    }

    // JSON içindeki geçersiz karakterleri temizle
    jsonText = jsonText
      .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F]/g, "") // Kontrol karakterlerini kaldır
      .replace(/\n/g, " ") // Yeni satırları boşluğa çevir
      .replace(/\r/g, "") // Carriage return'leri kaldır
      .replace(/\t/g, " ") // Tab'leri boşluğa çevir
      .replace(/\\"/g, '"') // Escaped tırnakları düzelt
      .replace(/\\'/g, "'") // Escaped apostrophe'ları düzelt

    // JSON parse dene
    let blogData
    try {
      blogData = JSON.parse(jsonText)
    } catch (parseError: any) {
      console.error("❌ JSON parse hatası, daha agresif temizleme deneniyor...")
      console.error("JSON metni (ilk 500 karakter):", jsonText.substring(0, 500))
      
      // Daha agresif temizleme
      jsonText = jsonText
        .replace(/[^\x20-\x7E\u00A0-\uFFFF]/g, "") // Sadece yazdırılabilir karakterler
        .replace(/([{,]\s*"[^"]*":\s*)"([^"]*)"([,}])/g, '$1"$2"$3') // String değerlerini düzelt
      
      try {
        blogData = JSON.parse(jsonText)
      } catch (secondError: any) {
        // Son çare: Manuel JSON oluştur
        console.error("❌ JSON parse başarısız, manuel oluşturuluyor...")
        const slugParts = originalSlug.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1))
        blogData = {
          title: slugParts.join(' '),
          slug: originalSlug,
          excerpt: topic.substring(0, 160),
          category: "Fotoğrafçılık",
          seoTitle: slugParts.join(' '),
          seoDescription: topic.substring(0, 160),
          seoKeywords: originalSlug.split('-').join(','),
          content: `<h1>${slugParts.join(' ')}</h1><p>${topic}</p>`,
          coverImageAlt: slugParts.join(' ')
        }
      }
    }

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
    let slug = blogData.slug
    let existingPost = await prisma.blogPost.findUnique({
      where: { slug },
    })

    if (existingPost) {
      console.log(`   🔄 Mevcut blog güncelleniyor: ${slug}`)
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

    console.log(`   ✅ Yeni blog oluşturuluyor: ${slug}`)
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
  console.log("🚀 Başarısız blog'lar tekrar oluşturuluyor...\n")

  try {
    const results = {
      success: [] as any[],
      failed: [] as { url: string; error: string }[],
    }

    for (let i = 0; i < FAILED_URLS.length; i++) {
      const url = FAILED_URLS[i]
      const slug = extractSlugFromUrl(url)

      try {
        console.log(`\n[${i + 1}/${FAILED_URLS.length}] İşleniyor: ${url}`)
        console.log(`   Slug: ${slug}`)

        const topic = await extractTopicFromUrl(url)
        if (!topic) {
          const topicFromSlug = slug
            .split('-')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ')
          await processBlog(url, slug, topicFromSlug, results)
        } else {
          console.log(`   📝 Konu: ${topic}`)
          await processBlog(url, slug, topic, results)
        }

        if (i < FAILED_URLS.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 3000))
        }
      } catch (error: any) {
        console.error(`   ❌ Hata: ${error.message}`)
        results.failed.push({ url, error: error.message })
      }
    }

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

async function processBlog(
  url: string,
  slug: string,
  topic: string,
  results: { success: any[]; failed: { url: string; error: string }[] }
) {
  try {
    const blogData = await generateBlogFromTopic(topic, url, slug)
    console.log(`   ✅ Blog içeriği oluşturuldu: ${blogData.title}`)

    const savedPost = await saveBlogToDatabase(blogData, url)
    console.log(`   ✅ Veritabanına kaydedildi: ${savedPost.id}`)

    results.success.push(savedPost)
  } catch (error: any) {
    throw error
  }
}

main().catch(console.error)

