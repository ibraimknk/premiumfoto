"use client"

import { GalleryUpload } from "./GalleryUpload"

// SEO uyumlu başlık oluşturma
const generateSeoTitle = (category: string, index: number): string => {
  const seoKeywords: { [key: string]: string[] } = {
    "Düğün": [
      "Ataşehir düğün fotoğrafçısı çalışması",
      "İstanbul düğün fotoğrafı örneği",
      "Profesyonel düğün çekimi Foto Uğur",
      "Ataşehir fotoğrafçı düğün albümü",
      "İstanbul düğün fotoğrafçısı Foto Uğur",
    ],
    "Nişan": [
      "Ataşehir nişan fotoğrafçısı çalışması",
      "İstanbul nişan fotoğrafı örneği",
      "Profesyonel nişan çekimi Foto Uğur",
      "Ataşehir fotoğrafçı nişan çekimi",
      "İstanbul nişan fotoğrafçısı Foto Uğur",
    ],
    "Dış Çekim": [
      "Ataşehir dış mekan fotoğraf çekimi",
      "İstanbul dış çekim fotoğrafçısı Foto Uğur",
      "Profesyonel dış mekan çekimi örneği",
      "Ataşehir fotoğrafçı dış çekim çalışması",
      "İstanbul açık hava fotoğraf çekimi",
    ],
    "Ürün": [
      "Ataşehir ürün fotoğrafçılığı örneği",
      "Profesyonel ürün çekimi Foto Uğur",
      "İstanbul ürün fotoğrafçısı çalışması",
      "Ataşehir fotoğrafçı ürün çekimi",
      "Katalog ürün fotoğrafı örneği",
    ],
    "Stüdyo": [
      "Ataşehir stüdyo fotoğraf çekimi",
      "Profesyonel stüdyo çekimi Foto Uğur",
      "İstanbul stüdyo fotoğrafçısı örneği",
      "Ataşehir fotoğrafçı stüdyo çalışması",
      "Premium stüdyo fotoğraf örneği",
    ],
    "Vesikalık": [
      "Ataşehir vesikalık fotoğraf çekimi",
      "Biyometrik vesikalık Foto Uğur",
      "İstanbul profesyonel vesikalık",
      "Ataşehir fotoğrafçı vesikalık çekimi",
      "Dijital vesikalık fotoğraf örneği",
    ],
    "Kurumsal": [
      "Ataşehir kurumsal fotoğraf çekimi",
      "Profesyonel kurumsal fotoğrafçı Foto Uğur",
      "İstanbul iş yeri fotoğrafı örneği",
      "Ataşehir fotoğrafçı kurumsal çalışma",
      "Şirket tanıtım fotoğrafçılığı",
    ],
    "Diğer": [
      "Ataşehir fotoğrafçı Foto Uğur çalışması",
      "İstanbul profesyonel fotoğraf örneği",
      "Ataşehir fotoğraf stüdyosu çekimi",
      "Foto Uğur profesyonel çalışma",
      "İstanbul Ataşehir fotoğrafçı örneği",
    ],
  }

  const keywords = seoKeywords[category] || seoKeywords["Diğer"]
  return keywords[index % keywords.length]
}

export function GalleryUploadWrapper() {
  const handleFilesUploaded = async (files: any[]) => {
    // Yüklenen dosyaları otomatik olarak medya listesine ekle
    for (let i = 0; i < files.length; i++) {
      const file = files[i]
      const isVideo = file.type.startsWith("video/")
      const category = file.category || "Diğer"
      const seoTitle = generateSeoTitle(category, i + Date.now())
      
      await fetch("/api/admin/gallery", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: seoTitle, // SEO uyumlu başlık
          url: file.url,
          type: isVideo ? "video" : "photo",
          category: category,
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

