import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Seeding database...')

  // Create admin user
  const hashedPassword = await bcrypt.hash('admin123', 10)
  const admin = await prisma.user.upsert({
    where: { email: 'admin@fotougur.com' },
    update: {},
    create: {
      email: 'admin@fotougur.com',
      password: hashedPassword,
      name: 'Admin',
    },
  })
  console.log('✅ Admin user created')

  // Create site settings
  await prisma.siteSetting.upsert({
    where: { id: '1' },
    update: {},
    create: {
      id: '1',
      siteName: 'Foto Uğur',
      defaultTitle: 'Foto Uğur - Ataşehir Fotoğraf Stüdyosu',
      defaultDescription: 'Ataşehir\'de premium fotoğraf stüdyosu. Dış çekim, düğün, ürün fotoğrafçılığı ve profesyonel fotoğraf hizmetleri.',
      phone1: '0216 472 46 28',
      phone2: '0530 228 56 03',
      whatsapp: '905302285603',
      email: 'info@fotougur.com',
      address: 'Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul',
      workingHours: 'Pazartesi - Cumartesi: 09:00 - 19:00',
      primaryColor: '#000000',
      secondaryColor: '#D4AF37',
    },
  })
  console.log('✅ Site settings created')

  // Create services
  const services = [
    {
      title: 'Dış Mekan Çekimi',
      slug: 'dis-mekan-cekimi',
      shortDescription: 'Doğal ışık ve açık hava ortamında profesyonel fotoğraf çekimi',
      description: '<p>Dış mekan fotoğraf çekimi, doğal ışık ve çevrenin sunduğu imkanlarla yaratıcı ve etkileyici görüntüler elde etmenizi sağlar. İstanbul\'un en güzel lokasyonlarında, profesyonel ekipmanlarımızla size özel bir çekim deneyimi sunuyoruz.</p><p>Portre, aile, nişan, düğün öncesi çekimler ve kurumsal fotoğrafçılık hizmetlerimizle hayatınızın özel anlarını ölümsüzleştiriyoruz.</p>',
      category: 'Çekim Hizmetleri',
      seoTitle: 'Dış Mekan Fotoğraf Çekimi İstanbul | Foto Uğur',
      seoDescription: 'İstanbul\'da profesyonel dış mekan fotoğraf çekimi hizmeti. Doğal ışık, yaratıcı kompozisyon ve kaliteli sonuçlar.',
      seoKeywords: 'dış mekan fotoğraf çekimi istanbul, ataşehir fotoğrafçı, açık hava çekim',
    },
    {
      title: 'Düğün Fotoğrafçılığı',
      slug: 'dugun-fotografciligi',
      shortDescription: 'Hayatınızın en özel gününü ölümsüzleştirin',
      description: '<p>Düğününüz, hayatınızın en özel ve unutulmaz anlarından biridir. Bu özel günü en iyi şekilde yansıtan fotoğraflar için deneyimli ekibimizle yanınızdayız.</p><p>Nişan, düğün öncesi çekim, düğün günü ve nikah fotoğrafçılığı hizmetlerimizle, her anı profesyonelce kaydediyoruz.</p>',
      category: 'Özel Günler',
      seoTitle: 'İstanbul Düğün Fotoğrafçısı | Profesyonel Düğün Çekimi',
      seoDescription: 'İstanbul\'da profesyonel düğün fotoğrafçılığı hizmeti. Deneyimli ekibimizle özel gününüzü ölümsüzleştirin.',
      seoKeywords: 'istanbul düğün fotoğrafçısı, düğün fotoğrafçılığı ataşehir, profesyonel düğün çekimi',
    },
    {
      title: 'Ürün Fotoğrafçılığı',
      slug: 'urun-fotografciligi',
      shortDescription: 'E-ticaret ve katalog için profesyonel ürün fotoğrafları',
      description: '<p>E-ticaret siteniz veya kataloğunuz için yüksek kaliteli ürün fotoğrafları çekiyoruz. Profesyonel stüdyo ortamımızda, ürünlerinizi en iyi şekilde yansıtan görseller üretiyoruz.</p><p>Beyaz fon, yaşam alanı, detay çekimleri ve 360 derece görüntüleme seçenekleriyle hizmetinizdeyiz.</p>',
      category: 'Ticari Hizmetler',
      seoTitle: 'Ürün Fotoğrafı Çekimi İstanbul | E-Ticaret Fotoğrafçılığı',
      seoDescription: 'İstanbul\'da profesyonel ürün fotoğrafçılığı hizmeti. E-ticaret ve katalog için yüksek kaliteli görseller.',
      seoKeywords: 'ürün fotoğrafı çekimi istanbul, e-ticaret fotoğrafçılığı, katalog fotoğrafçılığı',
    },
    {
      title: 'Stüdyo Çekimi',
      slug: 'stuyo-cekimi',
      shortDescription: 'Kontrollü ışık ortamında profesyonel portre çekimi',
      description: '<p>Profesyonel stüdyo ortamımızda, kontrollü ışık koşullarında portre, kurumsal, vesikalık ve özel çekimler yapıyoruz.</p><p>Modern ekipmanlarımız ve deneyimli ekibimizle, istediğiniz görseli en iyi şekilde oluşturuyoruz.</p>',
      category: 'Çekim Hizmetleri',
      seoTitle: 'Stüdyo Fotoğraf Çekimi Ataşehir | Profesyonel Portre',
      seoDescription: 'Ataşehir\'de profesyonel stüdyo fotoğraf çekimi. Portre, kurumsal ve özel çekimler için modern stüdyo.',
      seoKeywords: 'stüdyo fotoğraf çekimi ataşehir, portre çekimi, profesyonel fotoğrafçı istanbul',
    },
    {
      title: 'Vesikalık & Biyometrik',
      slug: 'vesikalik-biyometrik',
      shortDescription: 'Resmi belgeler için uygun fotoğraf çekimi',
      description: '<p>Pasaport, kimlik, vize ve diğer resmi belgeler için uygun vesikalık ve biyometrik fotoğraf çekimi yapıyoruz.</p><p>Resmi standartlara uygun, dijital ve baskı formatında fotoğraflarınızı hızlıca hazırlıyoruz.</p>',
      category: 'Resmi Hizmetler',
      seoTitle: 'Vesikalık Fotoğraf Ataşehir | Biyometrik Fotoğraf Çekimi',
      seoDescription: 'Ataşehir\'de vesikalık ve biyometrik fotoğraf çekimi. Resmi belgeler için uygun, hızlı hizmet.',
      seoKeywords: 'vesikalık fotoğraf ataşehir, biyometrik fotoğraf, pasaport fotoğrafı',
    },
    {
      title: 'Sosyal Medya İçerikleri',
      slug: 'sosyal-medya-icerikleri',
      shortDescription: 'Markanız için profesyonel sosyal medya görselleri',
      description: '<p>Markanızın sosyal medya hesapları için profesyonel görsel içerikler üretiyoruz. Ürün tanıtımı, kurumsal içerik, reklam görselleri ve daha fazlası.</p><p>Güncel trendlere uygun, etkileyici ve marka kimliğinize uygun içerikler hazırlıyoruz.</p>',
      category: 'Ticari Hizmetler',
      seoTitle: 'Sosyal Medya İçerik Üretimi İstanbul | Profesyonel Görseller',
      seoDescription: 'İstanbul\'da sosyal medya için profesyonel görsel içerik üretimi. Markanız için etkileyici görseller.',
      seoKeywords: 'sosyal medya içerik üretimi, marka fotoğrafçılığı, reklam görselleri',
    },
  ]

  for (const service of services) {
    await prisma.service.upsert({
      where: { slug: service.slug },
      update: {},
      create: service,
    })
  }
  console.log('✅ Services created')

  // Create testimonials
  const testimonials = [
    {
      name: 'Ayşe Yılmaz',
      comment: 'Düğünümüz için harika bir deneyim yaşadık. Fotoğraflarımız muhteşem oldu, her anı yakaladılar.',
      serviceType: 'Düğün Fotoğrafçılığı',
      rating: 5,
      order: 1,
    },
    {
      name: 'Mehmet Demir',
      comment: 'Ürün fotoğraflarımız için çalıştık. E-ticaret sitemizde satışlarımız arttı. Çok memnun kaldık.',
      serviceType: 'Ürün Fotoğrafçılığı',
      rating: 5,
      order: 2,
    },
    {
      name: 'Zeynep Kaya',
      comment: 'Dış mekan çekimimiz harika geçti. Doğal ışık kullanımı ve kompozisyonlar mükemmeldi.',
      serviceType: 'Dış Mekan Çekimi',
      rating: 5,
      order: 3,
    },
    {
      name: 'Ali Çelik',
      comment: 'Profesyonel hizmet, zamanında teslimat ve kaliteli sonuçlar. Kesinlikle tavsiye ederim.',
      serviceType: 'Stüdyo Çekimi',
      rating: 5,
      order: 4,
    },
  ]

  for (const testimonial of testimonials) {
    await prisma.testimonial.create({
      data: testimonial,
    })
  }
  console.log('✅ Testimonials created')

  // Create FAQs
  const faqs = [
    {
      question: 'Randevu nasıl alabilirim?',
      answer: '<p>Randevu almak için bize telefon, WhatsApp veya iletişim formu üzerinden ulaşabilirsiniz. Size en uygun tarih ve saati belirleyerek randevunuzu oluşturuyoruz.</p>',
      order: 1,
    },
    {
      question: 'Çekim süresi ne kadar?',
      answer: '<p>Çekim süresi hizmet türüne göre değişmektedir. Portre çekimleri genellikle 1-2 saat, düğün çekimleri ise gün boyu sürmektedir. Detaylı bilgi için iletişime geçebilirsiniz.</p>',
      order: 2,
    },
    {
      question: 'Fotoğraflar ne zaman teslim edilir?',
      answer: '<p>Fotoğrafların teslim süresi çekim türüne ve miktarına göre değişmektedir. Genellikle 7-14 iş günü içinde düzenlenmiş fotoğraflarınızı dijital olarak teslim ediyoruz.</p>',
      order: 3,
    },
    {
      question: 'Hangi ödeme yöntemlerini kabul ediyorsunuz?',
      answer: '<p>Nakit, kredi kartı ve banka havalesi ile ödeme kabul ediyoruz. Ödeme planı hakkında detaylı bilgi için iletişime geçebilirsiniz.</p>',
      order: 4,
    },
    {
      question: 'Dış mekan çekimi için önerdiğiniz lokasyonlar var mı?',
      answer: '<p>İstanbul\'un birçok güzel lokasyonunda çekim yapıyoruz. Belgrad Ormanı, Emirgan Korusu, Bebek, Arnavutköy gibi popüler mekanların yanı sıra, sizin tercih ettiğiniz özel lokasyonlarda da çekim yapabiliriz.</p>',
      order: 5,
    },
    {
      question: 'Vesikalık fotoğraf için ne kadar süre gerekiyor?',
      answer: '<p>Vesikalık ve biyometrik fotoğraf çekimi yaklaşık 15-20 dakika sürmektedir. Aynı gün içinde dijital ve baskı formatında teslim edebiliyoruz.</p>',
      order: 6,
    },
  ]

  for (const faq of faqs) {
    await prisma.fAQ.create({
      data: faq,
    })
  }
  console.log('✅ FAQs created')

  // Create About page
  await prisma.page.upsert({
    where: { slug: 'hakkimizda' },
    update: {},
    create: {
      title: 'Hakkımızda',
      slug: 'hakkimizda',
      content: `<h2>Foto Uğur ve Uğur Fotoğrafçılık Hikayesi</h2>
      <p>Firmamız, 1997 yılında <strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong> adıyla Ataşehir'de faaliyet göstermeye başladı. Klasik karanlık oda döneminden dijital dünyaya uzanan yolculuğumuzda, fotoğrafçılığı her zaman bir zanaat ve estetik bakış açısının birleşimi olarak gördük.</p>
      <p>Fotoğrafçılık sektörüne ilk adımlarımızı, karanlık odada film banyo ederek ve baskı alarak attık. Ardından dijitalleşmenin hız kazandığı dönemde, bölgemizde termal baskı (bilgisayar kontrollü baskı sistemi) ile 20 dakikada express baskı hizmeti sunan öncü stüdyolardan biri olduk. Bu adım, <strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong>'ın teknolojiye ve yeniliğe verdiği önemin somut bir göstergesi haline geldi.</p>
      <p>Kurulduğumuz günden bu yana, yalnızca kaliteli fotoğraf üretmeyi değil, aynı zamanda müşterilerimizin güvenini ve memnuniyetini kazanmayı da ön planda tuttuk. Yıllar içerisinde binlerce kişi ve yüzlerce marka ile çalışarak, Ataşehir ve İstanbul genelinde güçlü ve samimi bir bağ oluşturduk.</p>
      <h3>2005 - Dijital Dönüşüm</h3>
      <p>2005 yılına gelindiğinde, internetin hayatın vazgeçilmez bir parçası haline gelmesiyle birlikte çevrimiçi dünyadaki yerimizi aldık ve web sitemiz üzerinden hem iletişim hem de dijital hizmetlerimizi geliştirdik.</p>
      <h3>2010 - Genişleyen Hizmet Yelpazesi</h3>
      <p>2010 yılı itibarıyla, hızla yükselen dış mekan fotoğrafçılığı trendiyle beraber hizmet yelpazemizi genişlettik. Bugün;</p>
      <ul>
        <li>dış mekan fotoğraf çekimi,</li>
        <li>stüdyo çekimleri,</li>
        <li>vesikalık ve biometrik fotoğraf,</li>
        <li>nişan ve düğün çekimleri,</li>
        <li>ürün ve katalog fotoğrafçılığı,</li>
        <li>kamera çekimleri,</li>
        <li>sosyal medya içerik üretimi</li>
      </ul>
      <p>gibi alanlarda profesyonel çözümler sunuyoruz.</p>
      <h3>Bugün</h3>
      <p><strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong> olarak, her projeye aynı özen ve heyecanla yaklaşırken, çağın gerektirdiği teknolojik donanımı da sürekli güncelliyoruz. Amacımız, yalnızca fotoğraf çekmek değil; sizin için değer taşıyan anları, markanızı veya hikâyenizi estetik ve kalıcı bir görsel dile dönüştürmek.</p>
      <p>Bugün Ataşehir'de, 1997'den bu yana edindiğimiz tecrübe, modern ekipmanlarımız ve dinamik bakış açımızla, siz değerli müşterilerimize güvenilir, kaliteli ve şeffaf bir hizmet sunmaya devam ediyoruz. <strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong> olarak gelecekte de aynı soruyu kendimize sormayı sürdüreceğiz:</p>
      <p><strong>"Bu işi daha iyi nasıl yapabiliriz?"</strong></p>`,
      seoTitle: 'Hakkımızda - Foto Uğur | Ataşehir Fotoğraf Stüdyosu',
      seoDescription: '1997\'den beri Ataşehir\'de profesyonel fotoğraf hizmetleri sunan Foto Uğur\'un hikayesi ve deneyimi.',
      seoKeywords: 'foto uğur hakkında, ataşehir fotoğraf stüdyosu, profesyonel fotoğrafçı istanbul',
    },
  })
  console.log('✅ About page created')

  // Create KVKK page
  await prisma.page.upsert({
    where: { slug: 'kvkk' },
    update: {},
    create: {
      title: 'KVKK Aydınlatma Metni',
      slug: 'kvkk',
      content: `<h2>Kişisel Verilerin Korunması Kanunu (KVKK) Aydınlatma Metni</h2>
      <p><strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong> olarak, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") kapsamında, kişisel verilerinizin korunmasına ilişkin aydınlatma yükümlülüğümüzü yerine getirmek amacıyla bu metni hazırlamış bulunmaktayız.</p>
      <h3>Veri Sorumlusu</h3>
      <p><strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong>, kişisel verilerinizin işlenmesinde veri sorumlusu sıfatına haizdir.</p>
      <p><strong>Adres:</strong> Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul</p>
      <p><strong>Telefon:</strong> 0216 472 46 28</p>
      <p><strong>E-posta:</strong> info@fotougur.com</p>
      <h3>İşlenen Kişisel Veriler</h3>
      <p>İletişim formu, randevu talepleri ve hizmet süreçleri kapsamında aşağıdaki kişisel verileriniz işlenmektedir:</p>
      <ul>
        <li><strong>Kimlik Bilgileri:</strong> Ad, soyad</li>
        <li><strong>İletişim Bilgileri:</strong> Telefon numarası, e-posta adresi, adres bilgileri</li>
        <li><strong>Hizmet Talebi Bilgileri:</strong> Randevu bilgileri, hizmet türü, özel istekler</li>
        <li><strong>İşlem Güvenliği Bilgileri:</strong> IP adresi, tarayıcı bilgileri (güvenlik amaçlı)</li>
      </ul>
      <h3>Kişisel Verilerin İşlenme Amaçları</h3>
      <p>Kişisel verileriniz aşağıdaki amaçlarla işlenmektedir:</p>
      <ul>
        <li>Hizmet taleplerinizin karşılanması ve randevu yönetimi</li>
        <li>İletişim ve bilgilendirme faaliyetlerinin yürütülmesi</li>
        <li>Yasal yükümlülüklerin yerine getirilmesi</li>
        <li>Müşteri memnuniyetinin artırılması ve hizmet kalitesinin iyileştirilmesi</li>
        <li>Web sitesi güvenliğinin sağlanması</li>
      </ul>
      <h3>Kişisel Verilerin İşlenme Hukuki Sebepleri</h3>
      <p>Kişisel verileriniz aşağıdaki hukuki sebeplere dayanarak işlenmektedir:</p>
      <ul>
        <li>KVKK'nın 5/2-c maddesi: "Sözleşmenin kurulması veya ifasıyla doğrudan doğruya ilgili olması kaydıyla, sözleşmenin taraflarına ait kişisel verilerin işlenmesinin gerekli olması"</li>
        <li>KVKK'nın 5/2-f maddesi: "Veri sorumlusunun hukuki yükümlülüğünü yerine getirebilmesi için zorunlu olması"</li>
        <li>KVKK'nın 5/2-a maddesi: "Açık rıza" (varsa)</li>
      </ul>
      <h3>Kişisel Verilerin Aktarımı</h3>
      <p>Kişisel verileriniz, yasal yükümlülüklerimiz ve hizmet sunumu kapsamında sınırlı olarak işlenmekte olup, aşağıdaki durumlar dışında üçüncü kişilerle paylaşılmamaktadır:</p>
      <ul>
        <li>Yasal zorunluluklar (mahkeme kararı, yasal düzenlemeler)</li>
        <li>Hizmet sağlayıcılarımız (hosting, e-posta servisleri - sadece teknik destek amaçlı)</li>
      </ul>
      <h3>Kişisel Verilerin Saklanma Süresi</h3>
      <p>Kişisel verileriniz, işlenme amaçlarının gerektirdiği süre boyunca ve yasal saklama yükümlülüklerimiz çerçevesinde saklanmaktadır. Bu süre sona erdiğinde, verileriniz yasalara uygun şekilde silinmekte veya anonim hale getirilmektedir.</p>
      <h3>KVKK Kapsamındaki Haklarınız</h3>
      <p>KVKK'nın 11. maddesi uyarınca aşağıdaki haklara sahipsiniz:</p>
      <ul>
        <li>Kişisel verilerinizin işlenip işlenmediğini öğrenme</li>
        <li>İşlenmişse bilgi talep etme</li>
        <li>İşlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme</li>
        <li>Yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri bilme</li>
        <li>Eksik veya yanlış işlenmişse düzeltilmesini isteme</li>
        <li>KVKK'nın 7. maddesinde öngörülen şartlar çerçevesinde silinmesini veya yok edilmesini isteme</li>
        <li>Düzeltme, silme, yok edilme kapsamında yapılan işlemlerin, kişisel verilerin aktarıldığı üçüncü kişilere bildirilmesini isteme</li>
        <li>İşlenen verilerin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle kişinin kendisi aleyhine bir sonucun ortaya çıkmasına itiraz etme</li>
        <li>Kişisel verilerin kanuna aykırı olarak işlenmesi sebebiyle zarara uğraması hâlinde zararın giderilmesini talep etme</li>
      </ul>
      <h3>Haklarınızı Kullanma Yöntemi</h3>
      <p>Yukarıda belirtilen haklarınızı kullanmak için, kimliğinizi tespit edici belgelerle birlikte yazılı olarak aşağıdaki iletişim bilgilerimiz üzerinden başvuruda bulunabilirsiniz:</p>
      <p><strong>Foto Uğur / Uğur Fotoğrafçılık</strong><br>
      Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul<br>
      E-posta: info@fotougur.com<br>
      Telefon: 0216 472 46 28</p>
      <p>Başvurularınız, KVKK'nın 13. maddesi uyarınca en geç 30 gün içinde değerlendirilerek sonuçlandırılacaktır.</p>`,
      seoTitle: 'KVKK Aydınlatma Metni - Foto Uğur | Kişisel Verilerin Korunması',
      seoDescription: 'Foto Uğur Kişisel Verilerin Korunması Kanunu (KVKK) aydınlatma metni ve kişisel veri işleme politikası.',
      seoKeywords: 'kvkk, kişisel verilerin korunması, gizlilik, foto uğur kvkk',
    },
  })
  console.log('✅ KVKK page created')

  // Create Privacy Policy page
  await prisma.page.upsert({
    where: { slug: 'gizlilik-politikasi' },
    update: {},
    create: {
      title: 'Gizlilik Politikası',
      slug: 'gizlilik-politikasi',
      content: `<h2>Gizlilik Politikası</h2>
      <p><strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong> olarak, gizliliğinize saygı gösteriyor ve kişisel bilgilerinizin korunmasına önem veriyoruz. Bu gizlilik politikası, web sitemizi kullanırken toplanan bilgilerin nasıl kullanıldığını ve korunduğunu açıklamaktadır.</p>
      <h3>Toplanan Bilgiler</h3>
      <p>Web sitemiz üzerinden iletişim formu, randevu talepleri ve hizmet süreçleri kapsamında aşağıdaki bilgiler toplanabilir:</p>
      <ul>
        <li><strong>Kimlik Bilgileri:</strong> Ad ve soyad</li>
        <li><strong>İletişim Bilgileri:</strong> E-posta adresi, telefon numarası, adres bilgileri</li>
        <li><strong>Hizmet Bilgileri:</strong> Hizmet talebi detayları, randevu bilgileri, özel istekler</li>
        <li><strong>Teknik Bilgiler:</strong> IP adresi, tarayıcı türü, işletim sistemi (güvenlik ve analiz amaçlı)</li>
      </ul>
      <h3>Bilgilerin Kullanımı</h3>
      <p>Toplanan bilgiler aşağıdaki amaçlarla kullanılmaktadır:</p>
      <ul>
        <li>Hizmet taleplerinizin karşılanması ve randevu yönetimi</li>
        <li>İletişim ve bilgilendirme faaliyetleri</li>
        <li>Müşteri memnuniyetinin artırılması</li>
        <li>Web sitesi güvenliğinin sağlanması</li>
        <li>Yasal yükümlülüklerin yerine getirilmesi</li>
        <li>İstatistiksel analizler ve hizmet iyileştirmeleri</li>
      </ul>
      <h3>Bilgilerin Korunması</h3>
      <p>Kişisel bilgileriniz güvenli bir şekilde saklanmakta ve yalnızca yasal zorunluluklar ve hizmet sunumu kapsamında kullanılmaktadır. Verilerinizin güvenliği için:</p>
      <ul>
        <li>SSL sertifikası ile şifreli bağlantı kullanılmaktadır</li>
        <li>Güvenli sunucu altyapısı tercih edilmektedir</li>
        <li>Erişim yetkileri sınırlandırılmıştır</li>
        <li>Düzenli güvenlik güncellemeleri yapılmaktadır</li>
      </ul>
      <h3>Çerezler (Cookies)</h3>
      <p>Web sitemiz, kullanıcı deneyimini iyileştirmek ve site performansını analiz etmek için çerezler kullanmaktadır. Detaylı bilgi için <a href="/cerez-politikasi">Çerez Politikası</a> sayfamızı ziyaret edebilirsiniz.</p>
      <h3>Üçüncü Taraf Hizmetler</h3>
      <p>Web sitemiz, hizmet kalitesini artırmak amacıyla aşağıdaki üçüncü taraf hizmetleri kullanabilir:</p>
      <ul>
        <li>Hosting ve sunucu hizmetleri</li>
        <li>E-posta servisleri</li>
        <li>Analiz araçları (anonim veriler)</li>
      </ul>
      <p>Bu hizmetler, kendi gizlilik politikalarına tabidir ve verileriniz sadece teknik destek amaçlı sınırlı olarak paylaşılmaktadır.</p>
      <h3>Veri Saklama Süresi</h3>
      <p>Kişisel verileriniz, işlenme amaçlarının gerektirdiği süre boyunca ve yasal saklama yükümlülüklerimiz çerçevesinde saklanmaktadır. Bu süre sona erdiğinde, verileriniz güvenli bir şekilde silinmektedir.</p>
      <h3>Haklarınız</h3>
      <p>Kişisel verilerinizle ilgili olarak aşağıdaki haklara sahipsiniz:</p>
      <ul>
        <li>Verilerinize erişim hakkı</li>
        <li>Düzeltme hakkı</li>
        <li>Silme hakkı</li>
        <li>İtiraz hakkı</li>
        <li>Veri taşınabilirliği hakkı</li>
      </ul>
      <p>Haklarınızı kullanmak için bizimle iletişime geçebilirsiniz.</p>
      <h3>Değişiklikler</h3>
      <p>Bu gizlilik politikası zaman zaman güncellenebilir. Önemli değişiklikler web sitemizde duyurulacaktır. Güncel versiyon her zaman bu sayfada yayınlanacaktır.</p>
      <h3>İletişim</h3>
      <p>Gizlilik politikamız hakkında sorularınız için bizimle iletişime geçebilirsiniz:</p>
      <p><strong>Foto Uğur / Uğur Fotoğrafçılık</strong><br>
      Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul<br>
      E-posta: info@fotougur.com<br>
      Telefon: 0216 472 46 28</p>`,
      seoTitle: 'Gizlilik Politikası - Foto Uğur | Privacy Policy',
      seoDescription: 'Foto Uğur gizlilik politikası ve kişisel verilerin korunması hakkında detaylı bilgiler.',
      seoKeywords: 'gizlilik politikası, privacy policy, kişisel veri koruma, foto uğur',
    },
  })
  console.log('✅ Privacy Policy page created')

  // Create Cookie Policy page
  await prisma.page.upsert({
    where: { slug: 'cerez-politikasi' },
    update: {},
    create: {
      title: 'Çerez Politikası',
      slug: 'cerez-politikasi',
      content: `<h2>Çerez Politikası</h2>
      <p><strong>Foto Uğur</strong> ve <strong>Uğur Fotoğrafçılık</strong> web sitesi, kullanıcı deneyimini iyileştirmek ve site performansını analiz etmek için çerezler (cookies) kullanmaktadır. Bu politika, çerez kullanımımız hakkında bilgi vermektedir.</p>
      <h3>Çerez Nedir?</h3>
      <p>Çerezler, web sitelerini ziyaret ettiğinizde tarayıcınızda saklanan küçük metin dosyalarıdır. Bu dosyalar, site deneyiminizi iyileştirmek, tercihlerinizi hatırlamak ve site kullanımını analiz etmek için kullanılır.</p>
      <h3>Kullandığımız Çerez Türleri</h3>
      <h4>1. Zorunlu Çerezler</h4>
      <p>Bu çerezler, web sitesinin temel işlevlerinin çalışması için gereklidir ve devre dışı bırakılamaz:</p>
      <ul>
        <li><strong>Oturum Yönetimi:</strong> Kullanıcı oturumlarının yönetimi ve güvenliği</li>
        <li><strong>Güvenlik:</strong> Güvenlik kontrolleri ve saldırı önleme</li>
        <li><strong>Form İşlemleri:</strong> İletişim formları ve randevu sistemlerinin çalışması</li>
      </ul>
      <h4>2. Performans ve Analitik Çerezler</h4>
      <p>Bu çerezler, site kullanımını analiz etmek ve iyileştirmeler yapmak için kullanılır:</p>
      <ul>
        <li>Sayfa görüntüleme istatistikleri</li>
        <li>Kullanıcı davranış analizi</li>
        <li>Site performans ölçümleri</li>
        <li>Hata takibi ve düzeltme</li>
      </ul>
      <h4>3. İşlevsellik Çerezleri</h4>
      <p>Bu çerezler, kullanıcı deneyimini kişiselleştirmek için kullanılır:</p>
      <ul>
        <li>Dil tercihleri</li>
        <li>Kullanıcı ayarları</li>
        <li>Önceki ziyaret bilgileri</li>
      </ul>
      <h3>Çerez Yönetimi</h3>
      <p>Tarayıcı ayarlarınızdan çerezleri yönetebilir veya devre dışı bırakabilirsiniz. Ancak, bazı çerezlerin devre dışı bırakılması web sitesinin bazı özelliklerinin çalışmamasına neden olabilir.</p>
      <h4>Tarayıcı Ayarları:</h4>
      <ul>
        <li><strong>Chrome:</strong> Ayarlar > Gizlilik ve güvenlik > Çerezler ve diğer site verileri</li>
        <li><strong>Firefox:</strong> Seçenekler > Gizlilik ve Güvenlik > Çerezler ve site verileri</li>
        <li><strong>Safari:</strong> Tercihler > Gizlilik > Çerezleri yönet</li>
        <li><strong>Edge:</strong> Ayarlar > Gizlilik, arama ve hizmetler > Çerezler</li>
      </ul>
      <h3>Üçüncü Taraf Çerezler</h3>
      <p>Web sitemiz, analiz ve iyileştirme amaçlı üçüncü taraf hizmetler kullanabilir. Bu hizmetler kendi çerez politikalarına tabidir:</p>
      <ul>
        <li>Analiz araçları (anonim veriler)</li>
        <li>Sosyal medya entegrasyonları (varsa)</li>
        <li>Harita servisleri (varsa)</li>
      </ul>
      <h3>Çerez Süreleri</h3>
      <p>Çerezler, kullanım amaçlarına göre farklı sürelerde saklanabilir:</p>
      <ul>
        <li><strong>Oturum Çerezleri:</strong> Tarayıcı kapatıldığında silinir</li>
        <li><strong>Kalıcı Çerezler:</strong> Belirli bir süre boyunca (genellikle 30-365 gün) saklanır</li>
      </ul>
      <h3>Güncellemeler</h3>
      <p>Bu çerez politikası zaman zaman güncellenebilir. Önemli değişiklikler web sitemizde duyurulacaktır. Güncel versiyon her zaman bu sayfada yayınlanacaktır.</p>
      <h3>İletişim</h3>
      <p>Çerez politikamız hakkında sorularınız için bizimle iletişime geçebilirsiniz:</p>
      <p><strong>Foto Uğur / Uğur Fotoğrafçılık</strong><br>
      Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul<br>
      E-posta: info@fotougur.com<br>
      Telefon: 0216 472 46 28</p>`,
      seoTitle: 'Çerez Politikası - Foto Uğur | Cookie Policy',
      seoDescription: 'Foto Uğur çerez politikası ve çerez kullanımı hakkında detaylı bilgiler.',
      seoKeywords: 'çerez politikası, cookie policy, çerez kullanımı, foto uğur',
    },
  })
  console.log('✅ Cookie Policy page created')

  // Create blog posts
  const blogPosts = [
    {
      title: 'Düğün Fotoğrafçılığında 5 Önemli İpucu',
      slug: 'dugun-fotografciliginda-5-onemli-ipucu',
      excerpt: 'Düğününüzün unutulmaz anlarını yakalamak için bilmeniz gerekenler.',
      content: '<p>Düğün fotoğrafçılığı, hayatınızın en özel gününü ölümsüzleştirmek için kritik öneme sahiptir. İşte dikkat etmeniz gereken 5 önemli nokta...</p>',
      category: 'İpuçları',
      isPublished: true,
      publishedAt: new Date(),
      seoTitle: 'Düğün Fotoğrafçılığında 5 Önemli İpucu | Foto Uğur Blog',
      seoDescription: 'Düğün fotoğrafçılığı için bilmeniz gereken önemli ipuçları ve profesyonel öneriler.',
      seoKeywords: 'düğün fotoğrafçılığı ipuçları, düğün çekimi, profesyonel fotoğrafçı',
    },
    {
      title: 'Ürün Fotoğrafçılığında Işık Kullanımı',
      slug: 'urun-fotografciliginda-isik-kullanimi',
      excerpt: 'E-ticaret için mükemmel ürün fotoğrafları çekmek için ışık teknikleri.',
      content: '<p>Ürün fotoğrafçılığında doğru ışık kullanımı, satışlarınızı artıran en önemli faktörlerden biridir...</p>',
      category: 'Teknik',
      isPublished: true,
      publishedAt: new Date(),
      seoTitle: 'Ürün Fotoğrafçılığında Işık Kullanımı | Foto Uğur Blog',
      seoDescription: 'E-ticaret için profesyonel ürün fotoğrafları çekmek için ışık teknikleri ve ipuçları.',
      seoKeywords: 'ürün fotoğrafçılığı, e-ticaret fotoğraf, ışık teknikleri',
    },
    {
      title: 'Dış Mekan Çekimi İçin En İyi Lokasyonlar',
      slug: 'dis-mekan-cekimi-icin-en-iyi-lokasyonlar',
      excerpt: 'İstanbul\'da dış mekan fotoğraf çekimi için önerilen mekanlar.',
      content: '<p>İstanbul, dış mekan fotoğraf çekimi için sayısız güzel lokasyon sunuyor. İşte en popüler ve etkileyici mekanlar...</p>',
      category: 'Lokasyonlar',
      isPublished: true,
      publishedAt: new Date(),
      seoTitle: 'Dış Mekan Çekimi İçin En İyi Lokasyonlar İstanbul | Foto Uğur',
      seoDescription: 'İstanbul\'da dış mekan fotoğraf çekimi için önerilen en güzel ve popüler lokasyonlar.',
      seoKeywords: 'dış mekan çekim lokasyonları istanbul, açık hava fotoğraf, istanbul fotoğraf mekanları',
    },
    {
      title: 'Sosyal Medya İçin Profesyonel Görsel İçerik',
      slug: 'sosyal-medya-icin-profesyonel-gorsel-icerik',
      excerpt: 'Markanızın sosyal medya hesapları için etkileyici görseller oluşturma rehberi.',
      content: '<p>Sosyal medya, markanızın görünürlüğünü artırmak için kritik bir platformdur. Profesyonel görsel içeriklerle fark yaratın...</p>',
      category: 'Sosyal Medya',
      isPublished: true,
      publishedAt: new Date(),
      seoTitle: 'Sosyal Medya İçin Profesyonel Görsel İçerik | Foto Uğur',
      seoDescription: 'Markanızın sosyal medya hesapları için profesyonel görsel içerik oluşturma rehberi ve ipuçları.',
      seoKeywords: 'sosyal medya içerik, marka fotoğrafçılığı, profesyonel görseller',
    },
    {
      title: 'Vesikalık ve Biyometrik Fotoğraf Rehberi',
      slug: 'vesikalik-ve-biyometrik-fotograf-rehberi',
      excerpt: 'Resmi belgeler için vesikalık ve biyometrik fotoğraf gereksinimleri hakkında bilmeniz gerekenler.',
      content: '<p>Pasaport, kimlik, vize gibi resmi belgeler için fotoğraf çektirirken dikkat etmeniz gereken önemli noktalar...</p>',
      category: 'Rehber',
      isPublished: true,
      publishedAt: new Date(),
      seoTitle: 'Vesikalık ve Biyometrik Fotoğraf Rehberi | Foto Uğur',
      seoDescription: 'Resmi belgeler için vesikalık ve biyometrik fotoğraf gereksinimleri ve standartları hakkında rehber.',
      seoKeywords: 'vesikalık fotoğraf, biyometrik fotoğraf, pasaport fotoğrafı gereksinimleri',
    },
  ]

  for (const post of blogPosts) {
    await prisma.blogPost.upsert({
      where: { slug: post.slug },
      update: {},
      create: post,
    })
  }
  console.log('✅ Blog posts created')

  console.log('🎉 Seeding completed!')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })

