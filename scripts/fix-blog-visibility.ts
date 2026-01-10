/**
 * Veritabanındaki tüm blog'ları yayınla ve görünür hale getir
 */

import { prisma } from '../lib/prisma'

async function main() {
  console.log("🔍 Veritabanındaki blog'lar kontrol ediliyor...\n")

  try {
    // Tüm blog'ları çek
    const allPosts = await prisma.blogPost.findMany({
      select: {
        id: true,
        title: true,
        slug: true,
        isPublished: true,
        publishedAt: true,
      },
    })

    console.log(`📊 Toplam ${allPosts.length} blog bulundu\n`)

    // Yayınlanmamış veya publishedAt olmayan blog'ları bul
    const unpublishedPosts = allPosts.filter(
      post => !post.isPublished || !post.publishedAt
    )

    console.log(`⚠️  Yayınlanmamış veya publishedAt olmayan: ${unpublishedPosts.length}\n`)

    if (unpublishedPosts.length === 0) {
      console.log("✅ Tüm blog'lar zaten yayınlanmış!")
      return
    }

    // Sorunlu blog'ları listele
    console.log("📋 Sorunlu blog'lar:\n")
    unpublishedPosts.forEach((post, index) => {
      const issues: string[] = []
      if (!post.isPublished) issues.push("isPublished = false")
      if (!post.publishedAt) issues.push("publishedAt = NULL")
      
      console.log(`${index + 1}. ${post.title}`)
      console.log(`   Slug: ${post.slug}`)
      console.log(`   Sorunlar: ${issues.join(", ")}\n`)
    })

    // Onay al
    console.log("=".repeat(60))
    console.log("🔧 Bu blog'ları yayınlamak istiyor musunuz?")
    console.log("   (Otomatik olarak isPublished = true ve publishedAt = şimdi olarak ayarlanacak)")
    console.log("=".repeat(60))

    // Şimdilik otomatik olarak düzelt (sunucuda çalıştırmak için)
    // Gerçek kullanımda confirm() eklenebilir

    // Tüm blog'ları yayınla
    const now = new Date()
    let updatedCount = 0

    for (const post of unpublishedPosts) {
      try {
        await prisma.blogPost.update({
          where: { id: post.id },
          data: {
            isPublished: true,
            publishedAt: post.publishedAt || now,
          },
        })
        console.log(`✅ Güncellendi: ${post.title}`)
        updatedCount++
      } catch (error: any) {
        console.error(`❌ Hata (${post.title}): ${error.message}`)
      }
    }

    console.log("\n" + "=".repeat(60))
    console.log("📊 SONUÇLAR")
    console.log("=".repeat(60))
    console.log(`✅ Güncellenen blog sayısı: ${updatedCount}`)
    console.log(`❌ Hata alan blog sayısı: ${unpublishedPosts.length - updatedCount}\n`)

    // Kontrol et
    const finalCheck = await prisma.blogPost.findMany({
      where: { isPublished: true },
      select: { id: true },
    })

    console.log(`📊 Şu anda yayınlanan blog sayısı: ${finalCheck.length}`)

  } catch (error: any) {
    console.error("❌ Genel hata:", error.message)
    if (error.code === 'P2001') {
      console.error("💡 Veritabanı bağlantı hatası. DATABASE_URL kontrol edin.")
    }
  } finally {
    await prisma.$disconnect()
  }
}

// Script'i çalıştır
main().catch(console.error)

