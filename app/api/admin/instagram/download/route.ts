import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { writeFile, mkdir } from "fs/promises"
import { join } from "path"
import { existsSync } from "fs"

export const dynamic = 'force-dynamic'

// Instagram'dan görsel/video URL'lerini indirip galeriye ekle
// Bu endpoint, dışarıdan indirilmiş dosyaların URL'lerini alır ve sunucuya kaydeder
export async function POST(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = await request.json()
    const { mediaUrls, category = "Instagram" } = body

    if (!mediaUrls || !Array.isArray(mediaUrls) || mediaUrls.length === 0) {
      return NextResponse.json({ error: "Media URL'leri gerekli" }, { status: 400 })
    }

    const uploadDir = join(process.cwd(), "public", "uploads")
    
    // Uploads klasörünü oluştur
    if (!existsSync(uploadDir)) {
      await mkdir(uploadDir, { recursive: true })
    }

    const importedMedia = []

    for (const mediaUrl of mediaUrls) {
      try {
        // URL'den dosyayı indir
        const response = await fetch(mediaUrl)
        if (!response.ok) {
          console.error(`Failed to download ${mediaUrl}: ${response.statusText}`)
          continue
        }

        // Content-Type'dan dosya tipini belirle
        const contentType = response.headers.get("content-type") || ""
        const isVideo = contentType.startsWith("video/")
        const extension = isVideo 
          ? (contentType.includes("mp4") ? ".mp4" : ".mov")
          : (contentType.includes("jpeg") ? ".jpg" : ".png")

        // Dosya adını oluştur
        const timestamp = Date.now()
        const fileName = `instagram-${timestamp}-${Math.random().toString(36).substring(7)}${extension}`
        const filePath = join(uploadDir, fileName)

        // Dosyayı kaydet
        const buffer = Buffer.from(await response.arrayBuffer())
        await writeFile(filePath, buffer)

        // URL'yi oluştur
        const url = `/uploads/${fileName}`

        // Veritabanına ekle
        const media = await prisma.media.create({
          data: {
            title: `Instagram - ${category}`,
            url,
            type: isVideo ? "video" : "photo",
            category,
            thumbnail: isVideo ? url : url, // Video için thumbnail aynı URL (ileride video thumbnail eklenebilir)
            isActive: true,
            order: 0,
          },
        })

        importedMedia.push(media)
      } catch (error: any) {
        console.error(`Error importing ${mediaUrl}:`, error)
        continue
      }
    }

    return NextResponse.json({
      success: true,
      imported: importedMedia.length,
      media: importedMedia,
      message: `${importedMedia.length} medya başarıyla galeriye eklendi`,
    })
  } catch (error: any) {
    console.error("Instagram download error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

