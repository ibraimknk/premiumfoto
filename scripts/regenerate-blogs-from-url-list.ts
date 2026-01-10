/**
 * Verilen URL listesinden otomatik blog oluşturma scripti
 * Her benzersiz URL için bir kez blog oluşturur
 */

import { prisma } from '../lib/prisma'
import { GoogleGenerativeAI } from '@google/generative-ai'
import * as cheerio from 'cheerio'

// Gemini API Key
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY)

// Verilen URL listesi
const URL_LIST = `
https://fotougur.com.tr/blog/atasehir-fotograf-studyosu-anilarinizi-olumsuzlestirin
https://fotougur.com.tr/blog/dogal-isikta-dugun-fotografciligi-sirlari
https://fotougur.com.tr/blog/dugun-fotografciligi-dogal-anlar-sirlari
https://fotougur.com.tr/blog/atasehir-biyometrik-fotograf-cekimi-rehberi
https://fotougur.com.tr/blog/dogal-isikla-harikalar-yaratin-fotografcilikta-ustalasmak
https://fotougur.com.tr/blog/atashehir-foto-ugur-aninda-biyometrik-fotograf
https://fotougur.com.tr/blog/dugun-fotografciliginda-dogal-anlar-yakalama-sanati
https://fotougur.com.tr/blog/dinamik-finans-merkezinde-profesyonel-fotograf-cozumleri
https://fotougur.com.tr/blog/istanbul-finans-merkezi-profesyonel-portre-cekimleri
https://fotougur.com.tr/blog/biyometrik-fotograf-kurallari-adim-adim-rehberiniz
https://fotougur.com.tr/blog/dogal-isikla-dugun-fotografciligi-buyulu-anlar-yakalayin
https://fotougur.com.tr/blog/atasehirde-fotograf-studyosu-secim-rehberi-anilariniz-guvende
https://fotougur.com.tr/blog/dis-mekan-cekimlerinde-flasin-gucu-isigi-kontrol-edin
https://fotougur.com.tr/blog/her-ortamda-mukemmel-isigi-yakalayin-fotografcilikta-aydinlatma-sirlari
https://fotougur.com.tr/blog/hizli-biyometrik-fotograf-sec-begen-3-dakikada-teslim-al
https://dugunkarem.com.tr/blog/atasehir-fotograf-studyosu-anilarinizi-olumsuzlestirin
https://dugunkarem.com.tr/blog/dogal-isikta-dugun-fotografciligi-sirlari
https://dugunkarem.com.tr/blog/atasehir-biyometrik-fotograf-cekimi-rehberi
https://dugunkarem.com.tr/blog/dogal-isikla-harikalar-yaratin-fotografcilikta-ustalasmak
https://dugunkarem.com.tr/blog/atashehir-foto-ugur-aninda-biyometrik-fotograf
https://dugunkarem.com.tr/blog/dugun-fotografciliginda-5-onemli-ipucu
https://dugunkarem.com.tr/blog/dugun-fotografciliginda-dogal-anlar-yakalama-sanati
https://dugunkarem.com.tr/blog/istanbul-finans-merkezi-profesyonel-portre-cekimleri
https://dugunkarem.com.tr/blog/2026-biyometrik-fotograf-fiyatlari-kapsamli-rehber
https://dugunkarem.com.tr/blog/dogal-isikla-dugun-fotografciligi-buyulu-anlar-yakalayin
https://dugunkarem.com.tr/blog/biyometrik-fotograf-kurallari-adim-adim-rehberiniz
https://dugunkarem.com.tr/blog/sosyal-medya-icin-profesyonel-gorsel-icerik
https://dugunkarem.com.tr/blog/her-ortamda-mukemmel-isigi-yakalayin-fotografcilikta-aydinlatma-sirlari
https://dugunkarem.com.tr/blog/dis-mekan-cekimi-icin-en-iyi-lokasyonlar
`.trim()

/**
 * URL listesini parse et ve benzersiz URL'leri çıkar
 */
