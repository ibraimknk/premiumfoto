import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

export const dynamic = 'force-dynamic'

// Toplu silme - seçilen medyaları veya tümünü sil
export async function POST(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = await request.json()
    const { ids, deleteAll } = body

    if (deleteAll) {
      // Tüm medyaları sil
      const deleted = await prisma.media.deleteMany({})
      return NextResponse.json({
        success: true,
        message: `${deleted.count} medya başarıyla silindi`,
        deleted: deleted.count,
      })
    }

    if (!ids || !Array.isArray(ids) || ids.length === 0) {
      return NextResponse.json({ error: "Silinecek medya ID'leri gerekli" }, { status: 400 })
    }

    // Seçilen medyaları sil
    const deleted = await prisma.media.deleteMany({
      where: {
        id: {
          in: ids,
        },
      },
    })

    return NextResponse.json({
      success: true,
      message: `${deleted.count} medya başarıyla silindi`,
      deleted: deleted.count,
    })
  } catch (error: any) {
    console.error("Bulk delete error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

