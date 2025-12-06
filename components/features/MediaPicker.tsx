"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Image as ImageIcon, Video, X, Check, Upload } from "lucide-react"
import Image from "next/image"
import { shouldUnoptimizeImage } from "@/lib/image-utils"

interface Media {
  id: string
  url: string
  type: string
  title: string | null
  thumbnail: string | null
}

interface MediaPickerProps {
  value?: string
  onChange: (url: string) => void
  type?: "image" | "video" | "all"
  label?: string
}

export function MediaPicker({
  value,
  onChange,
  type = "all",
  label = "Medya Seç",
}: MediaPickerProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [media, setMedia] = useState<Media[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("Tümü")

  useEffect(() => {
    if (isOpen) {
      fetchMedia()
    }
  }, [isOpen])

  const fetchMedia = async () => {
    setIsLoading(true)
    try {
      const response = await fetch("/api/admin/gallery/list")
      if (response.ok) {
        const data = await response.json()
        setMedia(data.media || [])
      }
    } catch (error) {
      console.error("Error fetching media:", error)
    } finally {
      setIsLoading(false)
    }
  }

  const filteredMedia = media.filter((item) => {
    const matchesType =
      type === "all" ||
      (type === "image" && item.type === "photo") ||
      (type === "video" && item.type === "video")
    const matchesCategory =
      selectedCategory === "Tümü" || item.title?.includes(selectedCategory) || false
    const matchesSearch =
      !searchTerm ||
      item.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      false
    return matchesType && matchesCategory && matchesSearch
  })

  const categories = Array.from(
    new Set(media.map((m) => m.title?.split(" ")[0] || "Diğer").filter(Boolean))
  )

  return (
    <>
      <div className="space-y-2">
        <Button
          type="button"
          variant="outline"
          onClick={() => setIsOpen(true)}
          className="w-full"
        >
          <ImageIcon className="mr-2 h-4 w-4" />
          {value ? "Medya Değiştir" : label}
        </Button>
        {value && (
          <div className="relative w-full h-48 border rounded-lg overflow-hidden">
            <Image
              src={value}
              alt="Selected media"
              fill
              className="object-cover"
              unoptimized={shouldUnoptimizeImage(value)}
            />
            <button
              type="button"
              onClick={() => onChange("")}
              className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>

      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-w-6xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Medya Seç</DialogTitle>
          </DialogHeader>

          <div className="space-y-4">
            {/* Search and Filter */}
            <div className="flex gap-4">
              <Input
                placeholder="Ara..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="flex-1"
              />
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                className="rounded-lg border border-input bg-background px-3 py-2"
              >
                <option value="Tümü">Tümü</option>
                {categories.map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
            </div>

            {/* Media Grid */}
            {isLoading ? (
              <div className="text-center py-12">Yükleniyor...</div>
            ) : (
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {filteredMedia.map((item) => (
                  <div
                    key={item.id}
                    className={`relative aspect-square rounded-lg overflow-hidden border-2 cursor-pointer transition-all ${
                      value === item.url
                        ? "border-amber-500 ring-2 ring-amber-200"
                        : "border-neutral-200 hover:border-amber-300"
                    }`}
                    onClick={() => {
                      onChange(item.url)
                      setIsOpen(false)
                    }}
                  >
                    {item.type === "photo" ? (
                      <Image
                        src={item.url}
                        alt={item.title || "Media"}
                        fill
                        className="object-cover"
                        unoptimized={shouldUnoptimizeImage(item.url)}
                      />
                    ) : (
                      <div className="w-full h-full bg-black flex items-center justify-center">
                        {item.thumbnail ? (
                          <Image
                            src={item.thumbnail}
                            alt={item.title || "Video"}
                            fill
                            className="object-cover opacity-50"
                            unoptimized={shouldUnoptimizeImage(item.thumbnail)}
                          />
                        ) : null}
                        <Video className="h-12 w-12 text-white" />
                      </div>
                    )}
                    {value === item.url && (
                      <div className="absolute inset-0 bg-amber-500/20 flex items-center justify-center">
                        <Check className="h-8 w-8 text-amber-600" />
                      </div>
                    )}
                    {item.title && (
                      <div className="absolute bottom-0 left-0 right-0 bg-black/60 text-white text-xs p-2 truncate">
                        {item.title}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}

            {filteredMedia.length === 0 && !isLoading && (
              <div className="text-center py-12 text-muted-foreground">
                Medya bulunamadı
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>
    </>
  )
}

