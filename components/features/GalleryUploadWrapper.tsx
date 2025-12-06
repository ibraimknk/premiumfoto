"use client"

import { GalleryUpload } from "./GalleryUpload"

export function GalleryUploadWrapper() {
  const handleFilesUploaded = async (files: any[]) => {
    // Yüklenen dosyaları otomatik olarak medya listesine ekle
    for (const file of files) {
      const isVideo = file.type.startsWith("video/")
      await fetch("/api/admin/gallery", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: file.name.replace(/\.[^/.]+$/, ""), // Extension'ı kaldır
          url: file.url,
          type: isVideo ? "video" : "photo",
          category: file.category || "Diğer", // Kategoriyi kullan
          thumbnail: isVideo ? "" : file.url,
          isActive: true,
          order: 0,
        }),
      })
    }
    // Sayfayı yenile
    window.location.reload()
  }

  return <GalleryUpload onFilesUploaded={handleFilesUploaded} />
}

