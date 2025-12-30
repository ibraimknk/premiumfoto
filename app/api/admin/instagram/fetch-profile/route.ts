import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { exec } from "child_process"
import { promisify } from "util"
import { writeFile, mkdir, readdir, copyFile, rm } from "fs/promises"
import { join } from "path"
import { existsSync } from "fs"

const execAsync = promisify(exec)

export const dynamic = 'force-dynamic'

// Instagram profilinden tüm gönderileri çek ve galeriye ekle
export async function POST(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = await request.json()
    const { profileUrl, username } = body

    if (!profileUrl && !username) {
      return NextResponse.json({ error: "Instagram profil URL'si veya kullanıcı adı gerekli" }, { status: 400 })
    }

    // Kullanıcı adını çıkar
    let instagramUsername = username
    if (!instagramUsername && profileUrl) {
      const usernameMatch = profileUrl.match(/instagram\.com\/([^\/\?]+)/)
      if (usernameMatch) {
        instagramUsername = usernameMatch[1].replace(/\/$/, '')
      }
    }

    if (!instagramUsername) {
      return NextResponse.json({ 
        error: "Geçersiz Instagram profil URL'si. Örnek: https://www.instagram.com/dugunkaremcom/ veya dugunkaremcom" 
      }, { status: 400 })
    }

    instagramUsername = instagramUsername.replace(/^@/, '').replace(/\/$/, '')

    // Instaloader ile Instagram içeriklerini indir
    // Not: Bu için sunucuda Python ve Instaloader kurulu olmalı
    try {
      console.log(`Instagram içerikleri indiriliyor: @${instagramUsername}`)
      
      // Uploads klasörünü oluştur
      const uploadDir = join(process.cwd(), "public", "uploads")
      if (!existsSync(uploadDir)) {
        await mkdir(uploadDir, { recursive: true })
      }

      // Instaloader komutunu çalıştır
      // --no-videos: Sadece görselleri indir (videoları atla - opsiyonel)
      // --no-captions: Caption'ları indirme
      // --no-metadata-json: Metadata JSON dosyalarını indirme
      // --no-profile-pic: Profil fotoğrafını indirme
      // --dirname-pattern: İndirme klasörü
      const tempDir = join(uploadDir, `instagram-${instagramUsername}-temp`)
      
           // Instaloader'ı bul (pipx, virtual env, sistem PATH)
           const homeDir = process.env.HOME || '/home/ibrahim'
           
           // Önce .local/bin'de kontrol et (en yaygın konum)
           const localBinPath = join(homeDir, '.local', 'bin', 'instaloader')
           let instaloaderCmd = 'instaloader'
           
           if (existsSync(localBinPath)) {
             instaloaderCmd = localBinPath
             console.log(`✅ Instaloader bulundu (.local/bin): ${instaloaderCmd}`)
           } else {
             // Alternatif yolları dene
             const instaloaderPaths = [
               join(homeDir, 'instagram-env', 'bin', 'instaloader'), // virtual env
               '/usr/local/bin/instaloader',
               '/usr/bin/instaloader',
             ]
             
             for (const path of instaloaderPaths) {
               if (existsSync(path)) {
                 instaloaderCmd = path
                 console.log(`✅ Instaloader bulundu (alternatif): ${instaloaderCmd}`)
                 break
               }
             }
             
             // Son olarak which/command -v ile sistem PATH'te ara
             if (instaloaderCmd === 'instaloader') {
               try {
                 const { stdout } = await execAsync('which instaloader 2>/dev/null || command -v instaloader 2>/dev/null', { 
                   timeout: 2000,
                   env: { ...process.env, PATH: `${join(homeDir, '.local', 'bin')}:${process.env.PATH || ''}` }
                 })
                 if (stdout.trim()) {
                   instaloaderCmd = stdout.trim()
                   console.log(`✅ Instaloader bulundu (PATH): ${instaloaderCmd}`)
                 }
               } catch (error) {
                 console.warn('Instaloader PATH\'te bulunamadı:', error)
               }
             }
           }
           
           // Eğer hala bulunamadıysa hata ver
           if (instaloaderCmd === 'instaloader' && !existsSync(localBinPath)) {
             console.error('❌ Instaloader bulunamadı!')
             return NextResponse.json({
               success: false,
               message: "Instaloader bulunamadı. Lütfen sunucuda kurun.",
               instructions: [
                 "1. npm run install-instaloader komutunu çalıştırın",
                 "2. VEYA manuel: pipx install instaloader",
                 "3. PM2'yi restart edin: pm2 restart foto-ugur-app --update-env"
               ],
               alternative: "Alternatif olarak, Instagram içeriklerini manuel olarak indirip toplu yükleme özelliğini kullanabilirsiniz."
             }, { status: 500 })
           }
      
           // PATH'e .local/bin ekle (eğer yoksa)
           const env = {
             ...process.env,
             PATH: `${join(homeDir, '.local', 'bin')}:${process.env.PATH || ''}`,
           }
           
           const command = `${instaloaderCmd} --no-videos --no-captions --no-metadata-json --no-profile-pic --dirname-pattern="${tempDir}" ${instagramUsername}`
           
           console.log(`📥 Instaloader komutu: ${command}`)
           console.log(`📁 Temp dizini: ${tempDir}`)
           console.log(`🔧 Environment PATH: ${env.PATH}`)
           
           let stdout = ''
           let stderr = ''
           
           try {
             const result = await execAsync(command, {
               cwd: process.cwd(),
               env: env,
               timeout: 600000, // 10 dakika timeout (çok sayıda görsel için)
             })
             stdout = result.stdout || ''
             stderr = result.stderr || ''
             
             console.log('✅ Instaloader çıktısı:', stdout)
             if (stderr) {
               console.warn('⚠️ Instaloader uyarıları:', stderr)
               // 403 hatası olsa bile indirilen dosyalar varsa devam et
             }
           } catch (execError: any) {
             console.error('❌ Instaloader çalıştırma hatası:', execError)
             console.error('   Hata kodu:', execError.code)
             console.error('   Hata mesajı:', execError.message)
             console.error('   stdout:', execError.stdout || '')
             console.error('   stderr:', execError.stderr || '')
             
             // Hata olsa bile tempDir var mı kontrol et (bazı dosyalar indirilmiş olabilir)
             if (!existsSync(tempDir)) {
               return NextResponse.json({
                 success: false,
                 message: `Instaloader çalıştırılamadı: ${execError.message || execError.code || 'Bilinmeyen hata'}`,
                 error: execError.message || String(execError),
                 code: execError.code,
                 instructions: [
                   "1. Instaloader'ın çalıştığını kontrol edin: instaloader --version",
                   "2. Python bağımlılıklarını kontrol edin: pip3 list | grep instaloader",
                   "3. Manuel test: instaloader --no-videos USERNAME",
                   "4. Alternatif: Instagram içeriklerini manuel olarak indirip toplu yükleme özelliğini kullanın"
                 ]
               }, { status: 500 })
             }
             
             // TempDir varsa devam et (bazı dosyalar indirilmiş olabilir)
             console.warn('⚠️ Instaloader hatası ama tempDir mevcut, devam ediliyor...')
             stderr = execError.stderr || execError.message || ''
           }

      // İndirilen dosyaları bul ve veritabanına ekle
      // 403 hatası olsa bile indirilen dosyalar varsa işle
      if (!existsSync(tempDir)) {
        return NextResponse.json({
          success: false,
          message: "Dosyalar indirilemedi. Instaloader kurulu olmayabilir veya profil bulunamadı.",
          instructions: [
            "1. Sunucuda Python kurulu olmalı: python3 --version",
            "2. Instaloader kurun: pip3 install instaloader",
            "3. Alternatif: Instagram içeriklerini manuel olarak indirip toplu yükleme özelliğini kullanın"
          ]
        })
      }

      // Recursive dosya tarama (alt klasörleri de kontrol et)
      const getAllFiles = async (dir: string, basePath: string = ''): Promise<string[]> => {
        const files: string[] = []
        try {
          const entries = await readdir(dir, { withFileTypes: true })
          for (const entry of entries) {
            const fullPath = join(dir, entry.name)
            const relativePath = basePath ? join(basePath, entry.name) : entry.name
            
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
      const imageFiles = allFiles.filter((file: string) => 
        file.endsWith('.jpg') || file.endsWith('.jpeg') || file.endsWith('.png')
      )
      
      console.log(`Toplam ${allFiles.length} dosya bulundu, ${imageFiles.length} görsel dosyası`)

      if (imageFiles.length === 0) {
        // Geçici klasörü temizle
        await rm(tempDir, { recursive: true, force: true })
        return NextResponse.json({
          success: false,
          message: "İndirilen görsel dosyası bulunamadı",
        })
      }

      // Dosyaları public/uploads klasörüne taşı ve veritabanına ekle
      let imported = 0

      for (const file of imageFiles) {
        try {
          // Dosya yolu düzelt (alt klasörler için)
          const filePath = file.includes('/') ? file : file
          const sourcePath = join(tempDir, filePath)
          
          // Dosya var mı kontrol et
          if (!existsSync(sourcePath)) {
            console.warn(`Dosya bulunamadı: ${sourcePath}`)
            continue
          }
          
          // Dosya adını temizle (sadece dosya adını al, klasör yolunu kaldır)
          const fileName = file.includes('/') ? file.split('/').pop() || file : file
          const timestamp = Date.now()
          const randomStr = Math.random().toString(36).substring(7)
          const newFileName = `instagram-${instagramUsername}-${timestamp}-${randomStr}-${fileName}`
          const targetPath = join(uploadDir, newFileName)
          
          // Dosyayı kopyala
          await copyFile(sourcePath, targetPath)
          
          // Dosyanın kopyalandığını doğrula
          if (!existsSync(targetPath)) {
            console.warn(`Dosya kopyalanamadı: ${targetPath}`)
            continue
          }
          
          // URL oluştur
          const url = `/uploads/${newFileName}`
          
          // Veritabanına ekle
          await prisma.media.create({
            data: {
              title: `Instagram - ${instagramUsername}`,
              url,
              type: "photo",
              category: "Instagram",
              thumbnail: url,
              isActive: true,
              order: 0,
            },
          })
          
          imported++
          console.log(`✅ İşlendi: ${fileName} (${imported}/${imageFiles.length})`)
        } catch (error: any) {
          console.error(`❌ Hata (${file}):`, error.message)
          continue
        }
      }

      // Geçici klasörü temizle
      await rm(tempDir, { recursive: true, force: true })

      return NextResponse.json({
        success: true,
        message: `${imported} içerik başarıyla indirildi ve galeriye eklendi`,
        imported,
        username: instagramUsername,
      })

    } catch (error: any) {
      // Instaloader kurulu değilse veya hata varsa
      if (error.code === 'ENOENT' || error.message?.includes('instaloader') || error.message?.includes('command not found')) {
        return NextResponse.json({
          success: false,
          message: "Instaloader bulunamadı. Lütfen sunucuda kurun.",
          instructions: [
            "1. pipx kur: sudo apt install pipx -y",
            "2. pipx ensurepath",
            "3. pipx install instaloader",
            "4. Alternatif: pip3 install --break-system-packages instaloader",
            "5. Alternatif: Instagram içeriklerini manuel olarak indirip toplu yükleme özelliğini kullanın"
          ],
          alternative: "Alternatif olarak, Instagram içeriklerini manuel olarak indirip toplu yükleme özelliğini kullanabilirsiniz."
        }, { status: 500 })
      }

      console.error("Instagram download error:", error)
      
      // Hata mesajını güvenli hale getir
      const errorMessage = error.message || String(error) || "İçerikler indirilemedi"
      
      return NextResponse.json({
        success: false,
        message: errorMessage,
        error: errorMessage,
        code: error.code,
      }, { status: 500 })
    }

  } catch (error: any) {
    console.error("Instagram profile fetch error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}
