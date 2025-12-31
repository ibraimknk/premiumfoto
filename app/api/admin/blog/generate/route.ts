import { NextResponse } from "next/server"
import { getServerSession } from "next-auth"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { generateBlogPost } from "@/lib/gemini"
import { ensureBlogImage } from "@/lib/blog-image-helper"

export const dynamic = 'force-dynamic'

export async function POST(request: Request) {
  try {
    const session = await getServerSession(authOptions)
    if (!session) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const body = await request.json()
    const { count = 1, topic } = body

    if (count < 1 || count > 10) {
      return NextResponse.json(
        { error: "Blog sayısı 1 ile 10 arasında olmalıdır" },
        { status: 400 }
      )
    }

    const createdPosts = []

    for (let i = 0; i < count; i++) {
      try {
        // Gemini API ile blog içeriği oluştur
        const blogData = await generateBlogPost(topic)

        // Slug'ın benzersiz olduğundan emin ol
        let slug = blogData.slug
        let slugExists = await prisma.blogPost.findUnique({
          where: { slug },
        })

        let counter = 1
        while (slugExists) {
          slug = `${blogData.slug}-${counter}`
          slugExists = await prisma.blogPost.findUnique({
            where: { slug },
          })
          counter++
        }

        // Görsel kontrolü - yoksa varsayılan görseli ekle
        const coverImage = ensureBlogImage(blogData.coverImage)
        
        // Blog yazısını veritabanına kaydet (otomatik yayınla)
        const post = await prisma.blogPost.create({
          data: {
            title: blogData.title,
            slug,
            excerpt: blogData.excerpt,
            content: blogData.content,
            category: blogData.category,
            seoTitle: blogData.seoTitle,
            seoDescription: blogData.seoDescription,
            seoKeywords: blogData.seoKeywords,
            coverImage: coverImage,
            ogImage: coverImage,
            isPublished: true, // Otomatik olarak yayınla
            publishedAt: new Date(), // Yayın tarihi şimdi
          },
        })

        createdPosts.push(post)

        // API rate limit'i için kısa bir bekleme
        if (i < count - 1) {
          await new Promise((resolve) => setTimeout(resolve, 2000))
        }
      } catch (error: any) {
        console.error(`Blog ${i + 1} oluşturma hatası:`, error)
        // Hata olsa bile diğer blogları oluşturmaya devam et
        continue
      }
    }

    if (createdPosts.length === 0) {
      return NextResponse.json(
        { error: "Hiç blog yazısı oluşturulamadı" },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      posts: createdPosts,
      count: createdPosts.length,
      message: `${createdPosts.length} blog yazısı başarıyla oluşturuldu`,
    })
  } catch (error: any) {
    console.error("Blog generate error:", error)
    return NextResponse.json(
      { error: error.message || "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

