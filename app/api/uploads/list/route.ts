// Yüklenen fotoğrafları listeleyen API endpoint
import { NextResponse } from "next/server"
import { readdir } from "fs/promises"
import { join } from "path"
import { existsSync } from "fs"

export const dynamic = 'force-dynamic'

export async function GET() {
  try {
    const uploadDir = join(process.cwd(), "public", "uploads")
    
    if (!existsSync(uploadDir)) {
      return NextResponse.json({ files: [] })
    }

    const files = await readdir(uploadDir)
    
    // Sadece resim dosyalarını filtrele
    const imageFiles = files.filter(file => {
      const ext = file.toLowerCase().split('.').pop()
      return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(ext || '')
    })

    // Dosya bilgilerini oluştur
    const images = imageFiles.map(file => ({
      name: file,
      url: `/uploads/${file}`,
      fullUrl: `https://fotougur.com.tr/uploads/${file}`
    }))

    // Tarihe göre sırala (en yeni önce)
    images.sort((a, b) => {
      const aTime = parseInt(a.name.split('-')[0]) || 0
      const bTime = parseInt(b.name.split('-')[0]) || 0
      return bTime - aTime
    })

    return NextResponse.json({ 
      success: true,
      images,
      count: images.length
    })
  } catch (error: any) {
    console.error("List uploads error:", error)
    return NextResponse.json(
      { 
        success: false,
        error: error.message || "Dosyalar listelenemedi",
        images: []
      },
      { status: 500 }
    )
  }
}

