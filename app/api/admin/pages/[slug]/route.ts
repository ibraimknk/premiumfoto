import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

// Bu route dinamik olmalı çünkü authentication için headers kullanıyor
export const dynamic = 'force-dynamic'

export async function PUT(
  request: Request,
  { params }: { params: { slug: string } }
) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = await request.json()
    const { title, content, ogImage, seoTitle, seoDescription, seoKeywords } = body

    const page = await prisma.page.upsert({
      where: { slug: params.slug },
      update: {
        title,
        content,
        ogImage,
        seoTitle,
        seoDescription,
        seoKeywords,
      },
      create: {
        title,
        slug: params.slug,
        content,
        ogImage,
        seoTitle,
        seoDescription,
        seoKeywords,
      },
    })

    return NextResponse.json({ success: true, page })
  } catch (error: any) {
    console.error("Page update error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

