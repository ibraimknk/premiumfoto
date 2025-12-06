"use client"

import { Button } from "@/components/ui/button"
import { Card, CardHeader } from "@/components/ui/card"
import Link from "next/link"
import { Edit } from "lucide-react"
import { DeleteButton } from "@/components/features/DeleteButton"

interface FAQ {
  id: string
  question: string
  answer: string
  isActive: boolean
  order: number
}

interface FAQListProps {
  faqs: FAQ[]
}

export function FAQList({ faqs }: FAQListProps) {
  return (
    <div className="space-y-4">
      {faqs.map((faq) => (
        <Card key={faq.id}>
          <CardHeader>
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <h3 className="text-lg font-semibold mb-2">{faq.question}</h3>
                <div
                  className="text-sm text-muted-foreground line-clamp-2"
                  dangerouslySetInnerHTML={{ __html: faq.answer }}
                />
              </div>
              <div className="flex space-x-2 ml-4">
                <Button variant="ghost" size="sm" asChild>
                  <Link href={`/admin/faq/${faq.id}/edit`}>
                    <Edit className="h-4 w-4" />
                  </Link>
                </Button>
                <DeleteButton
                  onDelete={async () => {
                    if (confirm("Bu soruyu silmek istediğinize emin misiniz?")) {
                      const response = await fetch(`/api/admin/faq/${faq.id}`, {
                        method: "DELETE",
                      })
                      if (response.ok) {
                        window.location.reload()
                      }
                    }
                  }}
                />
              </div>
            </div>
            <div className="flex items-center gap-4 mt-4">
              <span
                className={`px-2 py-1 rounded text-xs ${
                  faq.isActive
                    ? "bg-green-100 text-green-800"
                    : "bg-gray-100 text-gray-800"
                }`}
              >
                {faq.isActive ? "Aktif" : "Pasif"}
              </span>
              <span className="text-xs text-muted-foreground">Sıra: {faq.order}</span>
            </div>
          </CardHeader>
        </Card>
      ))}
    </div>
  )
}

