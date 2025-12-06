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

    const service = await prisma.service.update({
      where: { id: params.id },
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
        isActive,
        order,
      },
    })

    return NextResponse.json({ success: true, service })
  } catch (error: any) {
    console.error("Service update error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    await prisma.service.delete({
      where: { id: params.id },
    })

    return NextResponse.json({ success: true })
  } catch (error: any) {
    console.error("Service delete error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