function parseUniqueUrls(urlList: string): string[] {
  const urls = urlList
    .split('\n')
    .map(line => line.trim())
    .filter(line => line && line.startsWith('http') && line.includes('/blog/'))
    .filter(line => !line.endsWith('/blog')) // Ana blog sayfasını filtrele
  
  // Benzersiz URL'leri çıkar (aynı path'e sahip olanlar)
  const uniqueUrls = new Map<string, string>()
  
  for (const url of urls) {
    try {
      const urlObj = new URL(url)
      const path = urlObj.pathname
      
      // Aynı path'e sahip URL'lerden sadece birini tut (fotougur.com.tr öncelikli)
      if (!uniqueUrls.has(path) || url.includes('fotougur.com.tr')) {
        uniqueUrls.set(path, url)
      }
    } catch {
      // Geçersiz URL'leri atla
      continue
    }
  }
  
  return Array.from(uniqueUrls.values())
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
    // Çalışan modeli bul
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

    // Yeni blog oluştur
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
 * Veritabanındaki tüm blog slug'larını al
 */
async function getExistingBlogSlugs(): Promise<Set<string>> {
  try {
    const posts = await prisma.blogPost.findMany({
      select: { slug: true },
    })
    const slugs = new Set(posts.map(post => post.slug))
    console.log(`📊 Veritabanında ${slugs.size} mevcut blog bulundu`)
    return slugs
  } catch (error: any) {
    console.error("❌ Veritabanı okuma hatası:", error.message)
    return new Set()
  }
}

/**
 * Eksik blog URL'lerini filtrele (veritabanında olmayan)
 */
async function filterMissingBlogs(urls: string[]): Promise<string[]> {
  const existingSlugs = await getExistingBlogSlugs()
  const missingUrls: string[] = []

  for (const url of urls) {
    const slug = extractSlugFromUrl(url)
    if (!existingSlugs.has(slug)) {
      missingUrls.push(url)
      console.log(`   ⚠️  Eksik: ${slug} (${url})`)
    } else {
      console.log(`   ✅ Mevcut: ${slug}`)
    }
  }

  return missingUrls
}

/**
 * Ana fonksiyon
 */
async function main() {
  console.log("🚀 URL listesinden eksik blog'lar oluşturuluyor...\n")

  try {
    // 1. URL listesini parse et ve benzersiz URL'leri çıkar
    const urls = parseUniqueUrls(URL_LIST)
    
    if (urls.length === 0) {
      console.log("❌ Hiç geçerli blog URL'i bulunamadı!")
      return
    }

    console.log(`📋 ${urls.length} benzersiz blog URL'i bulundu:\n`)
    urls.forEach((url, index) => {
      console.log(`${index + 1}. ${url}`)
    })

    // 2. Veritabanındaki mevcut blog'ları kontrol et
    console.log("\n🔍 Veritabanındaki mevcut blog'lar kontrol ediliyor...\n")
    const missingUrls = await filterMissingBlogs(urls)
    
    if (missingUrls.length === 0) {
      console.log("\n✅ Tüm blog'lar zaten veritabanında mevcut! Eksik blog yok.")
      return
    }

    console.log(`\n📋 ${missingUrls.length} eksik blog URL'i bulundu:\n`)
    missingUrls.forEach((url, index) => {
      console.log(`${index + 1}. ${url}`)
    })

    console.log("\n🔄 Eksik blog'lar oluşturuluyor...\n")

    // 3. Sadece eksik URL'ler için blog oluştur
    const results = {
      success: [] as any[],
      failed: [] as { url: string; error: string }[],
    }

    for (let i = 0; i < missingUrls.length; i++) {
      const url = missingUrls[i]
      const slug = extractSlugFromUrl(url)

      try {
        console.log(`\n[${i + 1}/${missingUrls.length}] İşleniyor: ${url}`)
        console.log(`   Slug: ${slug} (Google index'i korunuyor)`)

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
        if (i < missingUrls.length - 1) {
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

