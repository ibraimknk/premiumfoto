import { prisma } from "@/lib/prisma"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import { generatePageMetadata, generateFAQSchema } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"

// Force dynamic rendering to always fetch fresh data
export const dynamic = 'force-dynamic'
export const revalidate = 0

export async function generateMetadata() {
  return await generatePageMetadata(
    "Sıkça Sorulan Sorular - Foto Uğur",
    "Fotoğraf hizmetlerimiz hakkında sıkça sorulan sorular ve cevapları.",
    "sss, sorular, cevaplar, fotoğraf hizmetleri"
  )
}

export default async function FAQPage() {
  const faqs = await prisma.fAQ.findMany({
    where: { isActive: true },
    orderBy: { order: 'asc' },
  })

  const faqSchema = generateFAQSchema(
    faqs.map((faq) => ({
      question: faq.question,
      answer: faq.answer,
    }))
  )

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqSchema) }}
      />
      <div className="bg-neutral-50">
        {/* Hero Section */}
        <section className="py-16 md:py-24 bg-white border-b">
          <Container>
            <AnimatedSection className="text-center space-y-6">
              <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">
                Sıkça Sorulan Sorular
              </h1>
              <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
                Merak ettiğiniz soruların yanıtları
              </p>
            </AnimatedSection>
          </Container>
        </section>

        {/* FAQ Content */}
        <section className="py-16 md:py-24">
          <Container size="md">
            <AnimatedSection>
              <Accordion type="single" collapsible className="w-full space-y-4">
                {faqs.map((faq, index) => (
                  <AccordionItem
                    key={faq.id}
                    value={faq.id}
                    className="border border-neutral-200 rounded-2xl px-6 bg-white hover:border-amber-300 transition-colors"
                  >
                    <AccordionTrigger className="text-left text-lg font-semibold text-neutral-900 hover:no-underline py-6">
                      {faq.question}
                    </AccordionTrigger>
                    <AccordionContent className="pb-6">
                      <div
                        className="prose max-w-none prose-p:text-neutral-600 prose-p:leading-relaxed"
                        dangerouslySetInnerHTML={{ __html: faq.answer }}
                      />
                    </AccordionContent>
                  </AccordionItem>
                ))}
              </Accordion>
            </AnimatedSection>

            {faqs.length === 0 && (
              <div className="text-center py-12">
                <p className="text-neutral-500">Henüz SSS içeriği eklenmemiş.</p>
              </div>
            )}
          </Container>
        </section>
      </div>
    </>
  )
}
