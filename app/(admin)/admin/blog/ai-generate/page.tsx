import AIBlogGenerator from "@/components/features/AIBlogGenerator"

export default function AIGenerateBlogPage() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">AI ile Blog Yazısı Oluştur</h1>
        <p className="text-muted-foreground">
          Gemini AI kullanarak SEO uyumlu blog yazıları oluşturun
        </p>
      </div>
      <AIBlogGenerator />
    </div>
  )
}

