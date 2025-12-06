"use client"

import { useState } from "react"
import Container from "@/components/layout/Container"
import { AnimatedSection } from "@/components/features/AnimatedSection"
import { GalleryList } from "@/components/features/GalleryList"
import { GalleryFilters } from "@/components/features/GalleryFilters"

interface Media {
  id: string
  title: string | null
  url: string
  type: string
  category: string | null
  thumbnail: string | null
  isActive: boolean
}

interface GalleryClientProps {
  media: Media[]
  categories: string[]
}

export function GalleryClient({ media, categories }: GalleryClientProps) {
  const [activeFilter, setActiveFilter] = useState("Tümü")

  return (
    <div className="bg-neutral-50">
      {/* Hero Section */}
      <section className="py-16 md:py-24 bg-white border-b">
        <Container>
          <AnimatedSection className="text-center space-y-6">
            <h1 className="text-4xl md:text-5xl font-bold text-neutral-900">Galeri / Portfolyo</h1>
            <p className="text-xl text-neutral-600 max-w-3xl mx-auto">
              Düğün, nişan, dış çekim, ürün ve stüdyo çalışmalarımızdan seçilmiş kareler. Daha fazla örnek için stüdyomuzu ziyaret edebilirsiniz.
            </p>
          </AnimatedSection>
        </Container>
      </section>

      {/* Gallery Content */}
      <section className="py-12 md:py-16">
        <Container>
          {/* Filters */}
          {categories.length > 0 && (
            <GalleryFilters
              categories={categories}
              onFilterChange={setActiveFilter}
              initialFilter={activeFilter}
            />
          )}

          {/* Gallery Grid with Lightbox */}
          <GalleryList
            media={media}
            isAdmin={false}
            filterCategory={activeFilter}
          />

          {media.length === 0 && (
            <div className="text-center py-12">
              <p className="text-neutral-500">Henüz galeri içeriği eklenmemiş.</p>
            </div>
          )}
        </Container>
      </section>
    </div>
  )
}

