import Link from "next/link"
import { prisma } from "@/lib/prisma"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Image from "next/image"
import { generatePageMetadata, generateServiceListSchema } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { ArrowRight, Camera, Heart, Package, Users, MessageCircle, CheckCircle2, Star } from "lucide-react"
import { shouldUnoptimizeImage } from "@/lib/image-utils"
import { BreadcrumbNav } from "@/components/features/BreadcrumbNav"

// Force dynamic rendering to always fetch fresh data
export const dynamic = 'force-dynamic'
export const revalidate = 0

export async function generateMetadata() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"
  return await generatePageMetadata(
    "Profesyonel Fotoğraf Hizmetleri - Foto Uğur | Ataşehir Fotoğrafçı | Düğün, Dış Mekan, Ürün Çekimi",
    "Foto Uğur olarak Ataşehir ve İstanbul'da 1997'den beri profesyonel fotoğraf hizmetleri sunuyoruz. Düğün fotoğrafçılığı, dış mekan çekimi, ürün fotoğrafçılığı, stüdyo çekimi, vesikalık ve biyometrik fotoğraf, sosyal medya içerikleri. Uzman ekibimiz ve modern ekipmanlarımızla hayatınızın özel anlarını ölümsüzleştiriyoruz.",
    "fotoğraf hizmetleri, ataşehir fotoğrafçı, istanbul fotoğrafçı, düğün fotoğrafçısı, dış mekan çekimi, ürün fotoğrafçılığı, stüdyo çekimi, vesikalık fotoğraf, biyometrik fotoğraf, sosyal medya içerikleri, profesyonel fotoğrafçı, foto uğur, uğur fotoğrafçılık",
    undefined,
    `${baseUrl}/hizmetler`
  )
}

