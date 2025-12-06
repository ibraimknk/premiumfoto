"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { MediaPicker } from "./MediaPicker"
import { X } from "lucide-react"
import Image from "next/image"
import { shouldUnoptimizeImage } from "@/lib/image-utils"

interface CarouselItem {
  id: string
  image: string
  title?: string
  subtitle?: string
}

interface CarouselManagerProps {
  items: CarouselItem[]
  onChange: (items: CarouselItem[]) => void
}

export function CarouselManager({ items, onChange }: CarouselManagerProps) {
  const [editingIndex, setEditingIndex] = useState<number | null>(null)

  const addItem = () => {
    onChange([
      ...items,
      {
        id: Date.now().toString(),
        image: "",
        title: "",
        subtitle: "",
      },
    ])
  }

  const updateItem = (index: number, field: string, value: string) => {
    const newItems = [...items]
    newItems[index] = { ...newItems[index], [field]: value }
    onChange(newItems)
  }

  const removeItem = (index: number) => {
    onChange(items.filter((_, i) => i !== index))
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Carousel Yönetimi</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {items.map((item, index) => (
          <div key={item.id} className="border rounded-lg p-4 space-y-3">
            <div className="flex items-center justify-between">
              <h4 className="font-semibold">Slide {index + 1}</h4>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => removeItem(index)}
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
            <div>
              <MediaPicker
                value={item.image}
                onChange={(url) => updateItem(index, "image", url)}
                type="image"
                label="Görsel Seç"
              />
            </div>
            <div>
              <label className="text-sm font-medium">Başlık</label>
              <input
                type="text"
                value={item.title || ""}
                onChange={(e) => updateItem(index, "title", e.target.value)}
                className="w-full rounded-lg border border-input bg-background px-3 py-2 mt-1"
                placeholder="Başlık (opsiyonel)"
              />
            </div>
            <div>
              <label className="text-sm font-medium">Alt Başlık</label>
              <input
                type="text"
                value={item.subtitle || ""}
                onChange={(e) => updateItem(index, "subtitle", e.target.value)}
                className="w-full rounded-lg border border-input bg-background px-3 py-2 mt-1"
                placeholder="Alt başlık (opsiyonel)"
              />
            </div>
            {item.image && (
              <div className="relative w-full h-32 border rounded-lg overflow-hidden">
                <Image
                  src={item.image}
                  alt={item.title || "Preview"}
                  fill
                  className="object-cover"
                  unoptimized={shouldUnoptimizeImage(item.image)}
                />
              </div>
            )}
          </div>
        ))}
        <Button type="button" variant="outline" onClick={addItem} className="w-full">
          + Yeni Slide Ekle
        </Button>
      </CardContent>
    </Card>
  )
}

