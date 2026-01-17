import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Home, Search, ArrowLeft } from "lucide-react"
import Container from "@/components/layout/Container"

export default function NotFound() {
  return (
    <div className="bg-neutral-50 min-h-screen flex items-center">
      <Container>
        <div className="max-w-2xl mx-auto text-center space-y-8 py-16">
          {/* 404 Number */}
          <div className="space-y-4">
            <h1 className="text-9xl font-bold text-amber-600">404</h1>
            <h2 className="text-3xl md:text-4xl font-bold text-neutral-900">
              Sayfa Bulunamadı
            </h2>
            <p className="text-lg text-neutral-600">
              Aradığınız sayfa mevcut değil veya taşınmış olabilir.
            </p>
          </div>

          {/* Actions */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" variant="premium" asChild>
              <Link href="/">
                <Home className="mr-2 h-5 w-5" />
                Ana Sayfaya Dön
              </Link>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <Link href="/blog">
                <Search className="mr-2 h-5 w-5" />
                Blog Yazıları
              </Link>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <Link href="/hizmetler">
                <Search className="mr-2 h-5 w-5" />
                Hizmetlerimiz
              </Link>
            </Button>
          </div>

          {/* Popular Links */}
          <div className="pt-8 border-t border-neutral-200">
            <p className="text-sm text-neutral-500 mb-4">Popüler Sayfalar:</p>
            <div className="flex flex-wrap gap-2 justify-center">
              <Link
                href="/"
                className="text-sm text-amber-600 hover:text-amber-700 hover:underline"
              >
                Ana Sayfa
              </Link>
              <span className="text-neutral-300">•</span>
              <Link
                href="/hizmetler"
                className="text-sm text-amber-600 hover:text-amber-700 hover:underline"
              >
                Hizmetler
              </Link>
              <span className="text-neutral-300">•</span>
              <Link
                href="/blog"
                className="text-sm text-amber-600 hover:text-amber-700 hover:underline"
              >
                Blog
              </Link>
              <span className="text-neutral-300">•</span>
              <Link
                href="/galeri"
                className="text-sm text-amber-600 hover:text-amber-700 hover:underline"
              >
                Galeri
              </Link>
              <span className="text-neutral-300">•</span>
              <Link
                href="/iletisim"
                className="text-sm text-amber-600 hover:text-amber-700 hover:underline"
              >
                İletişim
              </Link>
            </div>
          </div>
        </div>
      </Container>
    </div>
  )
}

