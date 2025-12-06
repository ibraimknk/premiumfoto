import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import TestimonialForm from "@/components/features/TestimonialForm"

export default async function EditTestimonialPage({
  params,
}: {
  params: { id: string }
}) {
  const testimonial = await prisma.testimonial.findUnique({
    where: { id: params.id },
  })

  if (!testimonial) {
    notFound()
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Müşteri Yorumu Düzenle</h1>
        <p className="text-muted-foreground">{testimonial.name}</p>
      </div>
      <TestimonialForm initialData={testimonial} />
    </div>
  )
}

