"use client"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Mail, Phone, MessageSquare, Check, X } from "lucide-react"
import { formatDate } from "@/lib/utils"

interface Message {
  id: string
  name: string
  email: string
  phone: string | null
  subject: string | null
  message: string
  isRead: boolean
  createdAt: Date
}

interface MessagesListProps {
  messages: Message[]
}

export function MessagesList({ messages }: MessagesListProps) {
  return (
    <div className="space-y-4">
      {messages.map((message) => (
        <Card
          key={message.id}
          className={!message.isRead ? "border-amber-500 bg-amber-50/50" : ""}
        >
          <CardHeader>
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  {!message.isRead && (
                    <span className="w-2 h-2 bg-amber-500 rounded-full" />
                  )}
                  <CardTitle className="text-lg">{message.name}</CardTitle>
                </div>
                <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
                  <div className="flex items-center gap-1">
                    <Mail className="h-4 w-4" />
                    {message.email}
                  </div>
                  {message.phone && (
                    <div className="flex items-center gap-1">
                      <Phone className="h-4 w-4" />
                      {message.phone}
                    </div>
                  )}
                  <div className="flex items-center gap-1">
                    <MessageSquare className="h-4 w-4" />
                    {formatDate(message.createdAt)}
                  </div>
                </div>
                {message.subject && (
                  <p className="font-semibold mt-2">{message.subject}</p>
                )}
              </div>
              <div className="flex space-x-2">
                {!message.isRead && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={async () => {
                      const response = await fetch(`/api/admin/messages/${message.id}/read`, {
                        method: "PUT",
                      })
                      if (response.ok) {
                        window.location.reload()
                      }
                    }}
                    title="Okundu olarak işaretle"
                  >
                    <Check className="h-4 w-4" />
                  </Button>
                )}
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={async () => {
                    if (confirm("Bu mesajı silmek istediğinize emin misiniz?")) {
                      const response = await fetch(`/api/admin/messages/${message.id}`, {
                        method: "DELETE",
                      })
                      if (response.ok) {
                        window.location.reload()
                      }
                    }
                  }}
                  title="Sil"
                >
                  <X className="h-4 w-4" />
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground whitespace-pre-wrap">
              {message.message}
            </p>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}

