import { prisma } from "@/lib/prisma"
import { GalleryClient } from "./GalleryClient"
import { Metadata } from "next"

export const metadata: Metadata = {
  title: "Galeri / Portfolyo | Foto Uğur",
  description: "Düğün, nişan, dış çekim, ürün ve stüdyo çalışmalarımızdan seçilmiş kareler. Daha fazla örnek için stüdyomuzu ziyaret edebilirsiniz.",
  openGraph: {
    title: "Galeri / Portfolyo | Foto Uğur",
    description: "Düğün, nişan, dış çekim, ürün ve stüdyo çalışmalarımızdan seçilmiş kareler.",
  },
}

export default async function GaleriPage() {
  // Aktif medyaları çek
  const media = await prisma.media.findMany({
    where: { isActive: true },
    orderBy: { order: "asc" },
    select: {
      id: true,
      title: true,
      url: true,
      type: true,
      category: true,
      thumbnail: true,
      isActive: true,
    },
  })

  // Kategorileri çıkar (benzersiz)
  const categories = Array.from(
    new Set(
      media
        .map((item) => item.category)
        .filter((cat): cat is string => cat !== null && cat !== "")
    )
  )

  return <GalleryClient media={media} categories={categories} />
}

