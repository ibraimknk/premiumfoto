import FAQForm from "@/components/features/FAQForm"

export default function NewFAQPage() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Yeni Soru Ekle</h1>
        <p className="text-muted-foreground">Yeni bir SSS sorusu ekleyin</p>
      </div>
      <FAQForm />
    </div>
  )
}

