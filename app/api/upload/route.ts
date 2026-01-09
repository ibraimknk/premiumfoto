// Fotoğraf Upload API Endpoint - fotougur.com.tr
// Public endpoint - API Key ile korunuyor (opsiyonel)

import { NextResponse } from "next/server"
import { writeFile, mkdir } from "fs/promises"
import { join } from "path"
import { existsSync } from "fs"

// Bu route dinamik olmalı
export const dynamic = 'force-dynamic'

// API Key koruması (opsiyonel - .env dosyasında UPLOAD_API_KEY tanımlayın)
const API_KEY = process.env.UPLOAD_API_KEY || null

// Domain ayarı
const DOMAIN = process.env.NEXT_PUBLIC_BASE_URL || "https://fotougur.com.tr"

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

    // FormData'yı al (admin upload route'u gibi basit)
    let formData: FormData
    try {
      formData = await request.formData()
    } catch (error: any) {
      console.error("FormData parse error:", error)
      const contentType = request.headers.get("content-type") || "unknown"
      return NextResponse.json(
        { 
          error: "Failed to parse body as FormData.",
          details: error.message || "Unknown error",
          contentType: contentType,
          hint: "Make sure you're sending multipart/form-data with 'file' field"
        },
        { status: 400 }
      )
    }

    const file = formData.get("file") as File

    if (!file) {
      return NextResponse.json(
        { error: "Dosya bulunamadı. 'file' adında bir dosya gönderin." },
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
        { 
          error: "Sadece resim dosyaları yüklenebilir",
          allowedTypes: ["jpeg", "jpg", "png", "gif", "webp", "svg"]
        },
        { status: 400 }
      )
    }

    // Dosya boyutu kontrolü (20MB limit)
    const maxFileSize = 20 * 1024 * 1024 // 20MB
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
    const fileExtension = originalName.split('.').pop()?.toLowerCase() || 'jpg'
    const fileName = `${timestamp}-${randomString}.${fileExtension}`
    const filePath = join(uploadDir, fileName)

    // Dosyayı kaydet
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    await writeFile(filePath, buffer)

    // Tam URL'yi oluştur (fotougur.com.tr)
    const url = `${DOMAIN}/uploads/${fileName}`

    return NextResponse.json({
      success: true,
      url: url,
      fileName: fileName,
      size: file.size,
      type: file.type,
      message: "Fotoğraf başarıyla yüklendi"
    })
  } catch (error: any) {
    console.error("Upload error:", error)
    
    // HTTP 413 hatası için özel mesaj
    if (error.message?.includes("413") || error.status === 413 || error.message?.includes("Payload Too Large")) {
      return NextResponse.json(
        { 
          success: false,
          error: "Dosya çok büyük. Maksimum dosya boyutu: 20MB. Lütfen daha küçük bir dosya seçin veya dosyayı sıkıştırın.",
          maxSize: 20 * 1024 * 1024,
        },
        { status: 413 }
      )
    }
    
    // Daha detaylı hata mesajı
    let errorMessage = "Dosya yükleme hatası"
    if (error.code === "ENOENT") {
      errorMessage = "Upload klasörü oluşturulamadı"
    } else if (error.code === "EACCES") {
      errorMessage = "Dosya yazma izni yok"
    } else if (error.code === "ENOSPC") {
      errorMessage = "Disk dolu"
    } else if (error.message) {
      errorMessage = error.message
    }
    
    return NextResponse.json(
      { 
        success: false,
        error: errorMessage,
        details: process.env.NODE_ENV === "development" ? error.stack : undefined
      },
      { status: 500 }
    )
  }
}

// GET endpoint - API bilgileri
export async function GET() {
  return NextResponse.json({
    message: "Fotoğraf Upload API - fotougur.com.tr",
    endpoint: "/api/upload",
    method: "POST",
    contentType: "multipart/form-data",
    fieldName: "file",
    maxFileSize: "20MB",
    allowedTypes: ["jpeg", "jpg", "png", "gif", "webp", "svg"],
    example: {
      curl: `curl -X POST https://fotougur.com.tr/api/upload \\
  -F "file=@/path/to/image.jpg" \\
  -H "x-api-key: YOUR_API_KEY"`
    }
  })
}

