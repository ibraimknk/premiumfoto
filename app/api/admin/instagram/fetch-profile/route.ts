import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"

export const dynamic = 'force-dynamic'

// Instagram profilinden tüm gönderileri çek
// Not: Instagram'ın resmi API'si olmadan bu zor, alternatif yöntemler kullanılmalı
export async function POST(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = await request.json()
    const { profileUrl } = body

    if (!profileUrl) {
      return NextResponse.json({ error: "Instagram profil URL'si gerekli" }, { status: 400 })
    }

    // Instagram profil URL'sinden kullanıcı adını çıkar
    // Format: https://www.instagram.com/username/ veya instagram.com/username
    const usernameMatch = profileUrl.match(/instagram\.com\/([^\/\?]+)/)
    if (!usernameMatch) {
      return NextResponse.json({ 
        error: "Geçersiz Instagram profil URL'si. Örnek: https://www.instagram.com/dugunkaremcom/" 
      }, { status: 400 })
    }

    const username = usernameMatch[1].replace(/\/$/, '') // Trailing slash'i kaldır

    // Instagram'dan içerik çekmek için alternatif yöntemler:
    // 1. Instagram Graph API (Business Account gerekir)
    // 2. Web scraping (Instagram'ın ToS'una aykırı olabilir)
    // 3. Üçüncü parti servisler
    
    // Şimdilik kullanıcıya manuel indirme talimatı ver
    return NextResponse.json({
      success: false,
      message: "Instagram'dan otomatik içerik çekmek için Instagram Graph API veya üçüncü parti araçlar gerekir.",
      username,
      instructions: [
        "1. Instagram içeriklerini indirmek için bir araç kullanın:",
        "   - Instaloader (komut satırı): pip install instaloader",
        "   - 4K Stogram (GUI): https://www.4kdownload.com/products/stogram",
        "   - DownloadGram (web): https://downloadgram.com/",
        "",
        "2. İndirilen dosyaları buraya yükleyin veya",
        "3. İndirilen dosyaların URL'lerini toplu olarak yapıştırın"
      ],
      alternative: "Alternatif olarak, Instagram içeriklerini manuel olarak indirip toplu yükleme özelliğini kullanabilirsiniz."
    })

  } catch (error: any) {
    console.error("Instagram profile fetch error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

