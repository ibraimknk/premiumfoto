import { Metadata } from 'next'

interface HreflangTagsProps {
  currentPath: string
  languages?: Array<{ code: string; url: string }>
}

export function HreflangTags({ currentPath, languages }: HreflangTagsProps) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://fotougur.com.tr'
  
  // Default: Turkish only (x-default points to Turkish)
  const defaultLanguages = languages || [
    { code: 'tr', url: `${baseUrl}${currentPath}` },
  ]

  return (
    <>
      {/* x-default: Turkish */}
      <link rel="alternate" hrefLang="x-default" href={`${baseUrl}${currentPath}`} />
      
      {/* Language alternatives */}
      {defaultLanguages.map((lang) => (
        <link
          key={lang.code}
          rel="alternate"
          hrefLang={lang.code}
          href={lang.url}
        />
      ))}
    </>
  )
}

