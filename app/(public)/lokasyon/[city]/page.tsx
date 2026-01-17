import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import { generatePageMetadata, generateLocalBusinessSchema } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { BreadcrumbNav } from "@/components/features/BreadcrumbNav"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { MapPin, Phone, Mail, Clock, ArrowRight } from "lucide-react"
import Image from "next/image"

const LOCATIONS = {
  atasehir: {
    name: "Ataşehir",
    fullName: "Ataşehir, İstanbul",
    address: "Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul",
    phone: "0216 472 46 28",
    email: "info@fotougur.com.tr",
    description: "Ataşehir'de profesyonel fotoğraf hizmetleri sunuyoruz. Düğün fotoğrafçılığı, dış mekan çekimi, ürün fotoğrafçılığı ve daha fazlası.",
    keywords: "ataşehir fotoğrafçı, ataşehir düğün fotoğrafçısı, ataşehir fotoğraf stüdyosu, istanbul fotoğrafçı",
  },
  istanbul: {
    name: "İstanbul",
    fullName: "İstanbul",
    address: "Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul",
    phone: "0216 472 46 28",
    email: "info@fotougur.com.tr",
    description: "İstanbul'da profesyonel fotoğraf hizmetleri. Düğün, dış mekan, ürün fotoğrafçılığı ve stüdyo çekimleri.",
    keywords: "istanbul fotoğrafçı, istanbul düğün fotoğrafçısı, istanbul fotoğraf stüdyosu",
  },
}

export async function generateStaticParams() {
  return Object.keys(LOCATIONS).map((city) => ({
    city,
  }))
}

export async function generateMetadata({
  params,
}: {
  params: { city: string }
}) {
  const location = LOCATIONS[params.city as keyof typeof LOCATIONS]
  
  if (!location) {
    return {}
  }

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"
  const canonicalUrl = `${baseUrl}/lokasyon/${params.city}`

  return generatePageMetadata(
    `${location.name} Fotoğrafçı - Foto Uğur | ${location.fullName} Profesyonel Fotoğraf Hizmetleri`,
    location.description,
    location.keywords,
    undefined,
    canonicalUrl
  )
}

export default async function LocationPage({
  params,
}: {
  params: { city: string }
}) {
  const location = LOCATIONS[params.city as keyof typeof LOCATIONS]

  if (!location) {
    notFound()
  }

  // Get services for this location
  const services = await prisma.service.findMany({
    where: { isActive: true },
    take: 6,
    orderBy: { order: 'asc' },
  })

  // Get blog posts related to location
  // Note: SQLite doesn't support 'mode: insensitive', so we use contains which is case-sensitive
  const blogPosts = await prisma.blogPost.findMany({
    where: {
      isPublished: true,
      publishedAt: { not: null },
      OR: [
        { title: { contains: location.name } },
        { content: { contains: location.name } },
      ],
    },
    take: 3,
    orderBy: { publishedAt: 'desc' },
  })

  const localBusinessSchema = generateLocalBusinessSchema()

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(localBusinessSchema) }}
      />
      <div className="bg-neutral-50">
        {/* Hero Section */}
        <section className="py-16 md:py-24 bg-white border-b">
          <Container>
            <AnimatedSection>
              <BreadcrumbNav
                items={[
                  { name: 'Ana Sayfa', url: '/' },
                  { name: 'Lokasyonlar', url: '/lokasyon' },
                  { name: location.name, url: `/lokasyon/${params.city}` },
                ]}
              />
              <h1 className="text-4xl md:text-5xl font-bold mb-4 text-neutral-900">
                {location.name} Fotoğrafçı - Foto Uğur
              </h1>
              <p className="text-xl text-neutral-600 mb-6">
                {location.description}
              </p>
              <div className="flex flex-wrap gap-4">
                <div className="flex items-center text-neutral-600">
                  <MapPin className="h-5 w-5 mr-2 text-amber-600" />
                  <span>{location.address}</span>
                </div>
                <div className="flex items-center text-neutral-600">
                  <Phone className="h-5 w-5 mr-2 text-amber-600" />
                  <a href={`tel:${location.phone.replace(/\s/g, '')}`} className="hover:text-amber-600">
                    {location.phone}
                  </a>
                </div>
              </div>
            </AnimatedSection>
          </Container>
        </section>

        {/* Services Section */}
        <section className="py-16 md:py-24">
          <Container>
            <AnimatedSection>
              <h2 className="text-3xl font-bold mb-8 text-neutral-900">
                {location.name} Bölgesinde Sunduğumuz Hizmetler
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {services.map((service) => (
                  <Card key={service.id} className="h-full hover:shadow-lg transition-shadow">
                    <CardHeader>
                      <CardTitle>{service.title}</CardTitle>
                      {service.shortDescription && (
                        <p className="text-sm text-neutral-600 mt-2">
                          {service.shortDescription}
                        </p>
                      )}
                    </CardHeader>
                    <CardContent>
                      <Button variant="outline" asChild className="w-full">
                        <Link href={`/hizmetler/${service.slug}`}>
                          Detaylar <ArrowRight className="ml-2 h-4 w-4" />
                        </Link>
                      </Button>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </AnimatedSection>
          </Container>
        </section>

        {/* Blog Posts Section */}
        {blogPosts.length > 0 && (
          <section className="py-16 md:py-24 bg-white">
            <Container>
              <AnimatedSection>
                <h2 className="text-3xl font-bold mb-8 text-neutral-900">
                  {location.name} Hakkında Blog Yazıları
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  {blogPosts.map((post) => (
                    <Card key={post.id} className="h-full hover:shadow-lg transition-shadow">
                      <CardHeader>
                        <CardTitle className="text-lg">{post.title}</CardTitle>
                        {post.excerpt && (
                          <p className="text-sm text-neutral-600 mt-2 line-clamp-3">
                            {post.excerpt}
                          </p>
                        )}
                      </CardHeader>
                      <CardContent>
                        <Button variant="outline" asChild className="w-full">
                          <Link href={`/blog/${post.slug}`}>
                            Devamını Oku <ArrowRight className="ml-2 h-4 w-4" />
                          </Link>
                        </Button>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </AnimatedSection>
            </Container>
          </section>
        )}

        {/* CTA Section */}
        <section className="py-16 md:py-24 bg-amber-50">
          <Container>
            <AnimatedSection className="text-center">
              <h2 className="text-3xl font-bold mb-4 text-neutral-900">
                {location.name} Bölgesinde Fotoğraf Hizmeti İçin Bize Ulaşın
              </h2>
              <p className="text-lg text-neutral-600 mb-8">
                Profesyonel fotoğraf hizmetlerimiz için hemen randevu alın
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" variant="premium" asChild>
                  <Link href="/iletisim">Randevu Al</Link>
                </Button>
                <Button size="lg" variant="outline" asChild>
                  <a href={`tel:${location.phone.replace(/\s/g, '')}`}>
                    <Phone className="mr-2 h-5 w-5" />
                    Hemen Ara
                  </a>
                </Button>
              </div>
            </AnimatedSection>
          </Container>
        </section>
      </div>
    </>
  )
}

