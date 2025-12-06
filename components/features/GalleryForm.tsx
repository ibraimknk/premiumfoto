"use client"

import { useState, useRef } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Upload, X, Loader2 } from "lucide-react"
import Image from "next/image"
import { shouldUnoptimizeImage } from "@/lib/image-utils"

interface GalleryFormProps {
  initialData?: {
    id: string
    title: string | null
    url: string
    type: string
    category: string | null
    thumbnail: string | null
    isActive: boolean
    order: number
  }
}

export default function GalleryForm({ initialData }: GalleryFormProps) {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const [formData, setFormData] = useState({
    title: initialData?.title || "",
    url: initialData?.url || "",
    type: initialData?.type || "photo",
    category: initialData?.category || "",
    thumbnail: initialData?.thumbnail || "",
    isActive: initialData?.isActive ?? true,
    order: initialData?.order || 0,
  })
  const [isUploading, setIsUploading] = useState(false)
  const [preview, setPreview] = useState<string | null>(initialData?.url || null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    setIsUploading(true)

    try {
      const formData = new FormData()
      formData.append("files", file)

      const response = await fetch("/api/admin/upload", {
        method: "POST",
        body: formData,
      })

      if (!response.ok) {
        // Hata mesajını API'den al
        let errorMessage = "Yükleme başarısız"
        try {
          const errorData = await response.json()
          errorMessage = errorData.error || errorMessage
        } catch {
          errorMessage = `HTTP ${response.status}: ${response.statusText}`
        }
        throw new Error(errorMessage)
      }

      const data = await response.json()
      
      if (!data.success || !data.files || data.files.length === 0) {
        throw new Error(data.error || "Dosya yüklenemedi")
      }
      
      if (data.files && data.files.length > 0) {
        const uploadedFile = data.files[0]
        setFormData((prev) => ({
          ...prev,
          url: uploadedFile.url,
          type: uploadedFile.type.startsWith("video/") ? "video" : "photo",
          thumbnail: uploadedFile.type.startsWith("video/") ? "" : uploadedFile.url,
        }))
        setPreview(uploadedFile.url)
      }
    } catch (error) {
      console.error("Upload error:", error)
      alert("Dosya yükleme hatası: " + (error as Error).message)
    } finally {
      setIsUploading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setIsLoading(true)

    try {
      const url = initialData
        ? `/api/admin/gallery/${initialData.id}`
        : "/api/admin/gallery"
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

      router.push("/admin/gallery")
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
            <CardTitle>Medya Bilgileri</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="title">Başlık</Label>
              <Input
                id="title"
                value={formData.title}
                onChange={(e) =>
                  setFormData({ ...formData, title: e.target.value })
                }
              />
            </div>
            <div>
              <Label htmlFor="url">Dosya Yükle veya URL Gir</Label>
              <div className="space-y-2">
                <div className="flex gap-2">
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/*,video/*"
                    onChange={handleFileSelect}
                    className="hidden"
                    id="file-upload-single"
                  />
                  <label htmlFor="file-upload-single" className="flex-1">
                    <Button
                      type="button"
                      variant="outline"
                      className="w-full"
                      disabled={isUploading}
                      asChild
                    >
                      <span>
                        {isUploading ? (
                          <>
                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                            Yükleniyor...
                          </>
                        ) : (
                          <>
                            <Upload className="mr-2 h-4 w-4" />
                            Dosya Seç
                          </>
                        )}
                      </span>
                    </Button>
                  </label>
                </div>
                {preview && (
                  <div className="relative w-full h-48 border rounded-lg overflow-hidden">
                    {formData.type === "photo" ? (
                      <Image
                        src={preview}
                        alt="Preview"
                        fill
                        className="object-cover"
                        unoptimized={shouldUnoptimizeImage(preview)}
                      />
                    ) : (
                      <video src={preview} controls className="w-full h-full" />
                    )}
                    <button
                      type="button"
                      onClick={() => {
                        setPreview(null)
                        setFormData((prev) => ({ ...prev, url: "", thumbnail: "" }))
                        if (fileInputRef.current) {
                          fileInputRef.current.value = ""
                        }
                      }}
                      className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                )}
                <Input
                  id="url"
                  value={formData.url}
                  onChange={(e) => {
                    setFormData({ ...formData, url: e.target.value })
                    setPreview(e.target.value || null)
                  }}
                  placeholder="/uploads/image.jpg veya URL"
                />
                <p className="text-xs text-muted-foreground">
                  Dosya yükleyebilir veya manuel olarak URL girebilirsiniz
                </p>
              </div>
            </div>
            <div>
              <Label htmlFor="type">Tür *</Label>
              <select
                id="type"
                value={formData.type}
                onChange={(e) =>
                  setFormData({ ...formData, type: e.target.value })
                }
                className="w-full rounded-lg border border-input bg-background px-3 py-2"
                required
              >
                <option value="photo">Fotoğraf</option>
                <option value="video">Video</option>
              </select>
            </div>
            {formData.type === "video" && (
              <div>
                <Label htmlFor="thumbnail">Thumbnail URL</Label>
                <Input
                  id="thumbnail"
                  value={formData.thumbnail}
                  onChange={(e) =>
                    setFormData({ ...formData, thumbnail: e.target.value })
                  }
                  placeholder="/images/gallery/thumbnail.jpg"
                />
              </div>
            )}
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

