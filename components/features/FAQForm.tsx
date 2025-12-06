"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

interface FAQFormProps {
  initialData?: {
    id: string
    question: string
    answer: string
    isActive: boolean
    order: number
  }
}

export default function FAQForm({ initialData }: FAQFormProps) {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const [formData, setFormData] = useState({
    question: initialData?.question || "",
    answer: initialData?.answer || "",
    isActive: initialData?.isActive ?? true,
    order: initialData?.order || 0,
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setIsLoading(true)

    try {
      const url = initialData
        ? `/api/admin/faq/${initialData.id}`
        : "/api/admin/faq"
      const method = initialData ? "PUT" : "POST"

      const response = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      })

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.error || "Bir hata oluştu")
      }

      router.push("/admin/faq")
      router.refresh()
    } catch (err: any) {
      setError(err.message || "Bir hata oluştu")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <div className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Soru ve Cevap</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="question">Soru *</Label>
              <Input
                id="question"
                value={formData.question}
                onChange={(e) =>
                  setFormData({ ...formData, question: e.target.value })
                }
                required
              />
            </div>
            <div>
              <Label htmlFor="answer">Cevap *</Label>
              <Textarea
                id="answer"
                value={formData.answer}
                onChange={(e) =>
                  setFormData({ ...formData, answer: e.target.value })
                }
                rows={6}
                required
                placeholder="HTML içerik ekleyebilirsiniz"
              />
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="isActive"
                  checked={formData.isActive}
                  onChange={(e) =>
                    setFormData({ ...formData, isActive: e.target.checked })
                  }
                  className="rounded"
                />
                <Label htmlFor="isActive">Aktif</Label>
              </div>
              <div>
                <Label htmlFor="order">Sıra</Label>
                <Input
                  id="order"
                  type="number"
                  value={formData.order}
                  onChange={(e) =>
                    setFormData({ ...formData, order: parseInt(e.target.value) || 0 })
                  }
                  className="w-24"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {error && (
          <div className="p-4 bg-red-50 text-red-800 rounded-md">{error}</div>
        )}

        <div className="flex gap-4">
          <Button type="submit" disabled={isLoading}>
            {isLoading ? "Kaydediliyor..." : "Kaydet"}
          </Button>
          <Button
            type="button"
            variant="outline"
            onClick={() => router.back()}
          >
            İptal
          </Button>
        </div>
      </div>
    </form>
  )
}

