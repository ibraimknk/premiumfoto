/**
 * Veritabanındaki mevcut blog'ları kontrol et ve liste
 */

import { prisma } from '../lib/prisma'

async function main() {
  console.log("🔍 Veritabanındaki blog'lar kontrol ediliyor...\n")

  try {
    // Tüm blog'ları çek
    const posts = await prisma.blogPost.findMany({
      select: {
        id: true,
        title: true,
        slug: true,
        isPublished: true,
        publishedAt: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    })

    console.log(`📊 Toplam ${posts.length} blog bulundu\n`)
    console.log("=".repeat(80))

    if (posts.length === 0) {
      console.log("❌ Veritabanında blog bulunamadı!")
      return
    }

    // Yayınlanan ve yayınlanmayan blog'ları ayır
    const published = posts.filter(p => p.isPublished)
    const unpublished = posts.filter(p => !p.isPublished)

    console.log(`✅ Yayınlanan: ${published.length}`)
    console.log(`⚠️  Yayınlanmayan: ${unpublished.length}\n`)

    // Tüm blog'ları listele
    console.log("📋 Tüm Blog'lar:\n")
    posts.forEach((post, index) => {
      const status = post.isPublished ? "✅" : "⚠️"
      const publishedDate = post.publishedAt 
        ? new Date(post.publishedAt).toLocaleDateString('tr-TR')
        : "Yayınlanmamış"
      
      console.log(`${index + 1}. ${status} ${post.title}`)
      console.log(`   Slug: ${post.slug}`)
      console.log(`   Yayın Tarihi: ${publishedDate}`)
      console.log(`   Oluşturma: ${new Date(post.createdAt).toLocaleDateString('tr-TR')}`)
      console.log(`   ID: ${post.id}`)
      console.log("")
    })

    // Slug'ları listele (URL'ler için)
    console.log("=".repeat(80))
    console.log("📝 Slug Listesi (URL karşılaştırması için):\n")
    posts.forEach(post => {
      console.log(`https://fotougur.com.tr/blog/${post.slug}`)
    })

    // Slug'ları Set olarak döndür
    const slugs = new Set(posts.map(p => p.slug))
    console.log("\n" + "=".repeat(80))
    console.log(`📊 Toplam ${slugs.size} benzersiz slug\n`)

    // CSV formatında export etmek ister misiniz?
    console.log("💡 İpucu: Slug'ları dosyaya kaydetmek için:")
    console.log('   node -e "require(\'./scripts/check-database-blogs.ts\').then(() => process.exit(0))" > blog-slugs.txt')

  } catch (error: any) {
    console.error("❌ Veritabanı okuma hatası:", error.message)
    if (error.code === 'P2001') {
      console.error("💡 Veritabanı bağlantı hatası. DATABASE_URL kontrol edin.")
    }
  } finally {
    await prisma.$disconnect()
  }
}

// Script'i çalıştır
main().catch(console.error)

