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
      excerpt,
      content,
      category,
      coverImage,
      seoTitle,
      seoDescription,
      seoKeywords,
      isPublished,
      publishedAt,
    } = body

    const post = await prisma.blogPost.update({
      where: { id: params.id },
      data: {
        title,
        slug,
        excerpt,
        content,
        category,
        coverImage,
        seoTitle,
        seoDescription,
        seoKeywords,
        isPublished,
        publishedAt: isPublished && publishedAt ? new Date(publishedAt) : null,
      },
    })

    return NextResponse.json({ success: true, post })
  } catch (error: any) {
    console.error("Blog post update error:", error)
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

    await prisma.blogPost.delete({
      where: { id: params.id },
    })

    return NextResponse.json({ success: true })
  } catch (error: any) {
    console.error("Blog post delete error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

