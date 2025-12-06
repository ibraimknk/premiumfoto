"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { MediaPicker } from "@/components/features/MediaPicker"

interface PageFormProps {
  initialData?: {
    id: string
    title: string
    slug: string
    content: string | null
    ogImage: string | null
    seoTitle: string | null
    seoDescription: string | null
    seoKeywords: string | null
  } | null
  slug: string
}

export default function PageForm({ initialData, slug }: PageFormProps) {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const [formData, setFormData] = useState({
    title: initialData?.title || "",
    slug: initialData?.slug || slug,
    content: initialData?.content || "",
    ogImage: initialData?.ogImage || "",
    seoTitle: initialData?.seoTitle || "",
    seoDescription: initialData?.seoDescription || "",
    seoKeywords: initialData?.seoKeywords || "",
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setIsLoading(true)

    try {
      const url = `/api/admin/pages/${slug}`
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

      router.push("/admin/pages")
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
            <CardTitle>Sayfa Bilgileri</CardTitle>
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
              <Label htmlFor="slug">URL Slug</Label>
              <Input
                id="slug"
                value={formData.slug}
                disabled
                className="bg-muted"
              />
            </div>
            <div>
              <Label>Öne Çıkan Görsel (OG Image)</Label>
              <MediaPicker
                value={formData.ogImage || undefined}
                onChange={(url) =>
                  setFormData({ ...formData, ogImage: url })
                }
                type="image"
                label="Görsel Seç"
              />
              <Input
                id="ogImage"
                value={formData.ogImage || ""}
                onChange={(e) =>
                  setFormData({ ...formData, ogImage: e.target.value })
                }
                placeholder="veya URL girin"
                className="mt-2"
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
                rows={15}
                placeholder="HTML içerik ekleyebilirsiniz"
              />
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

