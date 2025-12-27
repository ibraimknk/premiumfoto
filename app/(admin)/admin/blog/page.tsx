import { prisma } from "@/lib/prisma"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import Link from "next/link"
import { Plus, Sparkles } from "lucide-react"
import { BlogList } from "@/components/features/BlogList"

export default async function AdminBlogPage() {
  const posts = await prisma.blogPost.findMany({
    orderBy: { publishedAt: "desc" },
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Blog Yazıları</h1>
          <p className="text-muted-foreground">Blog yazılarınızı yönetin</p>
        </div>
        <div className="flex gap-2">
          <Button asChild variant="outline">
            <Link href="/admin/blog/ai-generate">
              <Sparkles className="mr-2 h-4 w-4" />
              AI ile Oluştur
            </Link>
          </Button>
          <Button asChild>
            <Link href="/admin/blog/new">
              <Plus className="mr-2 h-4 w-4" />
              Yeni Yazı
            </Link>
          </Button>
        </div>
      </div>

      <BlogList posts={posts} />

      {posts.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-muted-foreground mb-4">Henüz blog yazısı eklenmemiş.</p>
            <Button asChild>
              <Link href="/admin/blog/new">İlk Yazıyı Ekle</Link>
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

