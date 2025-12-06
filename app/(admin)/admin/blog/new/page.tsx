import BlogForm from "@/components/features/BlogForm"

export default function NewBlogPage() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Yeni Blog Yazısı</h1>
        <p className="text-muted-foreground">Yeni bir blog yazısı ekleyin</p>
      </div>
      <BlogForm />
    </div>
  )
}

