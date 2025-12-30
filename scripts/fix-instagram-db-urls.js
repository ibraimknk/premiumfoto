#!/usr/bin/env node

/**
 * Instagram veritabanı URL'lerini düzeltme scripti
 * 
 * Kullanım:
 *   node scripts/fix-instagram-db-urls.js
 * 
 * Bu script, veritabanındaki Instagram kayıtlarını kontrol edip
 * gerçek dosya adlarıyla eşleştirir.
 */

const fs = require('fs').promises
const path = require('path')
const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()
const UPLOADS_DIR = path.join(process.cwd(), 'public', 'uploads')

async function fixInstagramDbUrls() {
  console.log('📥 Instagram veritabanı URL\'leri düzeltiliyor...')
  
  // Uploads klasöründeki Instagram dosyalarını listele
  const files = await fs.readdir(UPLOADS_DIR)
  const instagramFiles = files.filter(file => 
    file.startsWith('instagram-') && 
    (file.endsWith('.jpg') || file.endsWith('.jpeg') || file.endsWith('.png'))
  )
  
  console.log(`✅ ${instagramFiles.length} Instagram dosyası bulundu`)
  
  if (instagramFiles.length === 0) {
    console.log('ℹ️ İşlenecek dosya yok')
    return
  }
  
  // Veritabanındaki Instagram kayıtlarını getir
  const dbRecords = await prisma.media.findMany({
    where: {
      category: 'Instagram',
    },
  })
  
  console.log(`📋 Veritabanında ${dbRecords.length} Instagram kaydı bulundu`)
  
  let fixed = 0
  let notFound = 0
  
  // Her veritabanı kaydı için dosyayı bul ve URL'yi düzelt
  for (const record of dbRecords) {
    try {
      // URL'den dosya adını çıkar
      const urlFileName = record.url.replace('/uploads/', '')
      
      // Dosya var mı kontrol et
      const filePath = path.join(UPLOADS_DIR, urlFileName)
      try {
        await fs.access(filePath)
        // Dosya var, URL doğru
        continue
      } catch {
        // Dosya yok, dosya adından eşleşen dosyayı bul
        // Dosya adı formatı: instagram-{username}-{timestamp}-{random}-{originalName}
        // Orijinal dosya adını çıkar (son kısımdan)
        const parts = urlFileName.split('-')
        if (parts.length < 5) continue
        
        // Orijinal dosya adını bul (son kısım)
        const originalFileName = parts.slice(4).join('-') // 2019-05-25_15-15-54_UTC.jpg gibi
        
        // Bu dosya adını içeren dosyayı bul
        const matchingFile = instagramFiles.find(file => file.includes(originalFileName))
        
        if (matchingFile) {
          // URL'yi güncelle
          const newUrl = `/uploads/${matchingFile}`
          await prisma.media.update({
            where: { id: record.id },
            data: { 
              url: newUrl,
              thumbnail: newUrl,
            },
          })
          fixed++
          console.log(`✅ Düzeltildi: ${urlFileName} -> ${matchingFile}`)
        } else {
          notFound++
          console.log(`⚠️ Eşleşen dosya bulunamadı: ${urlFileName}`)
        }
      }
    } catch (error) {
      console.error(`❌ Hata (${record.id}):`, error.message)
    }
  }
  
  console.log(`\n🎉 İşlem tamamlandı!`)
  console.log(`   ✅ Düzeltilen: ${fixed}`)
  console.log(`   ⚠️ Bulunamayan: ${notFound}`)
}

// Script çalıştır
if (require.main === module) {
  fixInstagramDbUrls()
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

module.exports = { fixInstagramDbUrls }

