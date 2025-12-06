import { prisma } from "@/lib/prisma"
import { Card, CardContent } from "@/components/ui/card"
import { MessagesList } from "@/components/features/MessagesList"

export default async function AdminMessagesPage() {
  const messages = await prisma.contactMessage.findMany({
    orderBy: { createdAt: "desc" },
  })

  const unreadCount = messages.filter((m) => !m.isRead).length

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">İletişim Mesajları</h1>
          <p className="text-muted-foreground">
            {unreadCount > 0 && (
              <span className="text-amber-600 font-semibold">
                {unreadCount} okunmamış mesaj
              </span>
            )}
            {unreadCount === 0 && "Tüm mesajlar"}
          </p>
        </div>
      </div>

      <MessagesList messages={messages} />

      {messages.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-muted-foreground">Henüz mesaj yok.</p>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

