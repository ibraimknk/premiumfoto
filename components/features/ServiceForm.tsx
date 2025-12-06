"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { MediaPicker } from "@/components/features/MediaPicker"

interface ServiceFormProps {
  initialData?: {
    id: string
    title: string
    slug: string
    shortDescription: string | null
    description: string | null
    category: string | null
    featuredImage: string | null
    seoTitle: string | null
    seoDescription: string | null
    seoKeywords: string | null
    isActive: boolean
    order: number
  }
}

export default function ServiceForm({ initialData }: ServiceFormProps) {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const [formData, setFormData] = useState({
    title: initialData?.title || "",
    slug: initialData?.slug || "",
    shortDescription: initialData?.shortDescription || "",
    description: initialData?.description || "",
    category: initialData?.category || "",
    featuredImage: initialData?.featuredImage || "",
    seoTitle: initialData?.seoTitle || "",
    seoDescription: initialData?.seoDescription || "",
    seoKeywords: initialData?.seoKeywords || "",
    isActive: initialData?.isActive ?? true,
    order: initialData?.order || 0,
  })

  // Auto-generate slug from title
  useEffect(() => {
    if (!initialData && formData.title) {
      const slug = formData.title
        .toLowerCase()
        .replace(/ğ/g, "g")
        .replace(/ü/g, "u")
        .replace(/ş/g, "s")
        .replace(/ı/g, "i")
        .replace(/ö/g, "o")
        .replace(/ç/g, "c")
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "")
      setFormData((prev) => ({ ...prev, slug }))
    }
  }, [formData.title, initialData])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setIsLoading(true)

    try {
      const url = initialData
        ? `/api/admin/services/${initialData.id}`
        : "/api/admin/services"
      const method = initialData ? "PUT" : "POST"

      const response = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      })

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.error || "Bir hata oluştu")
      }

      router.push("/admin/services")
      router.refresh()
    } catch (err: any) {
      setError(err.message || "Bir hata oluştu")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <div className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Genel Bilgiler</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="title">Başlık *</Label>
              <Input
                id="title"
                value={formData.title}
                onChange={(e) =>
                  setFormData({ ...formData, title: e.target.value })
                }
                required
              />
            </div>
            <div>
              <Label htmlFor="slug">URL Slug *</Label>
              <Input
                id="slug"
                value={formData.slug}
                onChange={(e) =>
                  setFormData({ ...formData, slug: e.target.value })
                }
                required
              />
            </div>
            <div>
              <Label htmlFor="shortDescription">Kısa Açıklama</Label>
              <Textarea
                id="shortDescription"
                value={formData.shortDescription}
                onChange={(e) =>
                  setFormData({ ...formData, shortDescription: e.target.value })
                }
                rows={2}
              />
            </div>
            <div>
              <Label htmlFor="description">Açıklama</Label>
              <Textarea
                id="description"
                value={formData.description}
                onChange={(e) =>
                  setFormData({ ...formData, description: e.target.value })
                }
                rows={6}
                placeholder="HTML içerik ekleyebilirsiniz"
              />
            </div>
            <div>
              <Label htmlFor="category">Kategori</Label>
              <Input
                id="category"
                value={formData.category}
                onChange={(e) =>
                  setFormData({ ...formData, category: e.target.value })
                }
              />
            </div>
            <div>
              <Label>Öne Çıkan Görsel</Label>
              <MediaPicker
                value={formData.featuredImage || undefined}
                onChange={(url) =>
                  setFormData({ ...formData, featuredImage: url })
                }
                type="image"
                label="Görsel Seç"
              />
              <Input
                id="featuredImage"
                value={formData.featuredImage}
                onChange={(e) =>
                  setFormData({ ...formData, featuredImage: e.target.value })
                }
                placeholder="veya URL girin"
                className="mt-2"
              />
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="isActive"
                  checked={formData.isActive}
                  onChange={(e) =>
                    setFormData({ ...formData, isActive: e.target.checked })
                  }
                  className="rounded"
                />
                <Label htmlFor="isActive">Aktif</Label>
              </div>
              <div>
                <Label htmlFor="order">Sıra</Label>
                <Input
                  id="order"
                  type="number"
                  value={formData.order}
                  onChange={(e) =>
                    setFormData({ ...formData, order: parseInt(e.target.value) || 0 })
                  }
                  className="w-24"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>SEO Ayarları</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="seoTitle">SEO Başlığı</Label>
              <Input
                id="seoTitle"
                value={formData.seoTitle}
                onChange={(e) =>
                  setFormData({ ...formData, seoTitle: e.target.value })
                }
              />
            </div>
            <div>
              <Label htmlFor="seoDescription">SEO Açıklaması</Label>
              <Textarea
                id="seoDescription"
                value={formData.seoDescription}
                onChange={(e) =>
                  setFormData({ ...formData, seoDescription: e.target.value })
                }
                rows={2}
              />
            </div>
            <div>
              <Label htmlFor="seoKeywords">SEO Anahtar Kelimeler</Label>
              <Input
                id="seoKeywords"
                value={formData.seoKeywords}
                onChange={(e) =>
                  setFormData({ ...formData, seoKeywords: e.target.value })
                }
                placeholder="kelime1, kelime2, kelime3"
              />
            </div>
          </CardContent>
        </Card>

        {error && (
          <div className="p-4 bg-red-50 text-red-800 rounded-md">{error}</div>
        )}

        <div className="flex gap-4">
          <Button type="submit" disabled={isLoading}>
            {isLoading ? "Kaydediliyor..." : "Kaydet"}
          </Button>
          <Button
            type="button"
            variant="outline"
            onClick={() => router.back()}
          >
            İptal
          </Button>
        </div>
      </div>
    </form>
  )
}

