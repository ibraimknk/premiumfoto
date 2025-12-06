import { prisma } from "@/lib/prisma"
import { generatePageMetadata } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"

export async function generateMetadata() {
  return await generatePageMetadata(
    "Gizlilik Politikası - Foto Uğur",
    "Foto Uğur gizlilik politikası ve kişisel verilerin korunması.",
    "gizlilik politikası, privacy policy"
  )
}

export default async function PrivacyPolicyPage() {
  const page = await prisma.page.findUnique({
    where: { slug: 'gizlilik-politikasi' },
  })

  const defaultContent = `
    <h2>Gizlilik Politikası</h2>
    <p>Foto Uğur olarak, gizliliğinize saygı gösteriyor ve kişisel bilgilerinizin korunmasına önem veriyoruz.</p>
    <h3>Toplanan Bilgiler</h3>
    <p>Web sitemiz üzerinden iletişim formu, randevu talepleri ve hizmet süreçleri kapsamında aşağıdaki bilgiler toplanabilir:</p>
    <ul>
      <li>Ad ve soyad</li>
      <li>E-posta adresi</li>
      <li>Telefon numarası</li>
      <li>Adres bilgileri</li>
      <li>Hizmet talebi detayları</li>
    </ul>
    <h3>Bilgilerin Kullanımı</h3>
    <p>Toplanan bilgiler aşağıdaki amaçlarla kullanılmaktadır:</p>
    <ul>
      <li>Hizmet taleplerinizin karşılanması</li>
      <li>Randevu yönetimi</li>
      <li>İletişim ve bilgilendirme</li>
      <li>Yasal yükümlülüklerin yerine getirilmesi</li>
    </ul>
    <h3>Bilgilerin Korunması</h3>
    <p>Kişisel bilgileriniz güvenli bir şekilde saklanmakta ve yalnızca yasal zorunluluklar ve hizmet sunumu kapsamında kullanılmaktadır.</p>
    <h3>Çerezler</h3>
    <p>Web sitemiz, kullanıcı deneyimini iyileştirmek için çerezler kullanmaktadır. Detaylı bilgi için Çerez Politikası sayfamızı ziyaret edebilirsiniz.</p>
    <h3>Değişiklikler</h3>
    <p>Bu gizlilik politikası zaman zaman güncellenebilir. Güncel versiyon her zaman bu sayfada yayınlanacaktır.</p>
  `

  return (
    <div className="bg-neutral-50">
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">
              {page?.title || "Gizlilik Politikası"}
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

