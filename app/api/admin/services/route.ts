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
    const {
      title,
      slug,
      shortDescription,
      description,
      category,
      featuredImage,
      seoTitle,
      seoDescription,
      seoKeywords,
      isActive,
      order,
    } = body

    const service = await prisma.service.create({
      data: {
        title,
        slug,
        shortDescription,
        description,
        category,
        featuredImage,
        seoTitle,
        seoDescription,
        seoKeywords,
        isActive: isActive ?? true,
        order: order || 0,
      },
    })

    return NextResponse.json({ success: true, service })
  } catch (error: any) {
    console.error("Service create error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

