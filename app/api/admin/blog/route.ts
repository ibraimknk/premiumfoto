import { NextResponse } from "next/server"
import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { ensureBlogImage } from "@/lib/blog-image-helper"

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

    // Görsel kontrolü - yoksa varsayılan görseli ekle
    const finalCoverImage = ensureBlogImage(coverImage)
    
    const post = await prisma.blogPost.create({
      data: {
        title,
        slug,
        excerpt,
        content,
        category,
        coverImage: finalCoverImage,
        ogImage: finalCoverImage,
        seoTitle,
        seoDescription,
        seoKeywords,
        isPublished: isPublished ?? false,
        publishedAt: isPublished && publishedAt ? new Date(publishedAt) : null,
      },
    })

    return NextResponse.json({ success: true, post })
  } catch (error: any) {
    console.error("Blog post create error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

