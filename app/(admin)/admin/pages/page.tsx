import { prisma } from "@/lib/prisma"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"
import { Plus, Edit, FileText } from "lucide-react"

export default async function AdminPagesPage() {
  const pages = await prisma.page.findMany({
    orderBy: { title: "asc" },
  })

  const defaultPages = [
    { slug: "hakkimizda", title: "Hakkımızda" },
    { slug: "kvkk", title: "KVKK Aydınlatma Metni" },
    { slug: "gizlilik-politikasi", title: "Gizlilik Politikası" },
    { slug: "cerez-politikasi", title: "Çerez Politikası" },
  ]

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Statik Sayfalar</h1>
          <p className="text-muted-foreground">Sayfa içeriklerini yönetin</p>
        </div>
        <Button asChild>
          <Link href="/admin/pages/new">
            <Plus className="mr-2 h-4 w-4" />
            Yeni Sayfa
          </Link>
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {defaultPages.map((defaultPage) => {
          const page = pages.find((p) => p.slug === defaultPage.slug)
          return (
            <Card key={defaultPage.slug}>
              <CardHeader>
                <div className="flex items-center gap-2 mb-2">
                  <FileText className="h-5 w-5 text-muted-foreground" />
                  <CardTitle className="text-lg">{defaultPage.title}</CardTitle>
                </div>
                <p className="text-sm text-muted-foreground">/{defaultPage.slug}</p>
              </CardHeader>
              <CardContent>
                <Button variant="outline" asChild className="w-full">
                  <Link href={`/admin/pages/${defaultPage.slug}/edit`}>
                    <Edit className="mr-2 h-4 w-4" />
                    {page ? "Düzenle" : "Oluştur"}
                  </Link>
                </Button>
              </CardContent>
            </Card>
          )
        })}

        {pages
          .filter((p) => !defaultPages.find((dp) => dp.slug === p.slug))
          .map((page) => (
            <Card key={page.id}>
              <CardHeader>
                <div className="flex items-center gap-2 mb-2">
                  <FileText className="h-5 w-5 text-muted-foreground" />
                  <CardTitle className="text-lg">{page.title}</CardTitle>
                </div>
                <p className="text-sm text-muted-foreground">/{page.slug}</p>
              </CardHeader>
              <CardContent>
                <Button variant="outline" asChild className="w-full">
                  <Link href={`/admin/pages/${page.slug}/edit`}>
                    <Edit className="mr-2 h-4 w-4" />
                    Düzenle
                  </Link>
                </Button>
              </CardContent>
            </Card>
          ))}
      </div>
    </div>
  )
}

