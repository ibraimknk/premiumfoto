import { prisma } from "@/lib/prisma"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Phone, Mail, MapPin, Clock, MessageCircle } from "lucide-react"
import { ContactForm } from "@/components/features/ContactForm"
import { generatePageMetadata } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"

export async function generateMetadata() {
  return await generatePageMetadata(
    "İletişim - Foto Uğur",
    "Randevu almak veya sorularınız için bize ulaşın. Ataşehir, İstanbul.",
    "iletişim, randevu, ataşehir fotoğrafçı"
  )
}

export default async function ContactPage() {
  const settings = await prisma.siteSetting.findFirst()

  return (
    <div className="bg-neutral-50">
      {/* Hero Section */}
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center space-y-6">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">İletişim</h1>
            <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
              Randevu almak veya sorularınız için bize ulaşın
            </p>
          </AnimatedSection>
        </Container>
      </section>

      {/* Contact Content */}
      <section className="py-16 md:py-24">
        <Container>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
            {/* Contact Form */}
            <AnimatedSection>
              <Card>
                <CardHeader>
                  <CardTitle className="text-2xl">Bize Yazın</CardTitle>
                </CardHeader>
                <CardContent>
                  <ContactForm />
                </CardContent>
              </Card>
            </AnimatedSection>

            {/* Contact Info */}
            <AnimatedSection delay={0.2}>
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-2xl">İletişim Bilgileri</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div className="flex items-start space-x-4">
                      <div className="w-12 h-12 rounded-xl bg-amber-100 flex items-center justify-center flex-shrink-0">
                        <MapPin className="h-6 w-6 text-amber-600" />
                      </div>
                      <div>
                        <p className="font-semibold text-neutral-900 mb-1">Adres</p>
                        <p className="text-neutral-600 leading-relaxed">
                          {settings?.address || 'Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul'}
                        </p>
                      </div>
                    </div>

                    <div className="flex items-start space-x-4">
                      <div className="w-12 h-12 rounded-xl bg-amber-100 flex items-center justify-center flex-shrink-0">
                        <Phone className="h-6 w-6 text-amber-600" />
                      </div>
                      <div>
                        <p className="font-semibold text-neutral-900 mb-2">Telefon</p>
                        <div className="space-y-2">
                          <a
                            href={`tel:${settings?.phone1?.replace(/\s/g, '') || '02164724628'}`}
                            className="block text-neutral-600 hover:text-amber-600 transition-colors"
                          >
                            {settings?.phone1 || '0216 472 46 28'}
                          </a>
                          <a
                            href={`tel:${settings?.phone2?.replace(/\s/g, '') || '05302285603'}`}
                            className="block text-neutral-600 hover:text-amber-600 transition-colors"
                          >
                            {settings?.phone2 || '0530 228 56 03'}
                          </a>
                        </div>
                      </div>
                    </div>

                    {settings?.email && (
                      <div className="flex items-start space-x-4">
                        <div className="w-12 h-12 rounded-xl bg-amber-100 flex items-center justify-center flex-shrink-0">
                          <Mail className="h-6 w-6 text-amber-600" />
                        </div>
                        <div>
                          <p className="font-semibold text-neutral-900 mb-1">E-posta</p>
                          <a
                            href={`mailto:${settings.email}`}
                            className="text-neutral-600 hover:text-amber-600 transition-colors"
                          >
                            {settings.email}
                          </a>
                        </div>
                      </div>
                    )}

                    {settings?.workingHours && (
                      <div className="flex items-start space-x-4">
                        <div className="w-12 h-12 rounded-xl bg-amber-100 flex items-center justify-center flex-shrink-0">
                          <Clock className="h-6 w-6 text-amber-600" />
                        </div>
                        <div>
                          <p className="font-semibold text-neutral-900 mb-1">Çalışma Saatleri</p>
                          <p className="text-neutral-600">{settings.workingHours}</p>
                        </div>
                      </div>
                    )}

                    <div className="pt-4">
                      <Button size="lg" variant="premium" asChild className="w-full">
                        <a
                          href={`https://wa.me/${settings?.whatsapp || '905302285603'}`}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <MessageCircle className="mr-2 h-5 w-5" />
                          WhatsApp ile Mesaj Gönder
                        </a>
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </div>

              {/* Map Placeholder */}
              <Card className="mt-6">
                <CardHeader>
                  <CardTitle>Konum</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="aspect-video bg-neutral-100 rounded-xl flex items-center justify-center">
                    <p className="text-neutral-400">Harita buraya eklenecek</p>
                  </div>
                </CardContent>
              </Card>
            </AnimatedSection>
          </div>
        </Container>
      </section>
    </div>
  )
}
