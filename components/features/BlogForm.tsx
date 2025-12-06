"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { MediaPicker } from "@/components/features/MediaPicker"

interface BlogFormProps {
  initialData?: {
    id: string
    title: string
    slug: string
    excerpt: string | null
    content: string | null
    category: string | null
    coverImage: string | null
    seoTitle: string | null
    seoDescription: string | null
    seoKeywords: string | null
    isPublished: boolean
    publishedAt: Date | null
  }
}

export default function BlogForm({ initialData }: BlogFormProps) {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const [formData, setFormData] = useState({
    title: initialData?.title || "",
    slug: initialData?.slug || "",
    excerpt: initialData?.excerpt || "",
    content: initialData?.content || "",
    category: initialData?.category || "",
    coverImage: initialData?.coverImage || "",
    seoTitle: initialData?.seoTitle || "",
    seoDescription: initialData?.seoDescription || "",
    seoKeywords: initialData?.seoKeywords || "",
    isPublished: initialData?.isPublished ?? false,
    publishedAt: initialData?.publishedAt
      ? new Date(initialData.publishedAt).toISOString().split("T")[0]
      : new Date().toISOString().split("T")[0],
  })

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
        ? `/api/admin/blog/${initialData.id}`
        : "/api/admin/blog"
      const method = initialData ? "PUT" : "POST"

      const response = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...formData,
          publishedAt: formData.isPublished ? formData.publishedAt : null,
        }),
      })

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.error || "Bir hata oluştu")
      }

      router.push("/admin/blog")
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
              <Label htmlFor="excerpt">Özet</Label>
              <Textarea
                id="excerpt"
                value={formData.excerpt}
                onChange={(e) =>
                  setFormData({ ...formData, excerpt: e.target.value })
                }
                rows={2}
              />
            </div>
            <div>
              <Label htmlFor="content">İçerik</Label>
              <Textarea
                id="content"
                value={formData.content}
                onChange={(e) =>
                  setFormData({ ...formData, content: e.target.value })
                }
                rows={10}
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
              <Label>Kapak Görseli</Label>
              <MediaPicker
                value={formData.coverImage || undefined}
                onChange={(url) =>
                  setFormData({ ...formData, coverImage: url })
                }
                type="image"
                label="Görsel Seç"
              />
              <Input
                id="coverImage"
                value={formData.coverImage}
                onChange={(e) =>
                  setFormData({ ...formData, coverImage: e.target.value })
                }
                placeholder="veya URL girin"
                className="mt-2"
              />
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="isPublished"
                  checked={formData.isPublished}
                  onChange={(e) =>
                    setFormData({ ...formData, isPublished: e.target.checked })
                  }
                  className="rounded"
                />
                <Label htmlFor="isPublished">Yayınla</Label>
              </div>
              {formData.isPublished && (
                <div>
                  <Label htmlFor="publishedAt">Yayın Tarihi</Label>
                  <Input
                    id="publishedAt"
                    type="date"
                    value={formData.publishedAt}
                    onChange={(e) =>
                      setFormData({ ...formData, publishedAt: e.target.value })
                    }
                  />
                </div>
              )}
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

