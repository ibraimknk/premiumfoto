"use client"

import { useState, useEffect } from "react"
import Image from "next/image"
import { X, ChevronLeft, ChevronRight, Play } from "lucide-react"
import { Button } from "@/components/ui/button"
import { shouldUnoptimizeImage } from "@/lib/image-utils"

interface MediaItem {
  id: string
  url: string
  type: string
  title: string | null
  thumbnail: string | null
}

interface GalleryLightboxProps {
  media: MediaItem[]
  initialIndex?: number
  onClose?: () => void
}

export function GalleryLightbox({
  media,
  initialIndex = 0,
  onClose,
}: GalleryLightboxProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [currentIndex, setCurrentIndex] = useState(initialIndex)

  useEffect(() => {
    if (initialIndex !== null && initialIndex >= 0) {
      setIsOpen(true)
      setCurrentIndex(initialIndex)
    }
  }, [initialIndex])

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden"
    } else {
      document.body.style.overflow = "unset"
    }
    return () => {
      document.body.style.overflow = "unset"
    }
  }, [isOpen])

  const currentItem = media[currentIndex]
  const hasPrevious = currentIndex > 0
  const hasNext = currentIndex < media.length - 1

  const goToPrevious = () => {
    if (hasPrevious) {
      setCurrentIndex(currentIndex - 1)
    }
  }

  const goToNext = () => {
    if (hasNext) {
      setCurrentIndex(currentIndex + 1)
    }
  }

  useEffect(() => {
    if (!isOpen) return

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "ArrowLeft" && hasPrevious) {
        setCurrentIndex((prev) => prev - 1)
      }
      if (e.key === "ArrowRight" && hasNext) {
        setCurrentIndex((prev) => prev + 1)
      }
      if (e.key === "Escape") {
        setIsOpen(false)
        onClose?.()
      }
    }

    window.addEventListener("keydown", handleKeyDown)
    return () => window.removeEventListener("keydown", handleKeyDown)
  }, [isOpen, hasPrevious, hasNext, onClose])

  const handleClose = () => {
    setIsOpen(false)
    onClose?.()
  }

  if (!currentItem || media.length === 0 || !isOpen) return null

  return (
    <div
      className="fixed inset-0 z-[9999] bg-black/95 flex items-center justify-center"
      onClick={handleClose}
    >
      {/* Close Button */}
      <Button
        variant="ghost"
        size="icon"
        className="absolute top-4 right-4 z-10 bg-white/10 hover:bg-white/20 text-white border-none h-12 w-12"
        onClick={handleClose}
      >
        <X className="h-6 w-6" />
      </Button>

      {/* Previous Button */}
      {hasPrevious && (
        <Button
          variant="ghost"
          size="icon"
          className="absolute left-4 top-1/2 -translate-y-1/2 z-10 bg-white/10 hover:bg-white/20 text-white border-none h-14 w-14"
          onClick={(e) => {
            e.stopPropagation()
            goToPrevious()
          }}
        >
          <ChevronLeft className="h-8 w-8" />
        </Button>
      )}

      {/* Next Button */}
      {hasNext && (
        <Button
          variant="ghost"
          size="icon"
          className="absolute right-4 top-1/2 -translate-y-1/2 z-10 bg-white/10 hover:bg-white/20 text-white border-none h-14 w-14"
          onClick={(e) => {
            e.stopPropagation()
            goToNext()
          }}
        >
          <ChevronRight className="h-8 w-8" />
        </Button>
      )}

      {/* Media Content */}
      <div
        className="relative w-full h-full flex items-center justify-center p-4 md:p-8"
        onClick={(e) => e.stopPropagation()}
      >
        {currentItem.type === "photo" ? (
          <div className="relative w-full h-full max-w-[95vw] max-h-[95vh]">
            <Image
              src={currentItem.url}
              alt={currentItem.title || "Galeri görseli"}
              fill
              className="object-contain"
              priority
              unoptimized={shouldUnoptimizeImage(currentItem.url)}
            />
          </div>
        ) : (
          <video
            src={currentItem.url}
            controls
            autoPlay
            className="max-w-[95vw] max-h-[95vh]"
            onClick={(e) => e.stopPropagation()}
          />
        )}

        {/* Title */}
        {currentItem.title && (
          <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-black/80 text-white px-6 py-3 rounded-lg text-center max-w-[90%]">
            {currentItem.title}
          </div>
        )}

        {/* Counter */}
        <div className="absolute top-4 left-4 bg-black/80 text-white px-4 py-2 rounded-lg text-sm font-medium">
          {currentIndex + 1} / {media.length}
        </div>
      </div>
    </div>
  )
}
