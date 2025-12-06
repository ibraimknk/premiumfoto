import { prisma } from "@/lib/prisma"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import Link from "next/link"
import { Plus } from "lucide-react"
import { TestimonialsList } from "@/components/features/TestimonialsList"

export default async function AdminTestimonialsPage() {
  const testimonials = await prisma.testimonial.findMany({
    orderBy: { order: "asc" },
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Müşteri Yorumları</h1>
          <p className="text-muted-foreground">Müşteri yorumlarını yönetin</p>
        </div>
        <Button asChild>
          <Link href="/admin/testimonials/new">
            <Plus className="mr-2 h-4 w-4" />
            Yeni Yorum
          </Link>
        </Button>
      </div>

      <TestimonialsList testimonials={testimonials} />

      {testimonials.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-muted-foreground mb-4">Henüz yorum eklenmemiş.</p>
            <Button asChild>
              <Link href="/admin/testimonials/new">İlk Yorumu Ekle</Link>
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

