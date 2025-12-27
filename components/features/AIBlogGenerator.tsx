"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Sparkles, Loader2, CheckCircle2, AlertCircle } from "lucide-react"

export default function AIBlogGenerator() {
  const router = useRouter()
  const [count, setCount] = useState(1)
  const [topic, setTopic] = useState("")
  const [isGenerating, setIsGenerating] = useState(false)
  const [progress, setProgress] = useState({ current: 0, total: 0 })
  const [result, setResult] = useState<{ success: boolean; message: string; posts?: any[] } | null>(null)
  const [notification, setNotification] = useState<{ type: "success" | "error"; message: string } | null>(null)

  const handleGenerate = async () => {
    if (count < 1 || count > 10) {
      setNotification({
        type: "error",
        message: "Blog sayısı 1 ile 10 arasında olmalıdır",
      })
      setTimeout(() => setNotification(null), 5000)
      return
    }

    setIsGenerating(true)
    setProgress({ current: 0, total: count })
    setResult(null)

    try {
      const response = await fetch("/api/admin/blog/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          count: parseInt(count.toString()),
          topic: topic.trim() || undefined,
        }),
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Blog oluşturma başarısız")
      }

      setResult({
        success: true,
        message: data.message || `${data.count} blog yazısı başarıyla oluşturuldu`,
        posts: data.posts,
      })

      setNotification({
        type: "success",
        message: data.message,
      })

      // 2 saniye sonra blog listesine yönlendir
      setTimeout(() => {
        router.push("/admin/blog")
        router.refresh()
      }, 2000)
    } catch (error: any) {
      setResult({
        success: false,
        message: error.message || "Blog oluşturma sırasında bir hata oluştu",
      })

      setNotification({
        type: "error",
        message: error.message || "Blog oluşturma sırasında bir hata oluştu",
      })
      setTimeout(() => setNotification(null), 5000)
    } finally {
      setIsGenerating(false)
      setProgress({ current: 0, total: 0 })
    }
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-amber-600" />
            <CardTitle>AI ile Blog Yazısı Oluştur</CardTitle>
          </div>
          <CardDescription>
            Gemini AI kullanarak SEO uyumlu, profesyonel blog yazıları oluşturun
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {notification && (
            <div
              className={`p-4 rounded-lg border ${
                notification.type === "success"
                  ? "bg-green-50 border-green-200"
                  : "bg-red-50 border-red-200"
              }`}
            >
              <div className="flex items-center gap-2">
                {notification.type === "success" ? (
                  <CheckCircle2 className="h-5 w-5 text-green-600" />
                ) : (
                  <AlertCircle className="h-5 w-5 text-red-600" />
                )}
                <p
                  className={`text-sm font-medium ${
                    notification.type === "success" ? "text-green-900" : "text-red-900"
                  }`}
                >
                  {notification.message}
                </p>
              </div>
            </div>
          )}

          <div className="space-y-2">
            <Label htmlFor="count">Oluşturulacak Blog Sayısı</Label>
            <Input
              id="count"
              type="number"
              min="1"
              max="10"
              value={count}
              onChange={(e) => setCount(parseInt(e.target.value) || 1)}
              disabled={isGenerating}
            />
            <p className="text-sm text-muted-foreground">
              1 ile 10 arasında bir sayı girin (her blog için yaklaşık 10-15 saniye sürebilir)
            </p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="topic">Konu (Opsiyonel)</Label>
            <Textarea
              id="topic"
              placeholder="Örn: Düğün fotoğrafçılığında ışık kullanımı, Ürün fotoğrafçılığı ipuçları..."
              value={topic}
              onChange={(e) => setTopic(e.target.value)}
              disabled={isGenerating}
              rows={3}
            />
            <p className="text-sm text-muted-foreground">
              Belirtmezseniz, AI otomatik olarak fotoğrafçılık ile ilgili güncel bir konu seçecektir
            </p>
          </div>

          {isGenerating && (
            <div className="space-y-2 p-4 bg-amber-50 rounded-lg border border-amber-200">
              <div className="flex items-center gap-2">
                <Loader2 className="h-4 w-4 animate-spin text-amber-600" />
                <span className="text-sm font-medium text-amber-900">
                  Blog yazıları oluşturuluyor... ({progress.current}/{progress.total})
                </span>
              </div>
              <p className="text-xs text-amber-700">
                Lütfen bekleyin, bu işlem birkaç dakika sürebilir...
              </p>
            </div>
          )}

          {result && (
            <div
              className={`p-4 rounded-lg border ${
                result.success
                  ? "bg-green-50 border-green-200"
                  : "bg-red-50 border-red-200"
              }`}
            >
              <div className="flex items-start gap-2">
                {result.success ? (
                  <CheckCircle2 className="h-5 w-5 text-green-600 mt-0.5" />
                ) : (
                  <AlertCircle className="h-5 w-5 text-red-600 mt-0.5" />
                )}
                <div className="flex-1">
                  <p
                    className={`text-sm font-medium ${
                      result.success ? "text-green-900" : "text-red-900"
                    }`}
                  >
                    {result.message}
                  </p>
                  {result.success && result.posts && result.posts.length > 0 && (
                    <div className="mt-2 space-y-1">
                      <p className="text-xs text-green-700 font-medium">Oluşturulan bloglar:</p>
                      <ul className="text-xs text-green-700 list-disc list-inside">
                        {result.posts.map((post) => (
                          <li key={post.id}>{post.title}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          <Button
            onClick={handleGenerate}
            disabled={isGenerating || count < 1 || count > 10}
            className="w-full"
            size="lg"
          >
            {isGenerating ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Oluşturuluyor...
              </>
            ) : (
              <>
                <Sparkles className="mr-2 h-4 w-4" />
                Blog Yazılarını Oluştur
              </>
            )}
          </Button>

          <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
            <p className="text-sm text-blue-900 font-medium mb-2">💡 İpuçları:</p>
            <ul className="text-xs text-blue-800 space-y-1 list-disc list-inside">
              <li>Oluşturulan bloglar varsayılan olarak yayınlanmamış durumda olacaktır</li>
              <li>Blogları oluşturduktan sonra düzenleyip yayınlayabilirsiniz</li>
              <li>Her blog SEO uyumlu başlık, meta açıklama ve anahtar kelimeler içerir</li>
              <li>İçerikler en az 800 kelime olacak şekilde optimize edilir</li>
            </ul>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

