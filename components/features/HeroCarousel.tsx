"use client"

import { useState, useEffect } from "react"
import Image from "next/image"
import { ChevronLeft, ChevronRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { shouldUnoptimizeImage } from "@/lib/image-utils"

interface CarouselItem {
  id: string
  image: string
  title?: string
  subtitle?: string
}

interface HeroCarouselProps {
  items: CarouselItem[]
  autoPlay?: boolean
  interval?: number
}

export function HeroCarousel({ items, autoPlay = true, interval = 5000 }: HeroCarouselProps) {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isPaused, setIsPaused] = useState(false)

  const validItems = items.filter(item => item.image && item.image.trim() !== "" && !item.image.includes("/api/placeholder"))

  useEffect(() => {
    if (!autoPlay || isPaused || validItems.length <= 1) return

    const timer = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % validItems.length)
    }, interval)

    return () => clearInterval(timer)
  }, [autoPlay, interval, validItems.length, isPaused])

  const goToSlide = (index: number) => {
    setCurrentIndex(index)
  }

  const goToPrevious = () => {
    setCurrentIndex((prev) => (prev - 1 + validItems.length) % validItems.length)
  }

  const goToNext = () => {
    setCurrentIndex((prev) => (prev + 1) % validItems.length)
  }

  if (validItems.length === 0) return null

  return (
    <div
      className="relative w-full h-full rounded-3xl overflow-hidden"
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={() => setIsPaused(false)}
    >
      {/* Slides */}
      <div className="relative w-full h-full">
        {validItems.map((item, index) => (
          <div
            key={item.id}
            className={cn(
              "absolute inset-0 transition-opacity duration-700 ease-in-out",
              index === currentIndex ? "opacity-100 z-10" : "opacity-0 z-0"
            )}
          >
            <div className="relative w-full h-full">
              <Image
                src={item.image}
                alt={item.title || `Slide ${index + 1}`}
                fill
                className="object-cover"
                priority={index === 0}
                unoptimized={shouldUnoptimizeImage(item.image)}
              />
              {(item.title || item.subtitle) && (
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent flex items-end">
                  <div className="w-full p-8 text-white">
                    {item.title && (
                      <h3 className="text-2xl md:text-3xl font-bold mb-2">{item.title}</h3>
                    )}
                    {item.subtitle && (
                      <p className="text-lg md:text-xl opacity-90">{item.subtitle}</p>
                    )}
                  </div>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* Navigation Arrows */}
      {validItems.length > 1 && (
        <>
          <Button
            variant="ghost"
            size="icon"
            className="absolute left-4 top-1/2 -translate-y-1/2 z-20 bg-white/80 hover:bg-white rounded-full shadow-lg"
            onClick={goToPrevious}
            aria-label="Önceki slide"
          >
            <ChevronLeft className="h-6 w-6" />
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="absolute right-4 top-1/2 -translate-y-1/2 z-20 bg-white/80 hover:bg-white rounded-full shadow-lg"
            onClick={goToNext}
            aria-label="Sonraki slide"
          >
            <ChevronRight className="h-6 w-6" />
          </Button>
        </>
      )}

      {/* Dots Indicator */}
      {validItems.length > 1 && (
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 z-20 flex gap-2">
          {validItems.map((_, index) => (
            <button
              key={index}
              onClick={() => goToSlide(index)}
              className={cn(
                "w-2 h-2 rounded-full transition-all",
                index === currentIndex
                  ? "bg-white w-8"
                  : "bg-white/50 hover:bg-white/75"
              )}
              aria-label={`Slide ${index + 1} göster`}
            />
          ))}
        </div>
      )}
    </div>
  )
}

