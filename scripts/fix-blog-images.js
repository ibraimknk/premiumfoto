#!/usr/bin/env node

/**
 * Eski bloglara varsayılan görsel ekleme scripti
 * 
 * Kullanım:
 *   node scripts/fix-blog-images.js
 * 
 * Bu script, görseli olmayan tüm bloglara varsayılan görseli ekler
 */

const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()
const DEFAULT_BLOG_IMAGE = "/uploads/atasehirfotografci.jpg"

async function fixBlogImages() {
  console.log('📝 Blog görselleri kontrol ediliyor...')
  
  // Tüm blogları getir
  const allBlogs = await prisma.blogPost.findMany({
    select: {
      id: true,
      title: true,
      slug: true,
      coverImage: true,
    },
  })
  
  console.log(`📊 Toplam ${allBlogs.length} blog bulundu`)
  
  let fixed = 0
  let skipped = 0
  
  for (const blog of allBlogs) {
    // Görsel yoksa veya boşsa varsayılan görseli ekle
    if (!blog.coverImage || blog.coverImage.trim() === '') {
      await prisma.blogPost.update({
        where: { id: blog.id },
        data: {
          coverImage: DEFAULT_BLOG_IMAGE,
          ogImage: DEFAULT_BLOG_IMAGE,
        },
      })
      fixed++
      console.log(`✅ Düzeltildi: ${blog.title} (${blog.slug})`)
    } else {
      skipped++
      console.log(`⏭️  Atlandı: ${blog.title} (görsel mevcut: ${blog.coverImage})`)
    }
  }
  
  console.log(`\n🎉 İşlem tamamlandı!`)
  console.log(`   ✅ Düzeltilen: ${fixed}`)
  console.log(`   ⏭️  Atlanan: ${skipped}`)
}

// Script çalıştır
if (require.main === module) {
  fixBlogImages()
    .then(() => {
      prisma.$disconnect()
      process.exit(0)
    })
    .catch((error) => {
      console.error('❌ İşlem başarısız:', error)
      prisma.$disconnect()
      process.exit(1)
    })
}

module.exports = { fixBlogImages }

