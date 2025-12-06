import { prisma } from "@/lib/prisma"
import { generatePageMetadata } from "@/lib/seo"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"

export async function generateMetadata() {
  return await generatePageMetadata(
    "KVKK Aydınlatma Metni - Foto Uğur",
    "Foto Uğur Kişisel Verilerin Korunması Kanunu (KVKK) aydınlatma metni.",
    "kvkk, kişisel verilerin korunması, gizlilik"
  )
}

export default async function KVKKPage() {
  const page = await prisma.page.findUnique({
    where: { slug: 'kvkk' },
  })

  const defaultContent = `
    <h2>Kişisel Verilerin Korunması Kanunu (KVKK) Aydınlatma Metni</h2>
    <p>Foto Uğur olarak, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") kapsamında, kişisel verilerinizin korunmasına ilişkin aydınlatma yükümlülüğümüzü yerine getirmek amacıyla bu metni hazırlamış bulunmaktayız.</p>
    <h3>Veri Sorumlusu</h3>
    <p>Foto Uğur, kişisel verilerinizin işlenmesinde veri sorumlusu sıfatına haizdir.</p>
    <h3>İşlenen Kişisel Veriler</h3>
    <p>İletişim formu, randevu talepleri ve hizmet süreçleri kapsamında aşağıdaki kişisel verileriniz işlenmektedir:</p>
    <ul>
      <li>Kimlik bilgileri (ad, soyad)</li>
      <li>İletişim bilgileri (telefon, e-posta, adres)</li>
      <li>Hizmet talebi bilgileri</li>
    </ul>
    <h3>Kişisel Verilerin İşlenme Amaçları</h3>
    <p>Kişisel verileriniz aşağıdaki amaçlarla işlenmektedir:</p>
    <ul>
      <li>Hizmet taleplerinizin karşılanması</li>
      <li>Randevu yönetimi</li>
      <li>İletişim ve bilgilendirme</li>
      <li>Yasal yükümlülüklerin yerine getirilmesi</li>
    </ul>
    <h3>Kişisel Verilerin Aktarımı</h3>
    <p>Kişisel verileriniz, yasal yükümlülüklerimiz ve hizmet sunumu kapsamında sınırlı olarak işlenmekte olup, üçüncü kişilerle paylaşılmamaktadır.</p>
    <h3>Haklarınız</h3>
    <p>KVKK'nın 11. maddesi uyarınca aşağıdaki haklara sahipsiniz:</p>
    <ul>
      <li>Kişisel verilerinizin işlenip işlenmediğini öğrenme</li>
      <li>İşlenmişse bilgi talep etme</li>
      <li>İşlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme</li>
      <li>Yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri bilme</li>
      <li>Eksik veya yanlış işlenmişse düzeltilmesini isteme</li>
      <li>İşlenmesini gerektiren sebeplerin ortadan kalkması halinde silinmesini veya yok edilmesini isteme</li>
    </ul>
    <p>Haklarınızı kullanmak için bizimle iletişime geçebilirsiniz.</p>
  `

  return (
    <div className="bg-neutral-50">
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">
              {page?.title || "KVKK Aydınlatma Metni"}
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

