import Link from "next/link"
import { Phone, Mail, MapPin, Facebook, Instagram, MessageCircle } from "lucide-react"
import Container from "./Container"

export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="border-t bg-white">
      <Container>
        <div className="py-16">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12">
            {/* About */}
            <div className="space-y-4">
              <h3 className="text-xl font-bold font-poppins text-neutral-900">
                Foto Uğur
              </h3>
              <p className="text-sm text-neutral-600 leading-relaxed">
                Ataşehir&apos;de 1997&apos;den beri profesyonel fotoğraf hizmetleri
                sunuyoruz. Hayatınızın özel anlarını ölümsüzleştiriyoruz.
              </p>
            </div>

            {/* Quick Links */}
            <div>
              <h3 className="text-lg font-semibold mb-4 text-neutral-900">
                Hızlı Linkler
              </h3>
              <ul className="space-y-3">
                <li>
                  <Link
                    href="/hakkimizda"
                    className="text-sm text-neutral-600 hover:text-amber-600 transition-colors"
                  >
                    Hakkımızda
                  </Link>
                </li>
                <li>
                  <Link
                    href="/hizmetler"
                    className="text-sm text-neutral-600 hover:text-amber-600 transition-colors"
                  >
                    Hizmetlerimiz
                  </Link>
                </li>
                <li>
                  <Link
                    href="/galeri"
                    className="text-sm text-neutral-600 hover:text-amber-600 transition-colors"
                  >
                    Galeri
                  </Link>
                </li>
                <li>
                  <Link
                    href="/blog"
                    className="text-sm text-neutral-600 hover:text-amber-600 transition-colors"
                  >
                    Blog
                  </Link>
                </li>
                <li>
                  <Link
                    href="/iletisim"
                    className="text-sm text-neutral-600 hover:text-amber-600 transition-colors"
                  >
                    İletişim
                  </Link>
                </li>
              </ul>
            </div>

            {/* Services */}
            <div>
              <h3 className="text-lg font-semibold mb-4 text-neutral-900">
                Hizmetlerimiz
              </h3>
              <ul className="space-y-3 text-sm text-neutral-600">
                <li>Dış Mekan Çekimi</li>
                <li>Düğün Fotoğrafçılığı</li>
                <li>Ürün Fotoğrafçılığı</li>
                <li>Stüdyo Çekimi</li>
                <li>Vesikalık & Biyometrik</li>
              </ul>
            </div>

            {/* Contact */}
            <div>
              <h3 className="text-lg font-semibold mb-4 text-neutral-900">
                İletişim
              </h3>
              <ul className="space-y-4">
                <li className="flex items-start space-x-3">
                  <MapPin className="h-5 w-5 mt-0.5 text-amber-600 flex-shrink-0" />
                  <span className="text-sm text-neutral-600 leading-relaxed">
                    Mustafa Kemal Mah. 3001 Cad. No: 49/A, Ataşehir, İstanbul
                  </span>
                </li>
                <li>
                  <a
                    href="tel:02164724628"
                    className="flex items-center space-x-3 text-sm text-neutral-600 hover:text-amber-600 transition-colors"
                  >
                    <Phone className="h-5 w-5 text-amber-600" />
                    <span>0216 472 46 28</span>
                  </a>
                </li>
                <li>
                  <a
                    href="tel:05302285603"
                    className="flex items-center space-x-3 text-sm text-neutral-600 hover:text-amber-600 transition-colors"
                  >
                    <Phone className="h-5 w-5 text-amber-600" />
                    <span>0530 228 56 03</span>
                  </a>
                </li>
                <li>
                  <a
                    href="https://wa.me/905302285603"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center space-x-3 text-sm text-neutral-600 hover:text-amber-600 transition-colors"
                  >
                    <MessageCircle className="h-5 w-5 text-amber-600" />
                    <span>WhatsApp</span>
                  </a>
                </li>
                <li className="flex items-center space-x-4 pt-2">
                  <a
                    href="#"
                    className="text-neutral-400 hover:text-amber-600 transition-colors"
                    aria-label="Facebook"
                  >
                    <Facebook className="h-5 w-5" />
                  </a>
                  <a
                    href="#"
                    className="text-neutral-400 hover:text-amber-600 transition-colors"
                    aria-label="Instagram"
                  >
                    <Instagram className="h-5 w-5" />
                  </a>
                </li>
              </ul>
            </div>
          </div>

          <div className="mt-12 pt-8 border-t">
            <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
              <p className="text-sm text-neutral-500 text-center md:text-left">
                © {currentYear} Foto Uğur. Tüm hakları saklıdır.
              </p>
              <div className="flex flex-wrap justify-center md:justify-end gap-4 text-sm">
                <Link
                  href="/kvkk"
                  className="text-neutral-500 hover:text-amber-600 transition-colors"
                >
                  KVKK
                </Link>
                <span className="text-neutral-300">|</span>
                <Link
                  href="/gizlilik-politikasi"
                  className="text-neutral-500 hover:text-amber-600 transition-colors"
                >
                  Gizlilik Politikası
                </Link>
                <span className="text-neutral-300">|</span>
                <Link
                  href="/cerez-politikasi"
                  className="text-neutral-500 hover:text-amber-600 transition-colors"
                >
                  Çerez Politikası
                </Link>
              </div>
            </div>
          </div>
        </div>
      </Container>
    </footer>
  )
}
