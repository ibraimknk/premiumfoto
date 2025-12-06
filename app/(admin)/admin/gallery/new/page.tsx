import GalleryForm from "@/components/features/GalleryForm"

export default function NewGalleryPage() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Yeni Medya Ekle</h1>
        <p className="text-muted-foreground">Yeni bir fotoğraf veya video ekleyin</p>
      </div>
      <GalleryForm />
    </div>
  )
}

