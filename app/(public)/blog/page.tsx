import Link from "next/link"
import { prisma } from "@/lib/prisma"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import Image from "next/image"
import { formatDate } from "@/lib/utils"
import { generatePageMetadata } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { shouldUnoptimizeImage } from "@/lib/image-utils"
import { getBlogImage } from "@/lib/blog-image-helper"

// Force dynamic rendering to always fetch fresh data
export const dynamic = 'force-dynamic'
export const revalidate = 0

export async function generateMetadata() {
  return await generatePageMetadata(
    "Blog - Foto Uğur",
    "Fotoğrafçılık hakkında ipuçları, haberler ve daha fazlası.",
    "blog, fotoğraf ipuçları, fotoğrafçılık"
  )
}

export default async function BlogPage() {
  const posts = await prisma.blogPost.findMany({
    where: { 
      isPublished: true,
      publishedAt: { not: null }, // publishedAt null olmamalı
    },
    orderBy: { publishedAt: 'desc' as const },
  })
  
  // Debug için log - production'da da çalışsın
  console.log(`[Blog Page] ${posts.length} yayınlanmış blog bulundu`)
  
  if (posts.length === 0) {
    // Debug: Tüm blog'ları kontrol et
    const allPosts = await prisma.blogPost.findMany({
      select: {
        id: true,
        title: true,
        slug: true,
        isPublished: true,
        publishedAt: true,
      },
    })
    console.log(`[Blog Page Debug] Toplam blog sayısı: ${allPosts.length}`)
    console.log(`[Blog Page Debug] isPublished=true olanlar: ${allPosts.filter(p => p.isPublished).length}`)
    console.log(`[Blog Page Debug] publishedAt not null olanlar: ${allPosts.filter(p => p.publishedAt !== null).length}`)
    console.log(`[Blog Page Debug] Her ikisi de olanlar: ${allPosts.filter(p => p.isPublished && p.publishedAt !== null).length}`)
  }

  return (
    <div className="bg-neutral-50">
      {/* Hero Section */}
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center space-y-6">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">Blog</h1>
            <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
              Fotoğrafçılık hakkında ipuçları, haberler ve daha fazlası
            </p>
          </AnimatedSection>
        </Container>
      </section>

      {/* Blog Posts */}
      <section className="py-12 md:py-16">
        <Container>
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 lg:gap-8">
            {posts.map((post, index) => (
              <AnimatedSection key={post.id} delay={index * 0.1}>
                <Card className="h-full hover:shadow-lg transition-shadow rounded-3xl border border-neutral-200 bg-white shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all">
              <div className="relative h-48 w-full overflow-hidden rounded-t-lg">
                <Image
                  src={getBlogImage(post.coverImage)}
                  alt={`${post.title} - Foto Uğur blog yazısı`}
                  fill
                  className="object-cover"
                  unoptimized={shouldUnoptimizeImage(getBlogImage(post.coverImage))}
                />
              </div>
              <CardHeader>
                {post.category && (
                  <span className="text-xs font-semibold text-primary mb-2">
                    {post.category}
                  </span>
                )}
                <CardTitle>
                  <Link href={`/blog/${post.slug}`} className="hover:text-primary">
                    {post.title}
                  </Link>
                </CardTitle>
                <CardDescription>{post.excerpt}</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between text-sm text-muted-foreground">
                  {post.publishedAt && (
                    <span>{formatDate(post.publishedAt)}</span>
                  )}
                  <Link
                    href={`/blog/${post.slug}`}
                    className="text-primary hover:underline"
                  >
                    Devamını Oku →
                  </Link>
                </div>
                </CardContent>
              </Card>
              </AnimatedSection>
            ))}
          </div>

          {posts.length === 0 && (
            <div className="text-center py-12">
              <p className="text-neutral-500">Henüz blog yazısı eklenmemiş.</p>
            </div>
          )}
        </Container>
      </section>
    </div>
  )
}

