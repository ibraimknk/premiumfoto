// Fotoğraf silme API endpoint
import { NextResponse } from "next/server"
import { unlink } from "fs/promises"
import { join } from "path"
import { existsSync } from "fs"

export const dynamic = 'force-dynamic'

// Şifre kontrolü (opsiyonel)
const DELETE_PASSWORD = process.env.DELETE_PASSWORD || 'oxelio2024'

export async function DELETE(request: Request) {
  try {
    // Şifre kontrolü
    const { searchParams } = new URL(request.url)
    const password = searchParams.get('password')
    const fileName = searchParams.get('file')

    if (password !== DELETE_PASSWORD) {
      return NextResponse.json(
        { error: "Unauthorized - Geçersiz şifre" },
        { status: 401 }
      )
    }

    if (!fileName) {
      return NextResponse.json(
        { error: "Dosya adı gerekli" },
        { status: 400 }
      )
    }

    // Güvenlik: Sadece dosya adı, path traversal koruması
    const safeFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '')
    const filePath = join(process.cwd(), "public", "uploads", safeFileName)

    // Dosya var mı kontrol et
    if (!existsSync(filePath)) {
      return NextResponse.json(
        { error: "Dosya bulunamadı" },
        { status: 404 }
      )
    }

    // Dosyayı sil
    await unlink(filePath)

    return NextResponse.json({
      success: true,
      message: "Fotoğraf başarıyla silindi"
    })
  } catch (error: any) {
    console.error("Delete error:", error)
    return NextResponse.json(
      {
        success: false,
        error: error.message || "Dosya silinemedi"
      },
      { status: 500 }
    )
  }
}

