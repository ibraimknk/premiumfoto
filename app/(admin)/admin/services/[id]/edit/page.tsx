import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import ServiceForm from "@/components/features/ServiceForm"

export default async function EditServicePage({
  params,
}: {
  params: { id: string }
}) {
  const service = await prisma.service.findUnique({
    where: { id: params.id },
  })

  if (!service) {
    notFound()
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Hizmet Düzenle</h1>
        <p className="text-muted-foreground">{service.title}</p>
      </div>
      <ServiceForm initialData={service} />
    </div>
  )
}

