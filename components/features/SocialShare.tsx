'use client'

import { Facebook, Twitter, Linkedin, MessageCircle, Link2 } from 'lucide-react'
import { Button } from '@/components/ui/button'

interface SocialShareProps {
  url: string
  title: string
  description?: string
}

export function SocialShare({ url, title, description }: SocialShareProps) {
  const encodedUrl = encodeURIComponent(url)
  const encodedTitle = encodeURIComponent(title)
  const encodedDescription = encodeURIComponent(description || '')

  const shareLinks = {
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodedUrl}`,
    twitter: `https://twitter.com/intent/tweet?url=${encodedUrl}&text=${encodedTitle}`,
    linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${encodedUrl}`,
    whatsapp: `https://wa.me/?text=${encodedTitle}%20${encodedUrl}`,
  }

  const copyToClipboard = () => {
    navigator.clipboard.writeText(url)
    // Toast notification eklenebilir
    alert('Link kopyalandı!')
  }

  return (
    <div className="flex flex-wrap gap-2 items-center">
      <span className="text-sm text-neutral-600 mr-2">Paylaş:</span>
      <Button
        size="sm"
        variant="outline"
        asChild
        className="h-9"
      >
        <a
          href={shareLinks.facebook}
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Facebook'ta paylaş"
        >
          <Facebook className="h-4 w-4 mr-2" />
          Facebook
        </a>
      </Button>
      <Button
        size="sm"
        variant="outline"
        asChild
        className="h-9"
      >
        <a
          href={shareLinks.twitter}
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Twitter'da paylaş"
        >
          <Twitter className="h-4 w-4 mr-2" />
          Twitter
        </a>
      </Button>
      <Button
        size="sm"
        variant="outline"
        asChild
        className="h-9"
      >
        <a
          href={shareLinks.whatsapp}
          target="_blank"
          rel="noopener noreferrer"
          aria-label="WhatsApp'ta paylaş"
        >
          <MessageCircle className="h-4 w-4 mr-2" />
          WhatsApp
        </a>
      </Button>
      <Button
        size="sm"
        variant="outline"
        onClick={copyToClipboard}
        className="h-9"
        aria-label="Linki kopyala"
      >
        <Link2 className="h-4 w-4 mr-2" />
        Kopyala
      </Button>
    </div>
  )
}

