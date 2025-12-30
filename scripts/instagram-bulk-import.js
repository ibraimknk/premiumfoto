#!/usr/bin/env node

/**
 * Instagram İndirilen Dosyaları Toplu Olarak Galeriye Ekleme
 * 
 * Kullanım:
 *   node scripts/instagram-bulk-import.js
 * 
 * Bu script, public/uploads klasöründeki Instagram dosyalarını
 * otomatik olarak veritabanına ekler.
 */

const fs = require('fs').promises;
const path = require('path');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
const UPLOADS_DIR = path.join(process.cwd(), 'public', 'uploads');

async function importInstagramFiles() {
  console.log('📥 Instagram dosyaları galeriye ekleniyor...');
  
  try {
    // Uploads klasöründeki dosyaları listele
    const files = await fs.readdir(UPLOADS_DIR);
    
    // Instagram dosyalarını filtrele
    const instagramFiles = files.filter(file => 
      file.startsWith('instagram-') && 
      (file.endsWith('.jpg') || file.endsWith('.jpeg') || file.endsWith('.png') || file.endsWith('.mp4') || file.endsWith('.mov'))
    );
    
    if (instagramFiles.length === 0) {
      console.log('ℹ️ Instagram dosyası bulunamadı.');
      return;
    }
    
    console.log(`✅ ${instagramFiles.length} Instagram dosyası bulundu`);
    
    let imported = 0;
    let skipped = 0;
    
    for (const file of instagramFiles) {
      const filePath = path.join(UPLOADS_DIR, file);
      const url = `/uploads/${file}`;
      const isVideo = file.endsWith('.mp4') || file.endsWith('.mov');
      
      // Dosyanın zaten veritabanında olup olmadığını kontrol et
      const existing = await prisma.media.findFirst({
        where: { url }
      });
      
      if (existing) {
        console.log(`⏭️  Zaten ekli: ${file}`);
        skipped++;
        continue;
      }
      
      // Veritabanına ekle
      try {
        await prisma.media.create({
          data: {
            title: `Instagram - ${file.replace(/instagram-.*?-/, '').replace(/\.[^.]+$/, '')}`,
            url,
            type: isVideo ? 'video' : 'photo',
            category: 'Instagram',
            thumbnail: isVideo ? url : url,
            isActive: true,
            order: 0,
          },
        });
        
        console.log(`✅ Eklendi: ${file}`);
        imported++;
      } catch (error) {
        console.error(`❌ Hata (${file}):`, error.message);
      }
    }
    
    console.log(`\n🎉 İşlem tamamlandı!`);
    console.log(`   ✅ Eklenen: ${imported}`);
    console.log(`   ⏭️  Atlanan: ${skipped}`);
    
  } catch (error) {
    console.error('❌ Hata:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Script çalıştır
if (require.main === module) {
  importInstagramFiles()
    .then(() => {
      process.exit(0);
    })
    .catch((error) => {
      console.error('❌ İşlem başarısız:', error);
      process.exit(1);
    });
}

module.exports = { importInstagramFiles };

