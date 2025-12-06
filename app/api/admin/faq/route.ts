import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

// Bu route dinamik olmalı çünkü authentication için headers kullanıyor
export const dynamic = 'force-dynamic'

export async function POST(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = await request.json()
    const { question, answer, isActive, order } = body

    const faq = await prisma.fAQ.create({
      data: {
        question,
        answer,
        isActive: isActive ?? true,
        order: order || 0,
      },
    })

    return NextResponse.json({ success: true, faq })
  } catch (error: any) {
    console.error("FAQ create error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

