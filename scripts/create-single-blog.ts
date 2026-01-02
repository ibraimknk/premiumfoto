/**
 * Tek bir URL için blog oluşturma scripti
 */

import { prisma } from '../lib/prisma'
import { generateBlogPost } from '../lib/gemini'

// Blog URL'i
const BLOG_URL = process.argv[2] || 'https://fotougur.com.tr/blog/hizli-biyometrik-fotograf-sec-begen-3-dakikada-teslim-al'

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
 * Slug'dan konu çıkar
 */
function extractTopicFromSlug(slug: string): string {
  return slug
    .split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')
}

/**
 * Blog içeriğini oluştur ve veritabanına kaydet/güncelle
 */
async function createOrUpdateBlog(
  url: string,
  slug: string,
  topic: string
) {
  try {
    console.log(`\n🚀 Blog oluşturuluyor: ${url}`)
    console.log(`   Slug: ${slug}`)
    console.log(`   Konu: ${topic}`)
    
    // Gemini API ile blog içeriği oluştur
    console.log(`   🤖 Gemini API ile içerik oluşturuluyor...`)
    const blogData = await generateBlogPost(topic)
    console.log(`   ✅ İçerik oluşturuldu: ${blogData.title}`)

    // Mevcut blogu kontrol et
    const existingPost = await prisma.blogPost.findUnique({
      where: { slug },
    })

    if (existingPost) {
      console.log(`   🔄 Mevcut blog güncelleniyor...`)
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
      console.log(`   ✅ Blog güncellendi: ${updatedPost.title}`)
      return updatedPost
    }

    // Yeni blog oluştur
    console.log(`   ✅ Yeni blog oluşturuluyor...`)
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
    console.log(`   ✅ Blog oluşturuldu: ${newPost.title}`)
    return newPost
  } catch (error: any) {
    console.error(`   ❌ Hata: ${error.message}`)
    throw error
  }
}

/**
 * Ana fonksiyon
 */
async function main() {
  console.log("🚀 Tek Blog Oluşturma Scripti")
  console.log("=" .repeat(60))
  
  const slug = extractSlugFromUrl(BLOG_URL)
  const topic = extractTopicFromSlug(slug)

  try {
    const post = await createOrUpdateBlog(BLOG_URL, slug, topic)
    
    console.log("\n" + "=".repeat(60))
    console.log("✅ BAŞARILI!")
    console.log("=".repeat(60))
    console.log(`📝 Başlık: ${post.title}`)
    console.log(`🔗 Slug: ${post.slug}`)
    console.log(`🌐 URL: ${BLOG_URL}`)
    console.log(`📅 Tarih: ${post.publishedAt}`)
    console.log("=".repeat(60))
  } catch (error: any) {
    console.error("\n" + "=".repeat(60))
    console.error("❌ HATA!")
    console.error("=".repeat(60))
    console.error(`Hata: ${error.message}`)
    console.error("=".repeat(60))
    process.exit(1)
  }

  await prisma.$disconnect()
}

main().catch(console.error)

