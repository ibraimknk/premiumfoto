import { prisma } from "@/lib/prisma"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import Link from "next/link"
import { Plus } from "lucide-react"
import { GalleryList } from "@/components/features/GalleryList"
import { GalleryUploadWrapper } from "@/components/features/GalleryUploadWrapper"

export default async function AdminGalleryPage() {
  const media = await prisma.media.findMany({
    orderBy: { order: "asc" },
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Galeri</h1>
          <p className="text-muted-foreground">Fotoğraf ve videoları yönetin</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" asChild>
            <Link href="/admin/gallery/instagram-import">
              <Plus className="mr-2 h-4 w-4" />
              Instagram&apos;dan İçe Aktar
            </Link>
          </Button>
          <Button variant="outline" asChild>
            <Link href="/admin/gallery/new">
              <Plus className="mr-2 h-4 w-4" />
              Manuel Ekle
            </Link>
          </Button>
        </div>
      </div>

      {/* Toplu Yükleme */}
      <div className="mb-8">
        <GalleryUploadWrapper />
      </div>

      <GalleryList media={media} isAdmin={true} />

      {media.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-muted-foreground mb-4">Henüz medya eklenmemiş.</p>
            <Button asChild>
              <Link href="/admin/gallery/new">İlk Medyayı Ekle</Link>
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

