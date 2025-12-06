"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"
import { Edit } from "lucide-react"
import { DeleteButton } from "@/components/features/DeleteButton"
import Image from "next/image"
import { ImageIcon, Video, Play } from "lucide-react"
import { GalleryLightbox } from "@/components/features/GalleryLightbox"
import { shouldUnoptimizeImage } from "@/lib/image-utils"

interface Media {
  id: string
  title: string | null
  url: string
  type: string
  category: string | null
  thumbnail: string | null
  isActive: boolean
}

interface GalleryListProps {
  media: Media[]
  isAdmin?: boolean
  filterCategory?: string
}

export function GalleryList({ media, isAdmin = false, filterCategory }: GalleryListProps) {
  const [lightboxIndex, setLightboxIndex] = useState<number | null>(null)
  const [filteredMedia, setFilteredMedia] = useState(media)

  useEffect(() => {
    if (filterCategory && filterCategory !== "Tümü") {
      setFilteredMedia(media.filter((item) => item.category === filterCategory))
    } else {
      setFilteredMedia(media)
    }
  }, [filterCategory, media])

  if (isAdmin) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {media.map((item) => (
          <Card key={item.id} className="overflow-hidden">
            <div className="relative aspect-square">
              {item.type === "photo" ? (
                <Image
                  src={item.url}
                  alt={item.title || "Galeri görseli"}
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
              <div className="absolute top-2 right-2">
                {item.type === "photo" ? (
                  <ImageIcon className="h-5 w-5 text-white bg-black/50 rounded p-1" />
                ) : (
                  <Video className="h-5 w-5 text-white bg-black/50 rounded p-1" />
                )}
              </div>
            </div>
            <CardHeader>
              <CardTitle className="text-base">{item.title || "Başlıksız"}</CardTitle>
              {item.category && (
                <p className="text-sm text-muted-foreground">{item.category}</p>
              )}
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <span
                  className={`px-2 py-1 rounded text-xs ${
                    item.isActive
                      ? "bg-green-100 text-green-800"
                      : "bg-gray-100 text-gray-800"
                  }`}
                >
                  {item.isActive ? "Aktif" : "Pasif"}
                </span>
                <div className="flex space-x-2">
                  <Button variant="ghost" size="sm" asChild>
                    <Link href={`/admin/gallery/${item.id}/edit`}>
                      <Edit className="h-4 w-4" />
                    </Link>
                  </Button>
                  <DeleteButton
                    onDelete={async () => {
                      if (confirm("Bu medyayı silmek istediğinize emin misiniz?")) {
                        const response = await fetch(`/api/admin/gallery/${item.id}`, {
                          method: "DELETE",
                        })
                        if (response.ok) {
                          window.location.reload()
                        }
                      }
                    }}
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <>
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4 lg:gap-6">
        {filteredMedia.map((item, index) => (
          <div
            key={item.id}
            className="relative aspect-square rounded-lg overflow-hidden group cursor-pointer"
            onClick={() => setLightboxIndex(index)}
          >
            {item.type === "photo" ? (
              <Image
                src={item.url}
                alt={item.title ? `${item.title} - Foto Uğur ${item.category || 'galeri'} çalışması` : `Foto Uğur ${item.category || 'galeri'} çalışması`}
                fill
                className="object-cover group-hover:scale-110 transition-transform duration-300"
                unoptimized={shouldUnoptimizeImage(item.url)}
              />
            ) : (
              <>
                {item.thumbnail ? (
                  <Image
                    src={item.thumbnail}
                    alt={item.title ? `${item.title} - Foto Uğur video` : `Foto Uğur ${item.category || 'galeri'} videosu`}
                    fill
                    className="object-cover"
                    unoptimized={shouldUnoptimizeImage(item.thumbnail)}
                  />
                ) : (
                  <div className="w-full h-full bg-black" />
                )}
                <div className="absolute inset-0 flex items-center justify-center bg-black/30">
                  <Play className="h-12 w-12 text-white" />
                </div>
              </>
            )}
          </div>
        ))}
      </div>

      {lightboxIndex !== null && (
        <GalleryLightbox
          media={filteredMedia}
          initialIndex={lightboxIndex}
          onClose={() => setLightboxIndex(null)}
        />
      )}
    </>
  )
}

