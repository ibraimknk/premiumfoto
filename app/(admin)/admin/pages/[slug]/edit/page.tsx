import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import PageForm from "@/components/features/PageForm"

export default async function EditPagePage({
  params,
}: {
  params: { slug: string }
}) {
  const page = await prisma.page.findUnique({
    where: { slug: params.slug },
  })

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Sayfa Düzenle</h1>
        <p className="text-muted-foreground">
          {page?.title || params.slug}
        </p>
      </div>
      <PageForm initialData={page} slug={params.slug} />
    </div>
  )
}

