import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

// Bu route dinamik olmalı çünkü authentication için headers kullanıyor
export const dynamic = 'force-dynamic'

export async function GET(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const media = await prisma.media.findMany({
      where: { isActive: true },
      orderBy: { order: "asc" },
      select: {
        id: true,
        url: true,
        type: true,
        title: true,
        thumbnail: true,
        category: true,
      },
    })

    return NextResponse.json({ success: true, media })
  } catch (error: any) {
    console.error("Media list error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

