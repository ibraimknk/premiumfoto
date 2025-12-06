import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import FAQForm from "@/components/features/FAQForm"

export default async function EditFAQPage({
  params,
}: {
  params: { id: string }
}) {
  const faq = await prisma.fAQ.findUnique({
    where: { id: params.id },
  })

  if (!faq) {
    notFound()
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">SSS Düzenle</h1>
        <p className="text-muted-foreground">{faq.question}</p>
      </div>
      <FAQForm initialData={faq} />
    </div>
  )
}

