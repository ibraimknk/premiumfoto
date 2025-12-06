"use client"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"
import { Edit } from "lucide-react"
import { DeleteButton } from "@/components/features/DeleteButton"

interface Service {
  id: string
  title: string
  category: string | null
  isActive: boolean
}

interface ServicesListProps {
  services: Service[]
}

export function ServicesList({ services }: ServicesListProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {services.map((service) => (
        <Card key={service.id}>
          <CardHeader>
            <CardTitle>{service.title}</CardTitle>
            <p className="text-sm text-muted-foreground">{service.category}</p>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <span
                className={`px-2 py-1 rounded text-xs ${
                  service.isActive
                    ? "bg-green-100 text-green-800"
                    : "bg-gray-100 text-gray-800"
                }`}
              >
                {service.isActive ? "Aktif" : "Pasif"}
              </span>
              <div className="flex space-x-2">
                <Button variant="ghost" size="sm" asChild>
                  <Link href={`/admin/services/${service.id}/edit`}>
                    <Edit className="h-4 w-4" />
                  </Link>
                </Button>
                <DeleteButton
                  onDelete={async () => {
                    if (confirm("Bu hizmeti silmek istediğinize emin misiniz?")) {
                      const response = await fetch(`/api/admin/services/${service.id}`, {
                        method: "DELETE",
                      })
                      if (response.ok) {
                        window.location.reload()
                      }
                    }
                  }}
                />
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}

