import Link from "next/link"
import { prisma } from "@/lib/prisma"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Image from "next/image"
import { generatePageMetadata } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { ArrowRight } from "lucide-react"
import { shouldUnoptimizeImage } from "@/lib/image-utils"

// Force dynamic rendering to always fetch fresh data
export const dynamic = 'force-dynamic'
export const revalidate = 0

export async function generateMetadata() {
  return await generatePageMetadata(
    "Hizmetlerimiz - Foto Uğur",
    "Profesyonel fotoğraf hizmetlerimiz. Dış çekim, düğün, ürün fotoğrafçılığı ve daha fazlası.",
    "hizmetler, fotoğraf hizmetleri, ataşehir fotoğrafçı"
  )
}

export default async function ServicesPage() {
  const services = await prisma.service.findMany({
    where: { isActive: true },
    orderBy: { order: 'asc' },
  })

  return (
    <div className="bg-neutral-50">
      {/* Hero Section */}
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center space-y-6">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">Hizmetlerimiz</h1>
            <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
              Profesyonel fotoğraf hizmetlerimizle hayatınızın özel anlarını ölümsüzleştirin
            </p>
          </AnimatedSection>
        </Container>
      </section>

      {/* Services Grid */}
      <section className="py-16 md:py-24">
        <Container>
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 lg:gap-8">
              {services.map((service, index) => (
                <AnimatedSection key={service.id} delay={index * 0.1}>
                  <Card className="h-full group cursor-pointer overflow-hidden rounded-3xl border border-neutral-200 bg-white shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all">
                  {service.featuredImage && (
                    <div className="relative h-48 w-full overflow-hidden">
                      <Image
                        src={service.featuredImage}
                        alt={`${service.title} - Foto Uğur ${service.category || 'hizmet'} örneği`}
                        fill
                        className="object-cover group-hover:scale-110 transition-transform duration-500"
                        unoptimized={shouldUnoptimizeImage(service.featuredImage)}
                      />
                    </div>
                  )}
                  <CardHeader>
                    {service.category && (
                      <span className="text-xs font-semibold text-amber-600 mb-2 inline-block">
                        {service.category}
                      </span>
                    )}
                    <CardTitle className="text-xl">{service.title}</CardTitle>
                    <CardDescription className="text-base">
                      {service.shortDescription}
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Button variant="outline" asChild className="w-full group-hover:border-amber-500 group-hover:text-amber-600">
                      <Link href={`/hizmetler/${service.slug}`}>
                        Detaylı İncele
                        <ArrowRight className="ml-2 h-4 w-4" />
                      </Link>
                    </Button>
                  </CardContent>
                </Card>
              </AnimatedSection>
            ))}
          </div>
        </Container>
      </section>
    </div>
  )
}
