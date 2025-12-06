import { redirect } from "next/navigation"
import ServiceForm from "@/components/features/ServiceForm"

export default function NewServicePage() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Yeni Hizmet Ekle</h1>
        <p className="text-muted-foreground">Yeni bir hizmet ekleyin</p>
      </div>
      <ServiceForm />
    </div>
  )
}

