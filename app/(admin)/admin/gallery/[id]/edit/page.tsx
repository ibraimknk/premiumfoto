import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import GalleryForm from "@/components/features/GalleryForm"

export default async function EditGalleryPage({
  params,
}: {
  params: { id: string }
}) {
  const media = await prisma.media.findUnique({
    where: { id: params.id },
  })

  if (!media) {
    notFound()
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Medya Düzenle</h1>
        <p className="text-muted-foreground">{media.title || "Başlıksız"}</p>
      </div>
      <GalleryForm initialData={media} />
    </div>
  )
}

