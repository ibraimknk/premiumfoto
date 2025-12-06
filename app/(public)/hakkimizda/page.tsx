import { prisma } from "@/lib/prisma"
import { formatDate } from "@/lib/utils"
import { Calendar, Camera, Globe, Users, Award, Target, Heart } from "lucide-react"
import { generatePageMetadata } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { Card, CardContent } from "@/components/ui/card"
import Image from "next/image"

export async function generateMetadata() {
  const page = await prisma.page.findUnique({
    where: { slug: 'hakkimizda' },
  })

  return await generatePageMetadata(
    page?.seoTitle || "Hakkımızda - Foto Uğur",
    page?.seoDescription || "1997'den beri Ataşehir'de profesyonel fotoğraf hizmetleri sunan Foto Uğur'un hikayesi.",
    page?.seoKeywords || "hakkımızda, foto uğur, ataşehir fotoğraf stüdyosu"
  )
}

export default async function AboutPage() {
  const page = await prisma.page.findUnique({
    where: { slug: 'hakkimizda' },
  })

  const timeline = [
    {
      year: '1997',
      title: 'Kuruluş',
      description: 'Foto Uğur, Ataşehir\'de klasik karanlık oda döneminde faaliyet göstermeye başladı.',
      icon: Calendar,
    },
    {
      year: '2005',
      title: 'Dijital Dönüşüm',
      description: 'Web sitemiz ile çevrimiçi dünyadaki yerimizi aldık ve dijital hizmetlerimizi geliştirdik.',
      icon: Globe,
    },
    {
      year: '2010',
      title: 'Genişleyen Hizmetler',
      description: 'Dış mekan fotoğrafçılığı ve yeni hizmet alanlarıyla hizmet yelpazemizi genişlettik.',
      icon: Camera,
    },
    {
      year: 'Bugün',
      title: 'Premium Stüdyo',
      description: 'Modern ekipmanlar ve geniş hizmet yelpazesiyle profesyonel fotoğraf hizmetleri sunuyoruz.',
      icon: Users,
    },
  ]

  const values = [
    {
      icon: Target,
      title: 'Teknoloji',
      description: 'Sürekli güncellenen modern ekipmanlar ve dijital çözümlerle hizmet veriyoruz.',
    },
    {
      icon: Heart,
      title: 'Güven',
      description: '27 yıllık deneyimimizle müşterilerimizin güvenini kazanmayı ön planda tutuyoruz.',
    },
    {
      icon: Award,
      title: 'Estetik Bakış',
      description: 'Fotoğrafçılığı bir zanaat ve estetik bakış açısının birleşimi olarak görüyoruz.',
    },
    {
      icon: Users,
      title: 'Müşteri Memnuniyeti',
      description: 'Her projeye aynı özen ve heyecanla yaklaşıyor, kaliteli hizmet sunuyoruz.',
    },
  ]

  return (
    <div className="bg-neutral-50">
      {/* Hero Section */}
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center space-y-6">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">
              {page?.title || 'Hakkımızda'}
            </h1>
            <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
              1997&apos;den beri Ataşehir&apos;de profesyonel fotoğraf hizmetleri sunuyoruz
            </p>
          </AnimatedSection>
        </Container>
      </section>

      {/* Content Section */}
      {page?.content && (
        <section className="py-16 md:py-24 bg-white">
          <Container>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-start">
              <AnimatedSection>
                <div
                  className="prose prose-lg max-w-none prose-headings:text-neutral-900 prose-headings:font-bold prose-h2:text-2xl prose-h2:mt-8 prose-h2:mb-4 prose-h3:text-xl prose-h3:mt-6 prose-h3:mb-3 prose-p:text-neutral-600 prose-p:leading-relaxed prose-p:mb-4 prose-ul:list-disc prose-ul:ml-6 prose-ul:mb-4 prose-li:mb-2"
                  dangerouslySetInnerHTML={{ __html: page.content }}
                />
              </AnimatedSection>
              <AnimatedSection delay={0.2}>
                <div className="space-y-4">
                  <div className="relative aspect-[4/3] rounded-3xl overflow-hidden shadow-xl">
                    <div className="absolute inset-0 bg-gradient-to-br from-neutral-200 to-neutral-300 flex items-center justify-center">
                      <Camera className="h-24 w-24 text-neutral-400" />
                    </div>
                  </div>
                  <div className="relative aspect-[4/3] rounded-3xl overflow-hidden shadow-xl -mt-8 ml-8">
                    <div className="absolute inset-0 bg-gradient-to-br from-amber-100 to-amber-200 flex items-center justify-center">
                      <Users className="h-24 w-24 text-amber-600 opacity-30" />
                    </div>
                  </div>
                </div>
              </AnimatedSection>
            </div>
          </Container>
        </section>
      )}

      {/* Timeline */}
      <section className="py-16 md:py-24 bg-neutral-50">
        <Container>
          <AnimatedSection className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-neutral-900">Yolculuğumuz</h2>
            <p className="text-lg text-neutral-600">27 yıllık deneyimimizin kilometre taşları</p>
          </AnimatedSection>
          
          <div className="relative">
            <div className="absolute left-1/2 transform -translate-x-1/2 w-1 h-full bg-gradient-to-b from-amber-500 to-amber-600 hidden lg:block" />
            <div className="space-y-12 lg:space-y-16">
              {timeline.map((item, index) => {
                const Icon = item.icon
                return (
                  <AnimatedSection key={index} delay={index * 0.1}>
                    <div className={`flex items-center ${
                      index % 2 === 0 ? 'lg:flex-row' : 'lg:flex-row-reverse'
                    } flex-col lg:relative`}>
                      <div className="lg:w-1/2 mb-6 lg:mb-0">
                        <Card>
                          <CardContent className="p-6">
                            <div className="flex items-center space-x-4 mb-4">
                              <div className="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center">
                                <Icon className="h-6 w-6 text-amber-600" />
                              </div>
                              <span className="text-3xl font-bold text-amber-600">{item.year}</span>
                            </div>
                            <h3 className="text-xl font-semibold mb-2 text-neutral-900">{item.title}</h3>
                            <p className="text-neutral-600 leading-relaxed">{item.description}</p>
                          </CardContent>
                        </Card>
                      </div>
                      <div className="absolute left-1/2 transform -translate-x-1/2 w-4 h-4 bg-amber-500 rounded-full border-4 border-white z-10 hidden lg:block shadow-lg" />
                      <div className="lg:w-1/2" />
                    </div>
                  </AnimatedSection>
                )
              })}
            </div>
          </div>
        </Container>
      </section>

      {/* Values */}
      <section className="py-16 md:py-24 bg-white">
        <Container>
          <AnimatedSection className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-neutral-900">Değerlerimiz</h2>
            <p className="text-lg text-neutral-600">Çalışma prensiplerimiz</p>
          </AnimatedSection>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {values.map((value, index) => {
              const Icon = value.icon
              return (
                <AnimatedSection key={index} delay={index * 0.1}>
                  <Card className="h-full text-center">
                    <CardContent className="p-6">
                      <div className="w-16 h-16 rounded-2xl bg-amber-100 flex items-center justify-center mx-auto mb-4">
                        <Icon className="h-8 w-8 text-amber-600" />
                      </div>
                      <h3 className="text-xl font-semibold mb-3 text-neutral-900">{value.title}</h3>
                      <p className="text-neutral-600 leading-relaxed">{value.description}</p>
                    </CardContent>
                  </Card>
                </AnimatedSection>
              )
            })}
          </div>
        </Container>
      </section>

      {/* Stats */}
      <section className="py-16 md:py-24 bg-gradient-to-br from-neutral-900 to-neutral-800 text-white">
        <Container>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {[
              { number: '27+', label: 'Yıllık Deneyim' },
              { number: '1000+', label: 'Mutlu Müşteri' },
              { number: '500+', label: 'Tamamlanan Proje' },
              { number: '6', label: 'Hizmet Alanı' },
            ].map((stat, index) => (
              <AnimatedSection key={index} delay={index * 0.1} className="text-center">
                <div className="text-4xl md:text-5xl font-bold text-amber-500 mb-2">{stat.number}</div>
                <div className="text-neutral-300">{stat.label}</div>
              </AnimatedSection>
            ))}
          </div>
        </Container>
      </section>
    </div>
  )
}
