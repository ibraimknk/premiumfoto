#!/usr/bin/env node

/**
 * Uploads klasörü ve görsellerin durumunu kontrol eden script
 * 
 * Kullanım:
 *   node scripts/check-uploads-status.js
 */

const fs = require('fs')
const path = require('path')
const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()
const UPLOADS_DIR = path.join(process.cwd(), 'public', 'uploads')

async function checkUploadsStatus() {
  console.log('🔍 Uploads klasörü ve görseller kontrol ediliyor...\n')
  
  // 1. Klasör var mı?
  console.log('1️⃣ Klasör Kontrolü:')
  if (!fs.existsSync(UPLOADS_DIR)) {
    console.log('   ❌ Uploads klasörü bulunamadı!')
    console.log(`   📁 Oluşturulacak: ${UPLOADS_DIR}`)
    return
  }
  console.log(`   ✅ Klasör var: ${UPLOADS_DIR}`)
  
  // 2. İzinler
  console.log('\n2️⃣ İzin Kontrolü:')
  try {
    const stats = fs.statSync(UPLOADS_DIR)
    const mode = stats.mode.toString(8).slice(-3)
    console.log(`   📋 Klasör izinleri: ${mode}`)
    if (mode !== '755' && mode !== '775') {
      console.log('   ⚠️ İzinler ideal değil (755 veya 775 olmalı)')
    } else {
      console.log('   ✅ İzinler OK')
    }
  } catch (error) {
    console.log(`   ❌ İzin kontrolü başarısız: ${error.message}`)
  }
  
  // 3. Dosyalar
  console.log('\n3️⃣ Dosya Kontrolü:')
  try {
    const files = fs.readdirSync(UPLOADS_DIR)
    const imageFiles = files.filter(f => 
      f.endsWith('.jpg') || f.endsWith('.jpeg') || f.endsWith('.png') || f.endsWith('.webp')
    )
    console.log(`   📊 Toplam dosya: ${files.length}`)
    console.log(`   🖼️ Görsel dosyası: ${imageFiles.length}`)
    
    if (imageFiles.length > 0) {
      console.log('\n   📋 İlk 5 dosya:')
      imageFiles.slice(0, 5).forEach((file, i) => {
        const filePath = path.join(UPLOADS_DIR, file)
        const stats = fs.statSync(filePath)
        const sizeKB = (stats.size / 1024).toFixed(2)
        const mode = stats.mode.toString(8).slice(-3)
        console.log(`      ${i + 1}. ${file} (${sizeKB} KB, izin: ${mode})`)
      })
    } else {
      console.log('   ⚠️ Görsel dosyası bulunamadı!')
    }
  } catch (error) {
    console.log(`   ❌ Dosya okuma hatası: ${error.message}`)
  }
  
  // 4. Veritabanı kayıtları
  console.log('\n4️⃣ Veritabanı Kontrolü:')
  try {
    const allMedia = await prisma.media.findMany({
      where: { category: 'Instagram' },
      select: { id: true, url: true, title: true },
    })
    
    console.log(`   📊 Instagram kayıt sayısı: ${allMedia.length}`)
    
    if (allMedia.length > 0) {
      let foundCount = 0
      let notFoundCount = 0
      
      console.log('\n   📋 İlk 5 kayıt kontrolü:')
      for (let i = 0; i < Math.min(5, allMedia.length); i++) {
        const media = allMedia[i]
        const urlPath = media.url.replace('/uploads/', '')
        const filePath = path.join(UPLOADS_DIR, urlPath)
        const exists = fs.existsSync(filePath)
        
        if (exists) {
          foundCount++
          console.log(`      ✅ ${i + 1}. ${urlPath} - BULUNDU`)
        } else {
          notFoundCount++
          console.log(`      ❌ ${i + 1}. ${urlPath} - BULUNAMADI`)
          
          // Benzer dosya ara
          const files = fs.readdirSync(UPLOADS_DIR)
          const similar = files.filter(f => f.includes(urlPath.split('-').pop() || ''))
          if (similar.length > 0) {
            console.log(`         💡 Benzer dosya bulundu: ${similar[0]}`)
          }
        }
      }
      
      console.log(`\n   📊 Özet: ${foundCount} bulundu, ${notFoundCount} bulunamadı`)
    }
  } catch (error) {
    console.log(`   ❌ Veritabanı hatası: ${error.message}`)
  }
  
  // 5. Nginx config kontrolü
  console.log('\n5️⃣ Nginx Config Kontrolü:')
  console.log('   ℹ️ Nginx config dosyasını manuel kontrol edin:')
  console.log('      sudo cat /etc/nginx/sites-available/foto-ugur | grep -A 3 "location /uploads"')
  console.log('   📋 Doğru path: /home/ibrahim/premiumfoto/public/uploads/')
  
  // 6. Öneriler
  console.log('\n💡 Öneriler:')
  console.log('   1. İzinleri düzelt: bash scripts/fix-uploads-permissions.sh')
  console.log('   2. Veritabanı URL\'lerini düzelt: node scripts/fix-instagram-db-urls.js')
  console.log('   3. Nginx config\'i kontrol et ve güncelle')
  console.log('   4. Nginx\'i reload et: sudo systemctl reload nginx')
}

// Script çalıştır
if (require.main === module) {
  checkUploadsStatus()
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

module.exports = { checkUploadsStatus }

