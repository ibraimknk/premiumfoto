'use client'

import Script from 'next/script'

interface GoogleAnalyticsProps {
  gaId?: string
}

export function GoogleAnalytics({ gaId }: GoogleAnalyticsProps) {
  // Default GA ID - kullanıcının verdiği ID
  const defaultGaId = 'G-PR5RQ39RRG'
  const finalGaId = gaId || process.env.NEXT_PUBLIC_GA_ID || defaultGaId

  if (!finalGaId) {
    return null
  }

  return (
    <>
      <Script
        strategy="afterInteractive"
        src={`https://www.googletagmanager.com/gtag/js?id=${finalGaId}`}
      />
      <Script
        id="google-analytics"
        strategy="afterInteractive"
        dangerouslySetInnerHTML={{
          __html: `
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', '${finalGaId}');
          `,
        }}
      />
    </>
  )
}

