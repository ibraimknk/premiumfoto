import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import Image from "next/image"
import { formatDate } from "@/lib/utils"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { generatePageMetadata, generateArticleSchema } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { shouldUnoptimizeImage } from "@/lib/image-utils"
import { getBlogImage } from "@/lib/blog-image-helper"

// Dinamik rendering için - yeni blog'lar için 404 sorununu çözer
export const dynamic = 'force-dynamic'
export const revalidate = 60 // 60 saniyede bir revalidate et

export async function generateStaticParams() {
  const posts = await prisma.blogPost.findMany({
    where: { isPublished: true },
    select: { slug: true },
  })

  return posts.map((post) => ({
    slug: post.slug,
  }))
}

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}) {
  const post = await prisma.blogPost.findUnique({
    where: { slug: params.slug },
  })

  if (!post) {
    return {}
  }

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"
  const canonicalUrl = `${baseUrl}/blog/${post.slug}`

  return await generatePageMetadata(
    post.seoTitle || post.title,
    post.seoDescription || post.excerpt || undefined,
    post.seoKeywords || undefined,
    getBlogImage(post.ogImage || post.coverImage),
    canonicalUrl
  )
}

export default async function BlogPostPage({
  params,
}: {
  params: { slug: string }
}) {
  const post = await prisma.blogPost.findUnique({
    where: { slug: params.slug },
  })

  if (!post || !post.isPublished) {
    notFound()
  }

  // Get related posts
  const relatedPosts = await prisma.blogPost.findMany({
    where: {
      isPublished: true,
      category: post.category,
      id: { not: post.id },
    },
    take: 3,
    orderBy: { publishedAt: 'desc' },
  })

  // Get related services for internal linking
  const relatedServices = await prisma.service.findMany({
    where: { isActive: true },
    take: 3,
    orderBy: { order: 'asc' },
  })

  const articleSchema = generateArticleSchema({
    title: post.title,
    excerpt: post.excerpt,
    publishedAt: post.publishedAt,
    slug: post.slug,
    coverImage: post.coverImage,
  })

  // Breadcrumb schema
  const breadcrumbSchema = {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [
      {
        "@type": "ListItem",
        "position": 1,
        "name": "Ana Sayfa",
        "item": process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr",
      },
      {
        "@type": "ListItem",
        "position": 2,
        "name": "Blog",
        "item": `${process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"}/blog`,
      },
      {
        "@type": "ListItem",
        "position": 3,
        "name": post.title,
        "item": `${process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"}/blog/${post.slug}`,
      },
    ],
  }

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(articleSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
      />
      <div className="bg-neutral-50">
        <section className="py-16 md:py-24 bg-white border-b">
          <Container size="md">
            <AnimatedSection>
              {/* Header */}
              <div className="mb-8">
                {post.category && (
                  <span className="text-sm font-semibold text-amber-600 mb-2 block">
                    {post.category}
                  </span>
                )}
                <h1 className="text-4xl md:text-5xl font-bold mb-4 text-neutral-900">{post.title}</h1>
                {post.publishedAt && (
                  <p className="text-neutral-600">{formatDate(post.publishedAt)}</p>
                )}
              </div>
            </AnimatedSection>
          </Container>
        </section>

        <section className="py-12 md:py-16">
          <Container size="md">
            <AnimatedSection>
              {/* Cover Image */}
              <div className="relative h-96 w-full mb-8 rounded-2xl overflow-hidden">
                <Image
                  src={getBlogImage(post.coverImage)}
                  alt={`${post.title} - Ataşehir fotoğrafçı Foto Uğur blog yazısı | Uğur Fotoğrafçılık`}
                  fill
                  className="object-cover"
                  unoptimized={shouldUnoptimizeImage(getBlogImage(post.coverImage))}
                />
              </div>

              {/* Content */}
              {post.content && (
                <div
                  className="prose prose-lg max-w-none mb-12 prose-headings:text-neutral-900 prose-p:text-neutral-600 prose-p:leading-relaxed"
                  dangerouslySetInnerHTML={{ __html: post.content }}
                />
              )}

              {/* Related Services - Internal Linking */}
              {relatedServices.length > 0 && (
                <div className="mb-12 p-6 bg-amber-50 rounded-2xl border border-amber-200">
                  <h2 className="text-2xl font-bold mb-4 text-neutral-900">İlgili Hizmetlerimiz</h2>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {relatedServices.map((service) => (
                      <Link
                        key={service.id}
                        href={`/hizmetler/${service.slug}`}
                        className="group p-4 bg-white rounded-lg hover:shadow-md transition-all border border-neutral-200 hover:border-amber-400"
                      >
                        <h3 className="font-semibold text-neutral-900 group-hover:text-amber-600 transition-colors mb-2">
                          {service.title}
                        </h3>
                        {service.shortDescription && (
                          <p className="text-sm text-neutral-600 line-clamp-2">
                            {service.shortDescription}
                          </p>
                        )}
                      </Link>
                    ))}
                  </div>
                </div>
              )}

              {/* Related Posts */}
              {relatedPosts.length > 0 && (
                <div className="border-t border-neutral-200 pt-12">
                  <h2 className="text-2xl font-bold mb-6 text-neutral-900">Benzer Yazılar</h2>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {relatedPosts.map((relatedPost) => (
                      <Link
                        key={relatedPost.id}
                        href={`/blog/${relatedPost.slug}`}
                        className="group"
                      >
                        <div className="relative h-32 w-full mb-3 rounded-lg overflow-hidden">
                          <Image
                            src={getBlogImage(relatedPost.coverImage)}
                            alt={`${relatedPost.title} - Ataşehir fotoğrafçı Foto Uğur blog yazısı | Uğur Fotoğrafçılık`}
                            fill
                            className="object-cover group-hover:scale-110 transition-transform"
                            unoptimized={shouldUnoptimizeImage(getBlogImage(relatedPost.coverImage))}
                          />
                        </div>
                        <h3 className="font-semibold group-hover:text-amber-600 transition-colors">
                          {relatedPost.title}
                        </h3>
                      </Link>
                    ))}
                  </div>
                </div>
              )}

              {/* Back to Blog */}
              <div className="mt-12">
                <Button variant="outline" asChild>
                  <Link href="/blog">← Blog&apos;a Dön</Link>
                </Button>
              </div>
            </AnimatedSection>
          </Container>
        </section>
      </div>
    </>
  )
}

