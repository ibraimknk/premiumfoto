import { prisma } from "@/lib/prisma"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import Link from "next/link"
import { Plus } from "lucide-react"
import { FAQList } from "@/components/features/FAQList"

export default async function AdminFAQPage() {
  const faqs = await prisma.fAQ.findMany({
    orderBy: { order: "asc" },
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Sıkça Sorulan Sorular</h1>
          <p className="text-muted-foreground">SSS içeriklerini yönetin</p>
        </div>
        <Button asChild>
          <Link href="/admin/faq/new">
            <Plus className="mr-2 h-4 w-4" />
            Yeni Soru
          </Link>
        </Button>
      </div>

      <FAQList faqs={faqs} />

      {faqs.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-muted-foreground mb-4">Henüz SSS eklenmemiş.</p>
            <Button asChild>
              <Link href="/admin/faq/new">İlk Soruyu Ekle</Link>
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

