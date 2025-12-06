import { prisma } from "@/lib/prisma"
import { generatePageMetadata } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"

export async function generateMetadata() {
  return await generatePageMetadata(
    "Çerez Politikası - Foto Uğur",
    "Foto Uğur çerez politikası ve çerez kullanımı hakkında bilgiler.",
    "çerez politikası, cookie policy"
  )
}

export default async function CookiePolicyPage() {
  const page = await prisma.page.findUnique({
    where: { slug: 'cerez-politikasi' },
  })

  const defaultContent = `
    <h2>Çerez Politikası</h2>
    <p>Foto Uğur web sitesi, kullanıcı deneyimini iyileştirmek ve site performansını analiz etmek için çerezler kullanmaktadır.</p>
    <h3>Çerez Nedir?</h3>
    <p>Çerezler, web sitelerini ziyaret ettiğinizde tarayıcınızda saklanan küçük metin dosyalarıdır. Bu dosyalar, site deneyiminizi iyileştirmek ve site kullanımını analiz etmek için kullanılır.</p>
    <h3>Kullandığımız Çerezler</h3>
    <h4>Zorunlu Çerezler</h4>
    <p>Bu çerezler, web sitesinin temel işlevlerinin çalışması için gereklidir:</p>
    <ul>
      <li>Oturum yönetimi</li>
      <li>Güvenlik</li>
      <li>Form işlemleri</li>
    </ul>
    <h4>Analitik Çerezler</h4>
    <p>Bu çerezler, site kullanımını analiz etmek ve iyileştirmeler yapmak için kullanılır:</p>
    <ul>
      <li>Sayfa görüntüleme istatistikleri</li>
      <li>Kullanıcı davranış analizi</li>
    </ul>
    <h3>Çerez Yönetimi</h3>
    <p>Tarayıcı ayarlarınızdan çerezleri yönetebilir veya devre dışı bırakabilirsiniz. Ancak, bazı çerezlerin devre dışı bırakılması web sitesinin bazı özelliklerinin çalışmamasına neden olabilir.</p>
    <h3>Üçüncü Taraf Çerezler</h3>
    <p>Web sitemiz, analiz ve iyileştirme amaçlı üçüncü taraf hizmetler kullanabilir. Bu hizmetler kendi çerez politikalarına tabidir.</p>
  `

  return (
    <div className="bg-neutral-50">
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">
              {page?.title || "Çerez Politikası"}
            </h1>
          </AnimatedSection>
        </Container>
      </section>
      <section className="py-12 md:py-16">
        <Container size="md">
          <AnimatedSection>
            <div
              className="prose prose-lg max-w-none prose-headings:text-neutral-900 prose-p:text-neutral-600 prose-p:leading-relaxed"
              dangerouslySetInnerHTML={{
                __html: page?.content || defaultContent,
              }}
            />
          </AnimatedSection>
        </Container>
      </section>
    </div>
  )
}

