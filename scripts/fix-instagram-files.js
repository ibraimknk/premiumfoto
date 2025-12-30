#!/usr/bin/env node

/**
 * Instagram indirilen dosyaları düzeltme scripti
 * 
 * Kullanım:
 *   node scripts/fix-instagram-files.js dugunkaremcom
 * 
 * Bu script, temp klasöründeki dosyaları public/uploads klasörüne taşır
 * ve veritabanındaki kayıtları günceller.
 */

const fs = require('fs').promises
const path = require('path')
const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient()
const UPLOADS_DIR = path.join(process.cwd(), 'public', 'uploads')

async function fixInstagramFiles(username) {
  console.log(`📥 Instagram dosyaları düzeltiliyor: @${username}`)
  
  const tempDir = path.join(UPLOADS_DIR, `instagram-${username}-temp`)
  
  // Temp klasörü var mı kontrol et
  try {
    await fs.access(tempDir)
  } catch {
    console.log(`❌ Temp klasörü bulunamadı: ${tempDir}`)
    return
  }
  
  // Recursive dosya tarama
  const getAllFiles = async (dir, basePath = '') => {
    const files = []
    try {
      const entries = await fs.readdir(dir, { withFileTypes: true })
      for (const entry of entries) {
        const fullPath = path.join(dir, entry.name)
        const relativePath = basePath ? path.join(basePath, entry.name) : entry.name
        
        if (entry.isDirectory()) {
          const subFiles = await getAllFiles(fullPath, relativePath)
          files.push(...subFiles)
        } else {
          files.push(relativePath)
        }
      }
    } catch (error) {
      console.error(`Error scanning directory ${dir}:`, error)
    }
    return files
  }
  
  const allFiles = await getAllFiles(tempDir)
  
  // Sadece görsel dosyalarını filtrele
  const imageFiles = allFiles.filter(file => 
    file.endsWith('.jpg') || file.endsWith('.jpeg') || file.endsWith('.png')
  )
  
  console.log(`✅ ${imageFiles.length} görsel dosyası bulundu`)
  
  if (imageFiles.length === 0) {
    console.log('ℹ️ İşlenecek dosya yok')
    return
  }
  
  let copied = 0
  let updated = 0
  let errors = 0
  
  for (const file of imageFiles) {
    try {
      const sourcePath = path.join(tempDir, file)
      const fileName = file.includes('/') ? file.split('/').pop() : file
      const timestamp = Date.now()
      const randomStr = Math.random().toString(36).substring(7)
      const newFileName = `instagram-${username}-${timestamp}-${randomStr}-${fileName}`
      const targetPath = path.join(UPLOADS_DIR, newFileName)
      
      // Dosyayı kopyala
      await fs.copyFile(sourcePath, targetPath)
      copied++
      
      // Veritabanında bu dosya için kayıt var mı kontrol et
      const url = `/uploads/${newFileName}`
      const existing = await prisma.media.findFirst({
        where: {
          url: {
            contains: fileName
          }
        }
      })
      
      if (existing) {
        // Mevcut kaydı güncelle
        await prisma.media.update({
          where: { id: existing.id },
          data: { url }
        })
        updated++
        console.log(`✅ Güncellendi: ${fileName}`)
      } else {
        // Yeni kayıt oluştur
        await prisma.media.create({
          data: {
            title: `Instagram - ${username}`,
            url,
            type: 'photo',
            category: 'Instagram',
            thumbnail: url,
            isActive: true,
            order: 0,
          },
        })
        updated++
        console.log(`✅ Eklendi: ${fileName}`)
      }
    } catch (error) {
      errors++
      console.error(`❌ Hata (${file}):`, error.message)
    }
  }
  
  console.log(`\n🎉 İşlem tamamlandı!`)
  console.log(`   ✅ Kopyalanan: ${copied}`)
  console.log(`   ✅ Güncellenen/Eklenen: ${updated}`)
  console.log(`   ❌ Hatalar: ${errors}`)
  
  // Temp klasörünü temizle
  try {
    await fs.rm(tempDir, { recursive: true, force: true })
    console.log(`🗑️ Temp klasörü temizlendi`)
  } catch (error) {
    console.warn(`⚠️ Temp klasörü temizlenemedi: ${error.message}`)
  }
}

// Script çalıştır
if (require.main === module) {
  const username = process.argv[2] || 'dugunkaremcom'
  
  fixInstagramFiles(username)
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

module.exports = { fixInstagramFiles }

