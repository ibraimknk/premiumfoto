import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { writeFile, mkdir } from "fs/promises"
import { join } from "path"
import { existsSync } from "fs"

export const dynamic = 'force-dynamic'

// Instagram'dan görsel/video indirip galeriye ekle
export async function POST(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = await request.json()
    const { instagramUrl, category = "Instagram" } = body

    if (!instagramUrl) {
      return NextResponse.json({ error: "Instagram URL gerekli" }, { status: 400 })
    }

    // Instagram URL'den post ID'sini çıkar
    // Format: https://www.instagram.com/p/{POST_ID}/ veya https://www.instagram.com/reel/{POST_ID}/
    const postIdMatch = instagramUrl.match(/instagram\.com\/(?:p|reel)\/([^\/\?]+)/)
    if (!postIdMatch) {
      return NextResponse.json({ 
        error: "Geçersiz Instagram URL formatı. Örnek: https://www.instagram.com/p/ABC123/ veya https://www.instagram.com/reel/ABC123/" 
      }, { status: 400 })
    }

    const postId = postIdMatch[1]

    // Instagram Graph API kullanarak içerik çek
    // Not: Bu için Instagram Business Account ve Access Token gerekir
    // Şimdilik manuel indirme için alternatif bir yöntem kullanacağız
    
    // Kullanıcıya manuel indirme talimatı ver
    return NextResponse.json({
      success: false,
      message: "Instagram Graph API entegrasyonu için Instagram Business Account ve Access Token gerekir.",
      instructions: [
        "1. Instagram Business Account'unuzu Facebook Business Manager'a bağlayın",
        "2. Facebook Developer App oluşturun",
        "3. Instagram Basic Display API veya Instagram Graph API için Access Token alın",
        "4. Alternatif: Instagram içeriklerini manuel olarak indirip yükleyin"
      ],
      alternative: "Instagram içeriklerini manuel olarak indirip admin panelinden yükleyebilirsiniz."
    })

  } catch (error: any) {
    console.error("Instagram import error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

