import Link from "next/link"
import Image from "next/image"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Phone, Camera, Heart, Package, Users, MessageCircle, ArrowRight, Play, Star } from "lucide-react"
import { generatePageMetadata, generateLocalBusinessSchema, generateOrganizationSchema, generateWebSiteSchema, generateReviewSchema } from "@/lib/seo"
import { prisma } from "@/lib/prisma"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { HeroCarousel } from "@/components/features/HeroCarousel"

// Force dynamic rendering to always fetch fresh data
export const dynamic = 'force-dynamic'
export const revalidate = 0

export async function generateMetadata() {
  return await generatePageMetadata(
    "Foto Uğur | Ataşehir Fotoğrafçı | Dış Mekan, Düğün, Ürün Çekimi",
    "Ataşehir fotoğrafçı ve İstanbul fotoğrafçı hizmetleri. İstanbul düğün fotoğrafçısı olarak dış mekan çekimi, ürün fotoğrafçılığı ve profesyonel fotoğraf hizmetleri sunuyoruz. 1997'den beri güvenilir hizmet.",
    "ataşehir fotoğrafçı, istanbul fotoğrafçı, istanbul düğün fotoğrafçısı, dış mekan çekimi, ürün fotoğrafçılığı"
  )
}

export default async function HomePage() {
  const services = await prisma.service.findMany({
    where: { isActive: true },
    take: 6,
    orderBy: { order: 'asc' },
  })

  const testimonials = await prisma.testimonial.findMany({
    where: { isActive: true },
    take: 3,
    orderBy: { order: 'asc' },
  })

  const settings = await prisma.siteSetting.findFirst()

  // Parse carousel items
  let carouselItems: Array<{
    id: string
    image: string
    title?: string
    subtitle?: string
  }> = []

  if (settings && 'carouselItems' in settings && settings.carouselItems) {
    try {
      const parsed = JSON.parse(settings.carouselItems as string)
      if (Array.isArray(parsed) && parsed.length > 0) {
        carouselItems = parsed.filter((item: any) => item.image && item.image.trim() !== "" && !item.image.includes("/api/placeholder"))
      }
    } catch (e) {
      console.error("Error parsing carousel items:", e)
    }
  }

  // Eğer carousel items yoksa, boş array döndür (carousel gösterilmez)
  if (carouselItems.length === 0) {
    carouselItems = []
  }

  const serviceIcons: { [key: string]: typeof Camera } = {
    'Dış Mekan Çekimi': Camera,
    'Düğün Fotoğrafçılığı': Heart,
    'Ürün Fotoğrafçılığı': Package,
    'Stüdyo Çekimi': Users,
    'Vesikalık & Biyometrik': Users,
    'Sosyal Medya İçerikleri': MessageCircle,
  }

  const localBusinessSchema = generateLocalBusinessSchema()
  const organizationSchema = generateOrganizationSchema()
  const webSiteSchema = generateWebSiteSchema()
  const reviewSchema = testimonials.length > 0
    ? generateReviewSchema(
        testimonials.map((t) => ({
          name: t.name,
          rating: t.rating,
          comment: t.comment,
          date: t.createdAt,
        }))
      )
    : null

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(localBusinessSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(webSiteSchema) }}
      />
      {reviewSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(reviewSchema) }}
        />
      )}
      <div className="bg-neutral-50">
        {/* Hero Section */}
        <section className="relative min-h-[60vh] md:min-h-[75vh] flex items-center justify-center overflow-hidden bg-gradient-to-br from-neutral-50 via-white to-amber-50/30">
          <Container>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center py-12 md:py-16">
              {/* Left: Text Content */}
              <AnimatedSection className="space-y-6">
                <div className="space-y-4">
                  <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-neutral-900 leading-tight">
                    Ataşehir&apos;de <span className="text-amber-600">Premium</span> Fotoğraf Stüdyosu – Foto Uğur
                  </h1>
                  <p className="text-base md:text-lg text-neutral-600 leading-relaxed">
                    <strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong> olarak 1997&apos;den beri profesyonel fotoğraf hizmetleri sunuyoruz. Dış çekim, düğün, ürün fotoğrafçılığı ve daha fazlası.
                  </p>
                </div>
                <div className="flex flex-col sm:flex-row gap-4">
                  <Button size="lg" variant="premium" asChild>
                    <Link href="/iletisim">
                      Randevu Al
                      <ArrowRight className="ml-2 h-5 w-5" />
                    </Link>
                  </Button>
                  <Button size="lg" variant="outline" asChild>
                    <Link href="/galeri">
                      Portföyü İncele
                    </Link>
                  </Button>
                </div>
              </AnimatedSection>

              {/* Right: Carousel */}
              <AnimatedSection delay={0.2} className="hidden lg:block">
                <div className="relative aspect-[4/3] rounded-3xl overflow-hidden shadow-2xl">
                  <HeroCarousel
                    items={carouselItems}
                    autoPlay={true}
                    interval={5000}
                  />
                </div>
              </AnimatedSection>
              {/* Mobile placeholder */}
              <AnimatedSection delay={0.2} className="lg:hidden">
                <div className="relative aspect-[4/3] rounded-3xl overflow-hidden shadow-2xl">
                  <div className="absolute inset-0 bg-gradient-to-br from-amber-100 to-amber-200 flex items-center justify-center">
                    <Camera className="h-32 w-32 text-amber-600 opacity-20" />
                  </div>
                </div>
              </AnimatedSection>
            </div>
          </Container>
        </section>

        {/* Featured Services */}
        <section className="py-12 md:py-16 bg-white">
          <Container>
            <AnimatedSection className="text-center mb-12">
              <h2 className="text-3xl md:text-4xl font-bold mb-4 text-neutral-900">
                Hizmetlerimiz
              </h2>
              <p className="text-base md:text-lg text-neutral-600 max-w-2xl mx-auto">
                Profesyonel fotoğraf hizmetlerimizle hayatınızın özel anlarını ölümsüzleştirin
              </p>
            </AnimatedSection>
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 lg:gap-8">
              {services.map((service, index) => {
                const Icon = serviceIcons[service.title] || Camera
                return (
                  <AnimatedSection key={service.id} delay={index * 0.1}>
                    <Card className="h-full group cursor-pointer rounded-3xl border border-neutral-200 bg-white shadow-sm p-6 hover:shadow-md hover:-translate-y-0.5 transition-all">
                      <CardHeader className="p-0 mb-4">
                        <div className="w-14 h-14 rounded-2xl bg-amber-100 flex items-center justify-center mb-4 group-hover:bg-amber-200 transition-colors">
                          <Icon className="h-7 w-7 text-amber-600" />
                        </div>
                        <CardTitle className="text-xl">{service.title}</CardTitle>
                        <CardDescription className="text-base">
                          {service.shortDescription}
                        </CardDescription>
                      </CardHeader>
                      <CardContent className="p-0">
                        <Link
                          href={`/hizmetler/${service.slug}`}
                          className="inline-flex items-center text-sm font-medium text-amber-600 hover:text-amber-700 group-hover:gap-2 gap-1 transition-all"
                        >
                          Detaylı İncele
                          <ArrowRight className="h-4 w-4" />
                        </Link>
                      </CardContent>
                    </Card>
                  </AnimatedSection>
                )
              })}
            </div>
          </Container>
        </section>

        {/* About Preview */}
        <section className="py-12 md:py-16 bg-neutral-50">
          <Container>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
              <AnimatedSection className="space-y-6">
                <h2 className="text-3xl md:text-4xl font-bold text-neutral-900">
                  1997&apos;den Beri Fotoğrafçılıkta Öncü
                </h2>
                <p className="text-lg text-neutral-600 leading-relaxed">
                  Foto Uğur olarak, klasik karanlık oda döneminden dijital dünyaya uzanan
                  yolculuğumuzda, fotoğrafçılığı her zaman bir zanaat ve estetik bakış açısının
                  birleşimi olarak gördük.
                </p>
                <p className="text-lg text-neutral-600 leading-relaxed">
                  Bugün Ataşehir&apos;de, modern ekipmanlarımız ve dinamik bakış açımızla,
                  siz değerli müşterilerimize güvenilir, kaliteli ve şeffaf bir hizmet sunmaya
                  devam ediyoruz.
                </p>
                <Button size="lg" variant="outline" asChild>
                  <Link href="/hakkimizda">
                    Daha Fazlası İçin
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Link>
                </Button>
              </AnimatedSection>
              <AnimatedSection delay={0.2} className="relative">
                <div className="relative aspect-[4/3] rounded-3xl overflow-hidden shadow-xl">
                  <div className="absolute inset-0 bg-gradient-to-br from-neutral-200 to-neutral-300 flex items-center justify-center">
                    <Camera className="h-24 w-24 text-neutral-400" />
                  </div>
                </div>
                <div className="absolute -bottom-4 -right-4 w-24 h-24 bg-amber-500/20 rounded-full blur-2xl" />
              </AnimatedSection>
            </div>
          </Container>
        </section>

        {/* Testimonials */}
        {testimonials.length > 0 && (
          <section className="py-12 md:py-16 bg-white">
            <Container>
              <AnimatedSection className="text-center mb-12">
                <h2 className="text-3xl md:text-4xl font-bold mb-4 text-neutral-900">
                  Müşteri Yorumları
                </h2>
                <p className="text-base md:text-lg text-neutral-600">
                  Müşterilerimizin deneyimleri
                </p>
              </AnimatedSection>
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 lg:gap-8">
                {testimonials.map((testimonial, index) => (
                  <AnimatedSection key={testimonial.id} delay={index * 0.1}>
                    <Card className="h-full">
                      <CardHeader>
                        <div className="flex items-center mb-3">
                          {[...Array(testimonial.rating)].map((_, i) => (
                            <Star key={i} className="h-5 w-5 fill-amber-400 text-amber-400" />
                          ))}
                        </div>
                        <CardDescription className="text-base leading-relaxed">
                          &quot;{testimonial.comment}&quot;
                        </CardDescription>
                      </CardHeader>
                      <CardContent>
                        <p className="font-semibold text-neutral-900">{testimonial.name}</p>
                        {testimonial.serviceType && (
                          <p className="text-sm text-neutral-500">{testimonial.serviceType}</p>
                        )}
                      </CardContent>
                    </Card>
                  </AnimatedSection>
                ))}
              </div>
            </Container>
          </section>
        )}

        {/* Quick Contact */}
        <section className="py-12 md:py-16 bg-gradient-to-br from-neutral-900 to-neutral-800 text-white">
          <Container>
            <AnimatedSection className="max-w-3xl mx-auto text-center space-y-6">
              <h2 className="text-3xl md:text-4xl font-bold">
                Hemen İletişime Geçin
              </h2>
              <p className="text-base md:text-lg text-neutral-300">
                Randevu almak veya sorularınız için bize ulaşın
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" variant="premium" asChild>
                  <a href={`tel:${settings?.phone1?.replace(/\s/g, '') || '02164724628'}`}>
                    <Phone className="mr-2 h-5 w-5" />
                    {settings?.phone1 || '0216 472 46 28'}
                  </a>
                </Button>
                <Button size="lg" variant="outline" className="border-white text-white hover:bg-white/10" asChild>
                  <a href={`tel:${settings?.phone2?.replace(/\s/g, '') || '05302285603'}`}>
                    <Phone className="mr-2 h-5 w-5" />
                    {settings?.phone2 || '0530 228 56 03'}
                  </a>
                </Button>
                <Button size="lg" variant="outline" className="border-white text-white hover:bg-white/10" asChild>
                  <a
                    href={`https://wa.me/${settings?.whatsapp || '905302285603'}`}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <MessageCircle className="mr-2 h-5 w-5" />
                    WhatsApp
                  </a>
                </Button>
              </div>
              <p className="text-sm text-neutral-400 mt-8">
                {settings?.address || 'Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul'}
              </p>
            </AnimatedSection>
          </Container>
        </section>
      </div>
    </>
  )
}
