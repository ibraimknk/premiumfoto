import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import Image from "next/image"
import { Phone, MessageCircle } from "lucide-react"
import { generatePageMetadata, generateServiceSchema, generateBreadcrumbSchema, generateFAQSchema } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { shouldUnoptimizeImage } from "@/lib/image-utils"
import { BreadcrumbNav } from "@/components/features/BreadcrumbNav"

export async function generateStaticParams() {
  const services = await prisma.service.findMany({
    where: { isActive: true },
    select: { slug: true },
  })

  return services.map((service) => ({
    slug: service.slug,
  }))
}

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}) {
  const service = await prisma.service.findUnique({
    where: { slug: params.slug },
  })

  if (!service) {
    return {}
  }

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"
  const canonicalUrl = `${baseUrl}/hizmetler/${service.slug}`

  return await generatePageMetadata(
    service.seoTitle || service.title,
    service.seoDescription || service.shortDescription || undefined,
    service.seoKeywords || undefined,
    service.ogImage || service.featuredImage || undefined,
    canonicalUrl
  )
}

export default async function ServiceDetailPage({
  params,
}: {
  params: { slug: string }
}) {
  const service = await prisma.service.findUnique({
    where: { slug: params.slug },
  })

  if (!service || !service.isActive) {
    notFound()
  }

  // Parse images and videos from JSON strings
  const images = service.images ? JSON.parse(service.images) : []
  const videos = service.videos ? JSON.parse(service.videos) : []

  // Get related blog posts for this service
  // Note: SQLite doesn't support 'mode: insensitive', so we use contains which is case-sensitive
  const relatedBlogs = await prisma.blogPost.findMany({
    where: {
      isPublished: true,
      publishedAt: { not: null },
      OR: [
        { title: { contains: service.title } },
        { category: service.category || undefined },
        { content: { contains: service.title } },
      ],
    },
    take: 3,
    orderBy: { publishedAt: 'desc' },
  })

  // Get FAQs for this service
  const faqs = await prisma.fAQ.findMany({
    where: {
      isActive: true,
      OR: [
        { question: { contains: service.title, mode: 'insensitive' } },
        { answer: { contains: service.title, mode: 'insensitive' } },
        { question: { contains: service.category || '', mode: 'insensitive' } },
      ],
    },
    orderBy: { order: 'asc' },
    take: 5,
  })

  const serviceSchema = generateServiceSchema({
    title: service.title,
    description: service.shortDescription || service.description,
    slug: service.slug,
  })

  const breadcrumbSchema = generateBreadcrumbSchema([
    { name: "Ana Sayfa", url: "/" },
    { name: "Hizmetler", url: "/hizmetler" },
    { name: service.title, url: `/hizmetler/${service.slug}` },
  ])

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(serviceSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
      />
      {faqSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(faqSchema) }}
        />
      )}
      <div className="bg-neutral-50">
        <section className="py-16 md:py-24 bg-white border-b">
          <Container size="md">
            <AnimatedSection>
              {/* Breadcrumb */}
              <BreadcrumbNav
                items={[
                  { name: 'Hizmetler', url: '/hizmetler' },
                  { name: service.title, url: `/hizmetler/${service.slug}` },
                ]}
              />
              
              {/* Header */}
              <div className="mb-8">
                <h1 className="text-4xl md:text-5xl font-bold mb-4 text-neutral-900">{service.title}</h1>
                {service.shortDescription && (
                  <p className="text-xl text-neutral-600">{service.shortDescription}</p>
                )}
              </div>
            </AnimatedSection>
          </Container>
        </section>

        <section className="py-12 md:py-16">
          <Container size="md">
            <AnimatedSection>

              {/* Featured Image */}
              {service.featuredImage && (
                <div className="relative h-96 w-full mb-8 rounded-2xl overflow-hidden">
                  <Image
                    src={service.featuredImage}
                    alt={`${service.title} - Ataşehir fotoğrafçı Foto Uğur ${service.category || 'hizmet'} örneği | Uğur Fotoğrafçılık`}
                    fill
                    unoptimized={shouldUnoptimizeImage(service.featuredImage)}
                    className="object-cover"
                  />
                </div>
              )}

              {/* Description */}
              {service.description && (
                <div
                  className="prose prose-lg max-w-none mb-12 prose-headings:text-neutral-900 prose-p:text-neutral-600 prose-p:leading-relaxed"
                  dangerouslySetInnerHTML={{ __html: service.description }}
                />
              )}

              {/* Gallery */}
              {(images.length > 0 || videos.length > 0) && (
                <div className="mb-12">
                  <h2 className="text-2xl font-bold mb-6 text-neutral-900">Galeri</h2>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                    {images.map((image: string, index: number) => (
                      <div key={index} className="relative aspect-square rounded-lg overflow-hidden">
                        <Image
                          src={image}
                          alt={`${service.title} örneği ${index + 1} - Ataşehir fotoğrafçı Foto Uğur ${service.category || 'çalışma'} | Uğur Fotoğrafçılık`}
                          fill
                          className="object-cover"
                          unoptimized={shouldUnoptimizeImage(image)}
                        />
                      </div>
                    ))}
                    {videos.map((video: string, index: number) => (
                      <div key={index} className="relative aspect-square rounded-lg overflow-hidden bg-black">
                        <video
                          src={video}
                          controls
                          className="w-full h-full object-cover"
                          aria-label={`${service.title} video ${index + 1} - Foto Uğur`}
                        />
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* CTA Section */}
              <Card className="mb-12 rounded-3xl border border-neutral-200">
          <CardHeader>
            <CardTitle>Bu Hizmet İçin Randevu Alın</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col sm:flex-row gap-4">
              <Button size="lg" asChild>
                <Link href="/iletisim">Randevu Al</Link>
              </Button>
              <Button size="lg" variant="outline" asChild>
                <a
                  href="https://wa.me/905302285603"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <MessageCircle className="mr-2 h-5 w-5" />
                  WhatsApp&apos;tan Yazın
                </a>
              </Button>
              <Button size="lg" variant="outline" asChild>
                <a href="tel:02164724628">
                  <Phone className="mr-2 h-5 w-5" />
                  Ara
                </a>
              </Button>
            </div>
              </CardContent>
              </Card>

              {/* Related Blog Posts */}
              {relatedBlogs.length > 0 && (
                <div className="mb-12 p-6 bg-amber-50 rounded-2xl border border-amber-200">
                  <h2 className="text-2xl font-bold mb-4 text-neutral-900">İlgili Blog Yazıları</h2>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {relatedBlogs.map((blog) => (
                      <Link
                        key={blog.id}
                        href={`/blog/${blog.slug}`}
                        className="group p-4 bg-white rounded-lg hover:shadow-md transition-all border border-neutral-200 hover:border-amber-400"
                      >
                        <h3 className="font-semibold text-neutral-900 group-hover:text-amber-600 transition-colors mb-2">
                          {blog.title}
                        </h3>
                        {blog.excerpt && (
                          <p className="text-sm text-neutral-600 line-clamp-2">
                            {blog.excerpt}
                          </p>
                        )}
                      </Link>
                    ))}
                  </div>
                </div>
              )}

              {/* FAQ Section */}
              {faqs.length > 0 && (
                <div className="mb-12">
                  <h2 className="text-2xl font-bold mb-6 text-neutral-900">
                    {service.title} Hakkında Sık Sorulan Sorular
                  </h2>
                  <Accordion type="single" collapsible className="w-full">
                    {faqs.map((faq, index) => (
                      <AccordionItem key={faq.id} value={`faq-${index}`}>
                        <AccordionTrigger className="text-left">
                          {faq.question}
                        </AccordionTrigger>
                        <AccordionContent>
                          <div
                            className="prose prose-sm max-w-none text-neutral-600"
                            dangerouslySetInnerHTML={{ __html: faq.answer }}
                          />
                        </AccordionContent>
                      </AccordionItem>
                    ))}
                  </Accordion>
                </div>
              )}

              {/* Related Services */}
              <div>
                <h2 className="text-2xl font-bold mb-6 text-neutral-900">Diğer Hizmetlerimiz</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* This would be populated with related services */}
                </div>
              </div>
            </AnimatedSection>
          </Container>
        </section>
      </div>
    </>
  )
}

