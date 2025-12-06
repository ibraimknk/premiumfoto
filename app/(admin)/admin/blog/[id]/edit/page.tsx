import { notFound } from "next/navigation"
import { prisma } from "@/lib/prisma"
import BlogForm from "@/components/features/BlogForm"

export default async function EditBlogPage({
  params,
}: {
  params: { id: string }
}) {
  const post = await prisma.blogPost.findUnique({
    where: { id: params.id },
  })

  if (!post) {
    notFound()
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Blog Yazısı Düzenle</h1>
        <p className="text-muted-foreground">{post.title}</p>
      </div>
      <BlogForm initialData={post} />
    </div>
  )
}

