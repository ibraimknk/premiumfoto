import TestimonialForm from "@/components/features/TestimonialForm"

export default function NewTestimonialPage() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Yeni Müşteri Yorumu</h1>
        <p className="text-muted-foreground">Yeni bir müşteri yorumu ekleyin</p>
      </div>
      <TestimonialForm />
    </div>
  )
}

