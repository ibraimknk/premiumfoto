import { prisma } from "@/lib/prisma"
import { generatePageMetadata } from "@/lib/seo"
import { GalleryClient } from "./GalleryClient"

export async function generateMetadata() {
  return await generatePageMetadata(
    "Galeri - Foto Uğur",
    "Çalışmalarımızdan örnekler. Dış mekan, düğün, ürün fotoğrafçılığı ve daha fazlası.",
    "galeri, portfolyo, fotoğraf örnekleri"
  )
}

export default async function GalleryPage() {
  const media = await prisma.media.findMany({
    where: { isActive: true },
    orderBy: { order: 'asc' },
  })

  const categories = Array.from(
    new Set(media.map((m) => m.category).filter((c): c is string => Boolean(c)))
  )

  return <GalleryClient media={media} categories={categories} />
}

