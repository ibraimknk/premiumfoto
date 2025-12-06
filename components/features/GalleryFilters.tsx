"use client"

import { useState, useEffect } from "react"
import { AnimatedSection } from "./AnimatedSection"

interface GalleryFiltersProps {
  categories: string[]
  onFilterChange?: (category: string) => void
  initialFilter?: string
}

export function GalleryFilters({ categories, onFilterChange, initialFilter = "Tümü" }: GalleryFiltersProps) {
  const [activeFilter, setActiveFilter] = useState(initialFilter)

  useEffect(() => {
    setActiveFilter(initialFilter)
  }, [initialFilter])

  const allCategories = ["Tümü", ...categories]

  const handleFilterClick = (category: string) => {
    setActiveFilter(category)
    onFilterChange?.(category)
  }

  return (
    <AnimatedSection className="flex flex-wrap gap-2 justify-center mb-8">
      {allCategories.map((category) => (
        <button
          key={category}
          onClick={() => handleFilterClick(category)}
          className={`px-4 py-2 rounded-full border transition-colors ${
            activeFilter === category
              ? "border-amber-500 bg-amber-50 text-amber-700 font-semibold"
              : "border-neutral-200 bg-white hover:bg-neutral-50 hover:border-amber-300"
          }`}
        >
          {category}
        </button>
      ))}
    </AnimatedSection>
  )
}

