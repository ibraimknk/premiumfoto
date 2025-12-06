import { prisma } from "@/lib/prisma"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Camera, Image as ImageIcon, FileText, MessageSquare } from "lucide-react"
import Link from "next/link"
import { Button } from "@/components/ui/button"

export default async function AdminDashboard() {
  const [
    servicesCount,
    mediaCount,
    blogPostsCount,
    messagesCount,
    recentMessages,
  ] = await Promise.all([
    prisma.service.count(),
    prisma.media.count(),
    prisma.blogPost.count(),
    prisma.contactMessage.count(),
    prisma.contactMessage.findMany({
      take: 5,
      orderBy: { createdAt: "desc" },
    }),
  ])

  const stats = [
    {
      title: "Hizmetler",
      count: servicesCount,
      icon: Camera,
      href: "/admin/services",
      color: "text-blue-600",
    },
    {
      title: "Medya",
      count: mediaCount,
      icon: ImageIcon,
      href: "/admin/gallery",
      color: "text-green-600",
    },
    {
      title: "Blog Yazıları",
      count: blogPostsCount,
      icon: FileText,
      href: "/admin/blog",
      color: "text-purple-600",
    },
    {
      title: "İletişim Mesajları",
      count: messagesCount,
      icon: MessageSquare,
      href: "/admin/messages",
      color: "text-orange-600",
    },
  ]

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">Hoş geldiniz! İşte genel bakış.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat) => {
          const Icon = stat.icon
          return (
            <Card key={stat.title} className="hover:shadow-lg transition-shadow">
              <CardHeader className="flex flex-row items-center justify-between">
                <CardTitle className="text-sm font-medium">{stat.title}</CardTitle>
                <Icon className={`h-5 w-5 ${stat.color}`} />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold mb-2">{stat.count}</div>
                <Button variant="ghost" size="sm" asChild>
                  <Link href={stat.href}>Görüntüle →</Link>
                </Button>
              </CardContent>
            </Card>
          )
        })}
      </div>

      {/* Recent Messages */}
      <Card>
        <CardHeader>
          <CardTitle>Son İletişim Mesajları</CardTitle>
        </CardHeader>
        <CardContent>
          {recentMessages.length > 0 ? (
            <div className="space-y-4">
              {recentMessages.map((message) => (
                <div
                  key={message.id}
                  className="p-4 border rounded-lg hover:bg-muted/50"
                >
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <p className="font-semibold">{message.name}</p>
                      <p className="text-sm text-muted-foreground">{message.email}</p>
                    </div>
                    <span className="text-xs text-muted-foreground">
                      {new Date(message.createdAt).toLocaleDateString("tr-TR")}
                    </span>
                  </div>
                  {message.subject && (
                    <p className="font-medium mb-1">{message.subject}</p>
                  )}
                  <p className="text-sm text-muted-foreground line-clamp-2">
                    {message.message}
                  </p>
                  {!message.isRead && (
                    <span className="inline-block mt-2 px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded">
                      Okunmadı
                    </span>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-muted-foreground">Henüz mesaj yok.</p>
          )}
          <div className="mt-4">
            <Button variant="outline" asChild>
              <Link href="/admin/messages">Tüm Mesajları Görüntüle →</Link>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

