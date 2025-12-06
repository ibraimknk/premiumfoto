"use client"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"
import { Edit } from "lucide-react"
import { DeleteButton } from "@/components/features/DeleteButton"
import Image from "next/image"
import { formatDate } from "@/lib/utils"
import { shouldUnoptimizeImage } from "@/lib/image-utils"

interface BlogPost {
  id: string
  title: string
  excerpt: string | null
  category: string | null
  coverImage: string | null
  isPublished: boolean
  publishedAt: Date | null
}

interface BlogListProps {
  posts: BlogPost[]
}

export function BlogList({ posts }: BlogListProps) {
  return (
    <div className="space-y-4">
      {posts.map((post) => (
        <Card key={post.id}>
          <div className="flex items-start gap-4">
            {post.coverImage && (
              <div className="relative w-32 h-32 flex-shrink-0 rounded-lg overflow-hidden">
                <Image
                  src={post.coverImage}
                  alt={post.title}
                  fill
                  className="object-cover"
                  unoptimized={shouldUnoptimizeImage(post.coverImage)}
                />
              </div>
            )}
            <div className="flex-1 p-6">
              <div className="flex items-start justify-between mb-2">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    {post.isPublished ? (
                      <span className="w-2 h-2 bg-green-500 rounded-full" />
                    ) : (
                      <span className="w-2 h-2 bg-gray-400 rounded-full" />
                    )}
                    <CardTitle className="text-lg">{post.title}</CardTitle>
                  </div>
                  {post.category && (
                    <span className="text-xs font-semibold text-primary mb-2 inline-block">
                      {post.category}
                    </span>
                  )}
                  {post.excerpt && (
                    <p className="text-sm text-muted-foreground line-clamp-2">
                      {post.excerpt}
                    </p>
                  )}
                  {post.publishedAt && (
                    <p className="text-xs text-muted-foreground mt-2">
                      {formatDate(post.publishedAt)}
                    </p>
                  )}
                </div>
                <div className="flex space-x-2">
                  <Button variant="ghost" size="sm" asChild>
                    <Link href={`/admin/blog/${post.id}/edit`}>
                      <Edit className="h-4 w-4" />
                    </Link>
                  </Button>
                  <DeleteButton
                    onDelete={async () => {
                      if (confirm("Bu blog yazısını silmek istediğinize emin misiniz?")) {
                        const response = await fetch(`/api/admin/blog/${post.id}`, {
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
            </div>
          </div>
        </Card>
      ))}
    </div>
  )
}

