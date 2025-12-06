"use client"

import Link from "next/link"
import { useState, useEffect } from "react"
import { Menu, X, Phone } from "lucide-react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import Container from "./Container"

export default function Header() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20)
    }
    window.addEventListener("scroll", handleScroll)
    return () => window.removeEventListener("scroll", handleScroll)
  }, [])

  const navItems = [
    { label: "Ana Sayfa", href: "/" },
    { label: "Hakkımızda", href: "/hakkimizda" },
    { label: "Hizmetler", href: "/hizmetler" },
    { label: "Galeri", href: "/galeri" },
    { label: "Blog", href: "/blog" },
    { label: "İletişim", href: "/iletisim" },
  ]

  return (
    <header
      className={cn(
        "sticky top-0 z-50 w-full border-b transition-all duration-300",
        scrolled
          ? "bg-white/95 backdrop-blur-md shadow-sm"
          : "bg-white/80 backdrop-blur-sm"
      )}
    >
      <Container>
        <div className="flex h-20 items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-2 group flex-shrink-0">
            <span className="text-2xl font-bold font-poppins text-neutral-900 group-hover:text-amber-600 transition-colors">
              Foto Uğur
            </span>
          </Link>

          {/* Desktop Navigation - Center */}
          <nav className="hidden lg:flex items-center space-x-1 flex-1 justify-center">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="px-4 py-2 text-sm font-medium text-neutral-700 hover:text-amber-600 transition-colors rounded-lg hover:bg-neutral-50"
              >
                {item.label}
              </Link>
            ))}
          </nav>

          {/* Desktop CTA - Right */}
          <div className="hidden lg:flex items-center space-x-4 flex-shrink-0">
            <a
              href="tel:02164724628"
              className="flex items-center space-x-2 text-sm text-neutral-600 hover:text-amber-600 transition-colors"
            >
              <Phone className="h-4 w-4" />
              <span className="font-medium hidden xl:inline">0216 472 46 28</span>
            </a>
            <Button size="lg" variant="premium" asChild>
              <Link href="/iletisim">Randevu Al</Link>
            </Button>
          </div>

          {/* Mobile Menu Button */}
          <button
            className="lg:hidden p-2 rounded-lg hover:bg-neutral-100 transition-colors"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Toggle menu"
          >
            {mobileMenuOpen ? (
              <X className="h-6 w-6 text-neutral-900" />
            ) : (
              <Menu className="h-6 w-6 text-neutral-900" />
            )}
          </button>
        </div>
      </Container>

      {/* Mobile Menu */}
      {mobileMenuOpen && (
        <div className="lg:hidden border-t bg-white">
          <Container>
            <nav className="flex flex-col space-y-1 py-4">
              {navItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="px-4 py-3 text-base font-medium text-neutral-700 hover:text-amber-600 hover:bg-neutral-50 rounded-lg transition-colors"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  {item.label}
                </Link>
              ))}
              <div className="pt-4 space-y-3">
                <a
                  href="tel:02164724628"
                  className="flex items-center space-x-2 px-4 py-3 text-base text-neutral-600 hover:text-amber-600"
                >
                  <Phone className="h-5 w-5" />
                  <span className="font-medium">0216 472 46 28</span>
                </a>
                <Button size="lg" variant="premium" asChild className="w-full">
                  <Link href="/iletisim" onClick={() => setMobileMenuOpen(false)}>
                    Randevu Al
                  </Link>
                </Button>
              </div>
            </nav>
          </Container>
        </div>
      )}
    </header>
  )
}
