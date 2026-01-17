import Link from "next/link"
import { generatePageMetadata } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { MapPin, ArrowRight } from "lucide-react"

export async function generateMetadata() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"
  const canonicalUrl = `${baseUrl}/lokasyon`

  return generatePageMetadata(
    "Lokasyonlar - Foto Uğur | Ataşehir ve İstanbul Fotoğraf Hizmetleri",
    "Ataşehir ve İstanbul bölgelerinde profesyonel fotoğraf hizmetleri. Düğün, dış mekan, ürün fotoğrafçılığı.",
    "ataşehir fotoğrafçı, istanbul fotoğrafçı, lokasyon",
    undefined,
    canonicalUrl
  )
}

const LOCATIONS = [
  {
    slug: "atasehir",
    name: "Ataşehir",
    description: "Ataşehir'de profesyonel fotoğraf hizmetleri sunuyoruz. Düğün fotoğrafçılığı, dış mekan çekimi ve daha fazlası.",
    address: "Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul",
  },
  {
    slug: "istanbul",
    name: "İstanbul",
    description: "İstanbul genelinde profesyonel fotoğraf hizmetleri. Tüm ilçelerde hizmet veriyoruz.",
    address: "Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul",
  },
]

export default function LocationsPage() {
  return (
    <div className="bg-neutral-50">
      {/* Hero Section */}
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center space-y-6">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">
              Hizmet Verdiğimiz Lokasyonlar
            </h1>
            <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
              Ataşehir ve İstanbul bölgelerinde profesyonel fotoğraf hizmetleri sunuyoruz
            </p>
          </AnimatedSection>
        </Container>
      </section>

      {/* Locations Grid */}
      <section className="py-16 md:py-24">
        <Container>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {LOCATIONS.map((location, index) => (
              <AnimatedSection key={location.slug} delay={index * 0.1}>
                <Card className="h-full hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex items-center mb-4">
                      <MapPin className="h-6 w-6 mr-2 text-amber-600" />
                      <CardTitle className="text-2xl">{location.name}</CardTitle>
                    </div>
                    <p className="text-neutral-600 mb-4">{location.description}</p>
                    <div className="flex items-start text-sm text-neutral-500">
                      <MapPin className="h-4 w-4 mr-2 mt-1 flex-shrink-0" />
                      <span>{location.address}</span>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <Button variant="premium" asChild className="w-full">
                      <Link href={`/lokasyon/${location.slug}`}>
                        {location.name} Hizmetlerimiz
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

