import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { writeFile, mkdir } from "fs/promises"
import { join } from "path"
import { existsSync } from "fs"

// Bu route dinamik olmalı çünkü authentication için headers kullanıyor
export const dynamic = 'force-dynamic'

export async function POST(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const formData = await request.formData()
    const files = formData.getAll("files") as File[]

    if (!files || files.length === 0) {
      return NextResponse.json({ error: "Dosya bulunamadı" }, { status: 400 })
    }

    // Dosya boyutu kontrolü (50MB limit)
    const maxFileSize = 50 * 1024 * 1024 // 50MB
    for (const file of files) {
      if (file.size > maxFileSize) {
        return NextResponse.json(
          { 
            error: `Dosya çok büyük: ${file.name} (${(file.size / 1024 / 1024).toFixed(2)}MB). Maksimum dosya boyutu: 50MB`,
            maxSize: maxFileSize,
            fileSize: file.size,
          },
          { status: 413 }
        )
      }
    }

    const uploadDir = join(process.cwd(), "public", "uploads")
    
    // Uploads klasörünü oluştur
    if (!existsSync(uploadDir)) {
      await mkdir(uploadDir, { recursive: true })
    }

    const uploadedFiles = []

    for (const file of files) {
      if (!file) continue

      // Dosya adını güvenli hale getir
      const timestamp = Date.now()
      const originalName = file.name.replace(/[^a-zA-Z0-9.-]/g, "_")
      const fileName = `${timestamp}-${originalName}`
      const filePath = join(uploadDir, fileName)

      // Dosyayı kaydet
      const bytes = await file.arrayBuffer()
      const buffer = Buffer.from(bytes)
      await writeFile(filePath, buffer)

      // URL'yi oluştur
      const url = `/uploads/${fileName}`

      uploadedFiles.push({
        name: file.name,
        url,
        size: file.size,
        type: file.type,
      })
    }

    return NextResponse.json({
      success: true,
      files: uploadedFiles,
    })
  } catch (error: any) {
    console.error("Upload error:", error)
    
    // HTTP 413 hatası için özel mesaj
    if (error.message?.includes("413") || error.status === 413 || error.message?.includes("Payload Too Large")) {
      return NextResponse.json(
        { 
          success: false,
          error: "Dosya çok büyük. Maksimum dosya boyutu: 50MB. Lütfen daha küçük bir dosya seçin veya dosyayı sıkıştırın.",
          maxSize: 50 * 1024 * 1024,
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

