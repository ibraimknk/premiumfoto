import { prisma } from "@/lib/prisma"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import Link from "next/link"
import { Plus } from "lucide-react"
import { ServicesList } from "@/components/features/ServicesList"

export default async function AdminServicesPage() {
  const services = await prisma.service.findMany({
    orderBy: { order: "asc" },
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Hizmetler</h1>
          <p className="text-muted-foreground">Hizmetlerinizi yönetin</p>
        </div>
        <Button asChild>
          <Link href="/admin/services/new">
            <Plus className="mr-2 h-4 w-4" />
            Yeni Hizmet
          </Link>
        </Button>
      </div>

      <ServicesList services={services} />

      {services.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-muted-foreground mb-4">Henüz hizmet eklenmemiş.</p>
            <Button asChild>
              <Link href="/admin/services/new">İlk Hizmeti Ekle</Link>
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

