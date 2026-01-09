// Next.js Image Upload API Endpoint
// app/api/upload/route.ts dosyasına kopyalayın

import { NextResponse } from "next/server"
import { writeFile, mkdir } from "fs/promises"
import { join } from "path"
import { existsSync } from "fs"

// Bu route dinamik olmalı
export const dynamic = 'force-dynamic'

// İsteğe bağlı: API Key ile koruma
const API_KEY = process.env.UPLOAD_API_KEY || null

export async function POST(request: Request) {
  try {
    // İsteğe bağlı: API Key kontrolü
    if (API_KEY) {
      const apiKey = request.headers.get("x-api-key")
      if (apiKey !== API_KEY) {
        return NextResponse.json(
          { error: "Unauthorized - Geçersiz API Key" },
          { status: 401 }
        )
      }
    }

    const formData = await request.formData()
    const file = formData.get("file") as File

    if (!file) {
      return NextResponse.json(
        { error: "Dosya bulunamadı" },
        { status: 400 }
      )
    }

    // Dosya tipi kontrolü (sadece resim)
    const allowedTypes = [
      "image/jpeg",
      "image/jpg",
      "image/png",
      "image/gif",
      "image/webp",
      "image/svg+xml"
    ]

    if (!allowedTypes.includes(file.type)) {
      return NextResponse.json(
        { error: "Sadece resim dosyaları yüklenebilir" },
        { status: 400 }
      )
    }

    // Dosya boyutu kontrolü (10MB limit - istediğiniz gibi değiştirebilirsiniz)
    const maxFileSize = 10 * 1024 * 1024 // 10MB
    if (file.size > maxFileSize) {
      return NextResponse.json(
        {
          error: `Dosya çok büyük. Maksimum dosya boyutu: ${maxFileSize / 1024 / 1024}MB`,
          maxSize: maxFileSize,
          fileSize: file.size,
        },
        { status: 413 }
      )
    }

    // Upload klasörü
    const uploadDir = join(process.cwd(), "public", "uploads")
    
    // Uploads klasörünü oluştur
    if (!existsSync(uploadDir)) {
      await mkdir(uploadDir, { recursive: true })
    }

    // Dosya adını güvenli hale getir
    const timestamp = Date.now()
    const randomString = Math.random().toString(36).substring(2, 15)
    const originalName = file.name.replace(/[^a-zA-Z0-9.-]/g, "_")
    const fileName = `${timestamp}-${randomString}-${originalName}`
    const filePath = join(uploadDir, fileName)

    // Dosyayı kaydet
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    await writeFile(filePath, buffer)

    // URL'yi oluştur (domain'inizi buraya ekleyin)
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000"
    const url = `${baseUrl}/uploads/${fileName}`

    return NextResponse.json({
      success: true,
      url: url,
      fileName: fileName,
      size: file.size,
      type: file.type,
    })
  } catch (error: any) {
    console.error("Upload error:", error)
    
    return NextResponse.json(
      {
        success: false,
        error: error.message || "Dosya yükleme hatası",
      },
      { status: 500 }
    )
  }
}

