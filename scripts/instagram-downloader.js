#!/usr/bin/env node

/**
 * Instagram Profil İçerik İndirici
 * 
 * Kullanım:
 *   node scripts/instagram-downloader.js dugunkaremcom
 * 
 * Gereksinimler:
 *   npm install puppeteer
 * 
 * Not: Instagram'ın ToS'una göre web scraping yapmak yasak olabilir.
 * Bu script sadece eğitim amaçlıdır. Kullanım sorumluluğu size aittir.
 */

const puppeteer = require('puppeteer');
const fs = require('fs').promises;
const path = require('path');
const https = require('https');
const http = require('http');

const INSTAGRAM_USERNAME = process.argv[2] || 'dugunkaremcom';
const OUTPUT_DIR = path.join(process.cwd(), 'public', 'uploads');

async function downloadFile(url, filepath) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    const file = require('fs').createWriteStream(filepath);
    
    protocol.get(url, (response) => {
      if (response.statusCode === 301 || response.statusCode === 302) {
        // Redirect takip et
        return downloadFile(response.headers.location, filepath)
          .then(resolve)
          .catch(reject);
      }
      
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve(filepath);
      });
    }).on('error', (err) => {
      fs.unlink(filepath).catch(() => {});
      reject(err);
    });
  });
}

async function downloadInstagramProfile(username) {
  console.log(`📥 Instagram profilinden içerikler indiriliyor: @${username}`);
  
  // Output klasörünü oluştur
  await fs.mkdir(OUTPUT_DIR, { recursive: true });
  
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  try {
    const page = await browser.newPage();
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
    
    // Instagram profil sayfasına git
    const profileUrl = `https://www.instagram.com/${username}/`;
    console.log(`🌐 Profil sayfasına gidiliyor: ${profileUrl}`);
    
    await page.goto(profileUrl, { waitUntil: 'networkidle2', timeout: 30000 });
    
    // Sayfayı scroll ederek tüm içerikleri yükle
    console.log('📜 Sayfa kaydırılıyor, içerikler yükleniyor...');
    
    let previousHeight = 0;
    let scrollAttempts = 0;
    const maxScrollAttempts = 10; // Maksimum scroll sayısı
    
    while (scrollAttempts < maxScrollAttempts) {
      previousHeight = await page.evaluate('document.body.scrollHeight');
      await page.evaluate('window.scrollTo(0, document.body.scrollHeight)');
      await page.waitForTimeout(2000); // 2 saniye bekle
      
      const newHeight = await page.evaluate('document.body.scrollHeight');
      if (newHeight === previousHeight) {
        break; // Daha fazla içerik yok
      }
      scrollAttempts++;
    }
    
    // Tüm görsel ve video URL'lerini çek
    console.log('🔍 İçerikler bulunuyor...');
    
    const mediaUrls = await page.evaluate(() => {
      const images = [];
      const videos = [];
      
      // Görselleri bul
      document.querySelectorAll('img').forEach(img => {
        const src = img.src || img.getAttribute('srcset')?.split(' ')[0];
        if (src && src.includes('instagram.com') && !images.includes(src)) {
          images.push(src);
        }
      });
      
      // Videoları bul
      document.querySelectorAll('video').forEach(video => {
        const src = video.src || video.getAttribute('poster');
        if (src && src.includes('instagram.com') && !videos.includes(src)) {
          videos.push(src);
        }
      });
      
      return { images, videos };
    });
    
    console.log(`✅ ${mediaUrls.images.length} görsel, ${mediaUrls.videos.length} video bulundu`);
    
    // Dosyaları indir
    const downloadedFiles = [];
    
    for (let i = 0; i < mediaUrls.images.length; i++) {
      const url = mediaUrls.images[i];
      const extension = url.includes('.jpg') ? '.jpg' : '.png';
      const filename = `instagram-${username}-${Date.now()}-${i}${extension}`;
      const filepath = path.join(OUTPUT_DIR, filename);
      
      try {
        console.log(`📥 İndiriliyor: ${i + 1}/${mediaUrls.images.length} - ${filename}`);
        await downloadFile(url, filepath);
        downloadedFiles.push({
          url: `/uploads/${filename}`,
          type: 'photo',
          filename
        });
      } catch (error) {
        console.error(`❌ İndirme hatası: ${filename} - ${error.message}`);
      }
    }
    
    for (let i = 0; i < mediaUrls.videos.length; i++) {
      const url = mediaUrls.videos[i];
      const filename = `instagram-${username}-${Date.now()}-video-${i}.mp4`;
      const filepath = path.join(OUTPUT_DIR, filename);
      
      try {
        console.log(`📥 İndiriliyor: ${i + 1}/${mediaUrls.videos.length} - ${filename}`);
        await downloadFile(url, filepath);
        downloadedFiles.push({
          url: `/uploads/${filename}`,
          type: 'video',
          filename
        });
      } catch (error) {
        console.error(`❌ İndirme hatası: ${filename} - ${error.message}`);
      }
    }
    
    console.log(`\n✅ Toplam ${downloadedFiles.length} dosya indirildi!`);
    console.log(`📁 Dosyalar: ${OUTPUT_DIR}`);
    
    // İndirilen dosyaların listesini JSON olarak kaydet
    const listFile = path.join(OUTPUT_DIR, `instagram-${username}-list.json`);
    await fs.writeFile(listFile, JSON.stringify(downloadedFiles, null, 2));
    console.log(`📋 Dosya listesi kaydedildi: ${listFile}`);
    
    return downloadedFiles;
    
  } catch (error) {
    console.error('❌ Hata:', error);
    throw error;
  } finally {
    await browser.close();
  }
}

// Script çalıştır
if (require.main === module) {
  downloadInstagramProfile(INSTAGRAM_USERNAME)
    .then((files) => {
      console.log('\n🎉 İşlem tamamlandı!');
      console.log(`\n💡 Şimdi admin panelinden bu dosyaları galeriye ekleyebilirsiniz:`);
      console.log(`   /admin/gallery`);
      process.exit(0);
    })
    .catch((error) => {
      console.error('\n❌ İşlem başarısız:', error);
      process.exit(1);
    });
}

module.exports = { downloadInstagramProfile };

