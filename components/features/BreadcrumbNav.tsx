'use client'

import Link from 'next/link'
import { ChevronRight, Home } from 'lucide-react'

interface BreadcrumbItem {
  name: string
  url: string
}

interface BreadcrumbNavProps {
  items: BreadcrumbItem[]
}

export function BreadcrumbNav({ items }: BreadcrumbNavProps) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://fotougur.com.tr'
  
  return (
    <nav aria-label="Breadcrumb" className="mb-6">
      <ol className="flex items-center space-x-2 text-sm text-neutral-600">
        <li>
          <Link
            href="/"
            className="hover:text-amber-600 transition-colors flex items-center"
            aria-label="Ana Sayfa"
          >
            <Home className="h-4 w-4" />
          </Link>
        </li>
        {items.map((item, index) => {
          const isLast = index === items.length - 1
          const fullUrl = item.url.startsWith('http') ? item.url : `${baseUrl}${item.url}`
          
          return (
            <li key={item.url} className="flex items-center">
              <ChevronRight className="h-4 w-4 mx-2 text-neutral-400" />
              {isLast ? (
                <span className="text-neutral-900 font-medium" aria-current="page">
                  {item.name}
                </span>
              ) : (
                <Link
                  href={item.url}
                  className="hover:text-amber-600 transition-colors"
                >
                  {item.name}
                </Link>
              )}
            </li>
          )
        })}
      </ol>
    </nav>
  )
}