export default async function ServicesPage() {
  const services = await prisma.service.findMany({
    where: { isActive: true },
    orderBy: { order: 'asc' },
  })

  const serviceListSchema = generateServiceListSchema(
    services.map((s) => ({
      title: s.title,
      slug: s.slug,
      description: s.shortDescription || s.description || "",
    }))
  )

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(serviceListSchema) }}
      />
      <div className="bg-neutral-50">
      {/* Hero Section */}
      <section className="py-16 md:py-24 bg-gradient-to-br from-white via-amber-50/30 to-white border-b">
        <Container>
          <AnimatedSection className="text-center space-y-6">
            <BreadcrumbNav
              items={[
                { name: 'Ana Sayfa', url: '/' },
                { name: 'Hizmetlerimiz', url: '/hizmetler' },
              ]}
            />
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-neutral-900 leading-tight">
              Profesyonel Fotoğraf Hizmetlerimiz
            </h1>
            <p className="text-xl md:text-2xl text-neutral-600 max-w-4xl mx-auto leading-relaxed">
              1997&apos;den beri Ataşehir ve İstanbul&apos;da profesyonel fotoğraf hizmetleri sunuyoruz. Düğün fotoğrafçılığından ürün çekimine, stüdyo çekiminden sosyal medya içeriklerine kadar geniş bir yelpazede hizmet veriyoruz.
            </p>
            <div className="flex flex-wrap justify-center gap-4 mt-8">
              <div className="flex items-center gap-2 text-neutral-700">
                <CheckCircle2 className="h-5 w-5 text-amber-600" />
                <span className="text-sm font-medium">25+ Yıllık Deneyim</span>
              </div>
              <div className="flex items-center gap-2 text-neutral-700">
                <CheckCircle2 className="h-5 w-5 text-amber-600" />
                <span className="text-sm font-medium">1000+ Mutlu Müşteri</span>
              </div>
              <div className="flex items-center gap-2 text-neutral-700">
                <CheckCircle2 className="h-5 w-5 text-amber-600" />
                <span className="text-sm font-medium">Profesyonel Ekipman</span>
              </div>
            </div>
          </AnimatedSection>
        </Container>
      </section>

      {/* Services Grid */}
      <section className="py-16 md:py-24">
        <Container>
          <div className="mb-12 text-center">
            <h2 className="text-3xl md:text-4xl font-bold text-neutral-900 mb-4">
              Tüm Hizmetlerimiz
            </h2>
            <p className="text-lg text-neutral-600 max-w-3xl mx-auto">
              Her ihtiyaca uygun profesyonel fotoğraf hizmetleri. Modern ekipmanlar ve uzman ekibimizle yanınızdayız.
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 lg:gap-8">
            {services.map((service, index) => {
              // Icon mapping
              const iconMap: { [key: string]: typeof Camera } = {
                'Dış Mekan Çekimi': Camera,
                'Düğün Fotoğrafçılığı': Heart,
                'Ürün Fotoğrafçılığı': Package,
                'Stüdyo Çekimi': Users,
                'Vesikalık & Biyometrik': Users,
                'Sosyal Medya İçerikleri': MessageCircle,
              }
              
              const ServiceIcon = iconMap[service.title] || Camera
              const description = service.shortDescription || 'Profesyonel fotoğraf hizmeti'
              
              return (
                <AnimatedSection key={service.id} delay={index * 0.1}>
                  <Card className="h-full group cursor-pointer overflow-hidden rounded-3xl border-2 border-neutral-200 bg-white shadow-sm hover:shadow-xl hover:border-amber-400 hover:-translate-y-2 transition-all duration-300">
                    {service.featuredImage && (
                      <div className="relative h-56 w-full overflow-hidden bg-neutral-100">
                        <Image
                          src={service.featuredImage}
                          alt={`${service.title} - Ataşehir fotoğrafçı Foto Uğur ${service.category || 'hizmet'} örneği | Uğur Fotoğrafçılık`}
                          fill
                          className="object-cover group-hover:scale-110 transition-transform duration-700"
                          unoptimized={shouldUnoptimizeImage(service.featuredImage)}
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                      </div>
                    )}
                    <CardHeader className="p-6">
                      <div className="flex items-start justify-between mb-3">
                        {service.category && (
                          <span className="text-xs font-semibold text-amber-600 bg-amber-50 px-3 py-1 rounded-full">
                            {service.category}
                          </span>
                        )}
                        <div className="p-2 bg-amber-100 rounded-lg group-hover:bg-amber-200 transition-colors">
                          <ServiceIcon className="h-5 w-5 text-amber-600" />
                        </div>
                      </div>
                      <CardTitle className="text-2xl font-bold text-neutral-900 mb-3 group-hover:text-amber-600 transition-colors">
                        {service.title}
                      </CardTitle>
                      <CardDescription className="text-base text-neutral-600 leading-relaxed line-clamp-3">
                        {description}
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="p-6 pt-0">
                      <div className="space-y-4">
                        <div className="flex items-center gap-2 text-sm text-neutral-500">
                          <Star className="h-4 w-4 text-amber-500 fill-amber-500" />
                          <span>Profesyonel Ekipman</span>
                        </div>
                        <Button variant="premium" asChild className="w-full group-hover:scale-105 transition-transform">
                          <Link href={`/hizmetler/${service.slug}`}>
                            Detaylı İncele
                            <ArrowRight className="ml-2 h-4 w-4 group-hover:translate-x-1 transition-transform" />
                          </Link>
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                </AnimatedSection>
              )
            })}
          </div>
        </Container>
      </section>

      {/* Why Choose Us Section */}
      <section className="py-16 md:py-24 bg-white">
        <Container>
          <AnimatedSection className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-neutral-900 mb-4">
              Neden Foto Uğur?
            </h2>
            <p className="text-lg text-neutral-600 max-w-3xl mx-auto">
              25 yıllık deneyimimiz ve müşteri memnuniyeti odaklı yaklaşımımızla fark yaratıyoruz
            </p>
          </AnimatedSection>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <AnimatedSection delay={0.1} className="text-center p-6 rounded-2xl bg-neutral-50 hover:bg-amber-50 transition-colors">
              <div className="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Camera className="h-8 w-8 text-amber-600" />
              </div>
              <h3 className="text-xl font-bold text-neutral-900 mb-2">Modern Ekipman</h3>
              <p className="text-neutral-600 text-sm">
                En son teknoloji fotoğraf makineleri ve profesyonel ekipmanlarla çalışıyoruz
              </p>
            </AnimatedSection>
            
            <AnimatedSection delay={0.2} className="text-center p-6 rounded-2xl bg-neutral-50 hover:bg-amber-50 transition-colors">
              <div className="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Star className="h-8 w-8 text-amber-600 fill-amber-600" />
              </div>
              <h3 className="text-xl font-bold text-neutral-900 mb-2">25+ Yıl Deneyim</h3>
              <p className="text-neutral-600 text-sm">
                1997&apos;den beri binlerce mutlu müşteriye hizmet verdik
              </p>
            </AnimatedSection>
            
            <AnimatedSection delay={0.3} className="text-center p-6 rounded-2xl bg-neutral-50 hover:bg-amber-50 transition-colors">
              <div className="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Heart className="h-8 w-8 text-amber-600" />
              </div>
              <h3 className="text-xl font-bold text-neutral-900 mb-2">Müşteri Memnuniyeti</h3>
              <p className="text-neutral-600 text-sm">
                Her projede %100 müşteri memnuniyeti hedefliyoruz
              </p>
            </AnimatedSection>
            
            <AnimatedSection delay={0.4} className="text-center p-6 rounded-2xl bg-neutral-50 hover:bg-amber-50 transition-colors">
              <div className="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 className="h-8 w-8 text-amber-600" />
              </div>
              <h3 className="text-xl font-bold text-neutral-900 mb-2">Hızlı Teslimat</h3>
              <p className="text-neutral-600 text-sm">
                Profesyonel düzenleme ve hızlı teslimat garantisi
              </p>
            </AnimatedSection>
          </div>
        </Container>
      </section>

      {/* Service Categories Section */}
      <section className="py-16 md:py-24 bg-neutral-50">
        <Container>
          <AnimatedSection className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-neutral-900 mb-4">
              Hizmet Kategorilerimiz
            </h2>
            <p className="text-lg text-neutral-600 max-w-3xl mx-auto">
              Geniş hizmet yelpazemizle her ihtiyaca uygun çözümler sunuyoruz
            </p>
          </AnimatedSection>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <Card className="p-6 border-2 border-neutral-200 hover:border-amber-400 transition-colors">
              <div className="flex items-center gap-4 mb-4">
                <div className="p-3 bg-amber-100 rounded-lg">
                  <Camera className="h-6 w-6 text-amber-600" />
                </div>
                <h3 className="text-xl font-bold text-neutral-900">Çekim Hizmetleri</h3>
              </div>
              <p className="text-neutral-600 text-sm leading-relaxed mb-4">
                Dış mekan çekimi, stüdyo çekimi ve özel gün çekimleri. Doğal ışık ve kontrollü stüdyo ortamında profesyonel fotoğraf çekimi hizmetleri.
              </p>
              <ul className="space-y-2 text-sm text-neutral-600">
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Dış Mekan Çekimi</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Stüdyo Çekimi</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Düğün Fotoğrafçılığı</span>
                </li>
              </ul>
            </Card>
            
            <Card className="p-6 border-2 border-neutral-200 hover:border-amber-400 transition-colors">
              <div className="flex items-center gap-4 mb-4">
                <div className="p-3 bg-amber-100 rounded-lg">
                  <Package className="h-6 w-6 text-amber-600" />
                </div>
                <h3 className="text-xl font-bold text-neutral-900">Ticari Hizmetler</h3>
              </div>
              <p className="text-neutral-600 text-sm leading-relaxed mb-4">
                E-ticaret, katalog ve sosyal medya için profesyonel ürün fotoğrafçılığı ve içerik üretimi hizmetleri.
              </p>
              <ul className="space-y-2 text-sm text-neutral-600">
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Ürün Fotoğrafçılığı</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Sosyal Medya İçerikleri</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Katalog Çekimi</span>
                </li>
              </ul>
            </Card>
            
            <Card className="p-6 border-2 border-neutral-200 hover:border-amber-400 transition-colors">
              <div className="flex items-center gap-4 mb-4">
                <div className="p-3 bg-amber-100 rounded-lg">
                  <Users className="h-6 w-6 text-amber-600" />
                </div>
                <h3 className="text-xl font-bold text-neutral-900">Resmi Hizmetler</h3>
              </div>
              <p className="text-neutral-600 text-sm leading-relaxed mb-4">
                Pasaport, kimlik ve resmi belgeler için uygun vesikalık ve biyometrik fotoğraf çekimi hizmetleri.
              </p>
              <ul className="space-y-2 text-sm text-neutral-600">
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Vesikalık Fotoğraf</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Biyometrik Fotoğraf</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-amber-600" />
                  <span>Pasaport Fotoğrafı</span>
                </li>
              </ul>
            </Card>
          </div>
        </Container>
      </section>

      {/* CTA Section */}
      <section className="py-16 md:py-24 bg-gradient-to-br from-amber-50 to-white">
        <Container>
          <AnimatedSection className="text-center max-w-3xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold text-neutral-900 mb-4">
              Hizmetlerimiz Hakkında Daha Fazla Bilgi Alın
            </h2>
            <p className="text-lg text-neutral-600 mb-8">
              Profesyonel fotoğraf hizmetlerimiz hakkında detaylı bilgi almak veya randevu oluşturmak için bizimle iletişime geçin. Size en uygun çözümü birlikte belirleyelim.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button size="lg" variant="premium" asChild>
                <Link href="/iletisim">
                  Randevu Al
                  <ArrowRight className="ml-2 h-5 w-5" />
                </Link>
              </Button>
              <Button size="lg" variant="outline" asChild>
                <Link href="/galeri">
                  Çalışmalarımızı İncele
                </Link>
              </Button>
            </div>
          </AnimatedSection>
        </Container>
      </section>
    </div>
    </>
  )
}
