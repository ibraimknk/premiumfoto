"use client"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"
import { Edit } from "lucide-react"
import { DeleteButton } from "@/components/features/DeleteButton"
import { Star } from "lucide-react"

interface Testimonial {
  id: string
  name: string
  comment: string
  serviceType: string | null
  rating: number
  isActive: boolean
}

interface TestimonialsListProps {
  testimonials: Testimonial[]
}

export function TestimonialsList({ testimonials }: TestimonialsListProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {testimonials.map((testimonial) => (
        <Card key={testimonial.id}>
          <CardHeader>
            <div className="flex items-center justify-between mb-2">
              <CardTitle className="text-lg">{testimonial.name}</CardTitle>
              <div className="flex items-center">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <Star key={i} className="h-4 w-4 fill-amber-400 text-amber-400" />
                ))}
              </div>
            </div>
            {testimonial.serviceType && (
              <p className="text-sm text-muted-foreground">{testimonial.serviceType}</p>
            )}
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4 line-clamp-3">
              {testimonial.comment}
            </p>
            <div className="flex items-center justify-between">
              <span
                className={`px-2 py-1 rounded text-xs ${
                  testimonial.isActive
                    ? "bg-green-100 text-green-800"
                    : "bg-gray-100 text-gray-800"
                }`}
              >
                {testimonial.isActive ? "Aktif" : "Pasif"}
              </span>
              <div className="flex space-x-2">
                <Button variant="ghost" size="sm" asChild>
                  <Link href={`/admin/testimonials/${testimonial.id}/edit`}>
                    <Edit className="h-4 w-4" />
                  </Link>
                </Button>
                <DeleteButton
                  onDelete={async () => {
                    if (confirm("Bu yorumu silmek istediğinize emin misiniz?")) {
                      const response = await fetch(`/api/admin/testimonials/${testimonial.id}`, {
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

