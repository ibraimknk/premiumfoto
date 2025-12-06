"use client"

import { useState, useRef } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Upload, X, Image as ImageIcon, Video, Loader2 } from "lucide-react"
import Image from "next/image"

interface UploadedFile {
  name: string
  url: string
  size: number
  type: string
}

interface GalleryUploadProps {
  onFilesUploaded: (files: UploadedFile[]) => void
}

const CATEGORIES = [
  "Tümü",
  "Düğün",
  "Nişan",
  "Dış Çekim",
  "Ürün",
  "Stüdyo",
  "Vesikalık",
  "Kurumsal",
  "Diğer",
]

export function GalleryUpload({ onFilesUploaded }: GalleryUploadProps) {
  const [isUploading, setIsUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState(0)
  const [selectedFiles, setSelectedFiles] = useState<File[]>([])
  const [previews, setPreviews] = useState<string[]>([])
  const [uploadedFiles, setUploadedFiles] = useState<UploadedFile[]>([])
  const [selectedCategory, setSelectedCategory] = useState("")
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    setSelectedFiles(files)

    // Preview oluştur
    const newPreviews: string[] = []
    files.forEach((file) => {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader()
        reader.onload = (e) => {
          if (e.target?.result) {
            newPreviews.push(e.target.result as string)
            setPreviews([...newPreviews])
          }
        }
        reader.readAsDataURL(file)
      } else {
        newPreviews.push("")
        setPreviews([...newPreviews])
      }
    })
  }

  const removeFile = (index: number) => {
    const newFiles = selectedFiles.filter((_, i) => i !== index)
    const newPreviews = previews.filter((_, i) => i !== index)
    setSelectedFiles(newFiles)
    setPreviews(newPreviews)
    if (fileInputRef.current) {
      fileInputRef.current.value = ""
    }
  }

  const handleUpload = async () => {
    if (selectedFiles.length === 0) return

    setIsUploading(true)
    setUploadProgress(0)

    try {
      const formData = new FormData()
      selectedFiles.forEach((file) => {
        formData.append("files", file)
      })

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
      
      if (!data.success || !data.files) {
        throw new Error(data.error || "Yükleme başarısız")
      }
      setUploadedFiles(data.files)
      // Kategori ile birlikte callback'e gönder
      onFilesUploaded(data.files.map((file: UploadedFile) => ({
        ...file,
        category: selectedCategory || "Diğer",
      })))
      
      // Temizle
      setSelectedFiles([])
      setPreviews([])
      if (fileInputRef.current) {
        fileInputRef.current.value = ""
      }
    } catch (error) {
      console.error("Upload error:", error)
      alert("Dosya yükleme hatası: " + (error as Error).message)
    } finally {
      setIsUploading(false)
      setUploadProgress(0)
    }
  }

  const getFileType = (file: File) => {
    if (file.type.startsWith("image/")) return "photo"
    if (file.type.startsWith("video/")) return "video"
    return "photo"
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Toplu Dosya Yükleme</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div>
          <Label htmlFor="category">Kategori/Etiket *</Label>
          <select
            id="category"
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="w-full rounded-lg border border-input bg-background px-3 py-2 mb-4"
            required
          >
            <option value="">Kategori Seçin</option>
            {CATEGORIES.filter((cat) => cat !== "Tümü").map((cat) => (
              <option key={cat} value={cat}>
                {cat}
              </option>
            ))}
          </select>
        </div>
        <div>
          <input
            ref={fileInputRef}
            type="file"
            multiple
            accept="image/*,video/*"
            onChange={handleFileSelect}
            className="hidden"
            id="file-upload"
            disabled={!selectedCategory}
          />
          <label htmlFor="file-upload">
            <Button
              type="button"
              variant="outline"
              className="w-full"
              asChild
              disabled={!selectedCategory}
            >
              <span>
                <Upload className="mr-2 h-4 w-4" />
                Dosyaları Seç (Çoklu Seçim)
              </span>
            </Button>
          </label>
          {!selectedCategory && (
            <p className="text-xs text-muted-foreground mt-1">
              Önce kategori seçin
            </p>
          )}
        </div>

        {selectedFiles.length > 0 && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {selectedFiles.map((file, index) => (
                <div
                  key={index}
                  className="relative border rounded-lg overflow-hidden group"
                >
                  {previews[index] ? (
                    <div className="relative aspect-square">
                      <Image
                        src={previews[index]}
                        alt={file.name}
                        fill
                        className="object-cover"
                        unoptimized={true}
                      />
                    </div>
                  ) : (
                    <div className="aspect-square bg-neutral-100 flex items-center justify-center">
                      {getFileType(file) === "video" ? (
                        <Video className="h-12 w-12 text-neutral-400" />
                      ) : (
                        <ImageIcon className="h-12 w-12 text-neutral-400" />
                      )}
                    </div>
                  )}
                  <button
                    type="button"
                    onClick={() => removeFile(index)}
                    className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    <X className="h-4 w-4" />
                  </button>
                  <div className="p-2 bg-white">
                    <p className="text-xs truncate">{file.name}</p>
                    <p className="text-xs text-muted-foreground">
                      {(file.size / 1024 / 1024).toFixed(2)} MB
                    </p>
                  </div>
                </div>
              ))}
            </div>

            <div className="flex items-center gap-4">
              <Button
                onClick={handleUpload}
                disabled={isUploading || !selectedCategory}
                className="flex-1"
              >
                {isUploading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Yükleniyor... ({selectedFiles.length} dosya)
                  </>
                ) : (
                  <>
                    <Upload className="mr-2 h-4 w-4" />
                    Yükle ({selectedFiles.length} dosya) - {selectedCategory}
                  </>
                )}
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  setSelectedFiles([])
                  setPreviews([])
                  if (fileInputRef.current) {
                    fileInputRef.current.value = ""
                  }
                }}
              >
                Temizle
              </Button>
            </div>
          </div>
        )}

        {uploadedFiles.length > 0 && (
          <div className="p-4 bg-green-50 text-green-800 rounded-md">
            <p className="font-semibold">
              ✅ {uploadedFiles.length} dosya başarıyla yüklendi!
            </p>
            <p className="text-sm mt-1">
              Dosyalar otomatik olarak medya listesine eklenecek.
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

