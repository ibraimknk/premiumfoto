import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

// Bu route dinamik olmalı çünkü authentication için headers kullanıyor
export const dynamic = 'force-dynamic'

export async function PUT(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const message = await prisma.contactMessage.update({
      where: { id: params.id },
      data: { isRead: true },
    })

    return NextResponse.json({ success: true, message })
  } catch (error: any) {
    console.error("Message read error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

