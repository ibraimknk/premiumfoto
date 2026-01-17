import { Metadata } from "next"
import { prisma } from "./prisma"

export async function generatePageMetadata(
  title?: string,
  description?: string,
  keywords?: string,
  image?: string
): Promise<Metadata> {
  const settings = await prisma.siteSetting.findFirst()
  const siteName = settings?.siteName || "Foto Uğur"
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com"

  return {
    title: title || settings?.defaultTitle || `${siteName} | Ataşehir Fotoğrafçı | Dış Mekan, Düğün, Ürün Çekimi | Uğur Fotoğrafçılık`,
    description: description || settings?.defaultDescription || "Foto Uğur ve Uğur Fotoğrafçılık olarak Ataşehir fotoğrafçı ve İstanbul fotoğrafçı hizmetleri. İstanbul düğün fotoğrafçısı olarak 1997'den beri profesyonel fotoğraf hizmetleri sunuyoruz. Dış mekan çekimi, ürün fotoğrafçılığı, düğün fotoğrafçılığı ve daha fazlası.",
    keywords: keywords || "foto uğur, uğur fotoğrafçılık, ataşehir fotoğrafçı, istanbul fotoğrafçı, istanbul düğün fotoğrafçısı, dış mekan çekimi, ürün fotoğrafçılığı, ataşehir düğün fotoğrafçısı",
    openGraph: {
      title: title || settings?.defaultTitle || siteName,
      description: description || settings?.defaultDescription || "",
      url: siteUrl,
      siteName,
      images: image ? [{ url: image }] : [],
      locale: "tr_TR",
      type: "website",
    },
    twitter: {
      card: "summary_large_image",
      title: title || settings?.defaultTitle || siteName,
      description: description || settings?.defaultDescription || "",
      images: image ? [image] : [],
    },
  }
}

export function generateLocalBusinessSchema() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com"

  return {
    "@context": "https://schema.org",
    "@type": "ProfessionalService",
    "name": "Foto Uğur - Uğur Fotoğrafçılık",
    "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
    "image": `${baseUrl}/logo.png`,
    "@id": baseUrl,
    "url": baseUrl,
    "telephone": "02164724628",
    "priceRange": "$$",
    "address": {
      "@type": "PostalAddress",
      "streetAddress": "Mustafa Kemal Mah. 3001 Cad. No: 49/A",
      "addressLocality": "Ataşehir",
      "addressRegion": "İstanbul",
      "postalCode": "34758",
      "addressCountry": "TR",
    },
    "geo": {
      "@type": "GeoCoordinates",
      "latitude": 40.9923,
      "longitude": 29.1244,
    },
    "openingHoursSpecification": {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
      ],
      "opens": "09:00",
      "closes": "19:00",
    },
    "sameAs": [
      "https://www.facebook.com/fotougur",
      "https://www.instagram.com/fotougur",
    ],
  }
}

export function generateServiceSchema(service: {
  title: string
  description: string
  slug: string
}) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com"

  return {
    "@context": "https://schema.org",
    "@type": "Service",
    "serviceType": service.title,
    "provider": {
      "@type": "LocalBusiness",
      "name": "Foto Uğur - Uğur Fotoğrafçılık",
      "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
    },
    "areaServed": {
      "@type": "City",
      "name": "Ataşehir, İstanbul",
    },
    "description": service.description,
    "url": `${baseUrl}/hizmetler/${service.slug}`,
  }
}

export function generateFAQSchema(faqs: Array<{ question: string; answer: string }>) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": faqs.map((faq) => ({
      "@type": "Question",
      "name": faq.question,
      "acceptedAnswer": {
        "@type": "Answer",
        "text": faq.answer.replace(/<[^>]*>/g, ""), // Remove HTML tags
      },
    })),
  }
}

export function generateArticleSchema(post: {
  title: string
  excerpt?: string | null
  publishedAt?: Date | null
  slug: string
  coverImage?: string | null
}) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"

  return {
    "@context": "https://schema.org",
    "@type": "BlogPosting",
    "headline": post.title,
    "description": post.excerpt || "",
    "datePublished": post.publishedAt?.toISOString() || new Date().toISOString(),
    "dateModified": post.publishedAt?.toISOString() || new Date().toISOString(),
    "author": {
      "@type": "Organization",
      "name": "Foto Uğur - Uğur Fotoğrafçılık",
      "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
      "url": baseUrl,
    },
    "publisher": {
      "@type": "Organization",
      "name": "Foto Uğur - Uğur Fotoğrafçılık",
      "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
      "logo": {
        "@type": "ImageObject",
        "url": `${baseUrl}/logo.png`,
      },
    },
    "image": post.coverImage ? `${baseUrl}${post.coverImage}` : `${baseUrl}/logo.png`,
    "url": `${baseUrl}/blog/${post.slug}`,
    "mainEntityOfPage": {
      "@type": "WebPage",
      "@id": `${baseUrl}/blog/${post.slug}`,
    },
  }
}

export function generateBlogListSchema() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"

  return {
    "@context": "https://schema.org",
    "@type": "Blog",
    "name": "Foto Uğur Blog",
    "description": "Fotoğrafçılık hakkında ipuçları, haberler ve daha fazlası",
    "url": `${baseUrl}/blog`,
    "publisher": {
      "@type": "Organization",
      "name": "Foto Uğur - Uğur Fotoğrafçılık",
      "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
      "logo": {
        "@type": "ImageObject",
        "url": `${baseUrl}/logo.png`,
      },
    },
  }
}

export function generateServiceListSchema(services: Array<{ title: string; slug: string; description: string }>) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"

  return {
    "@context": "https://schema.org",
    "@type": "ItemList",
    "itemListElement": services.map((service, index) => ({
      "@type": "ListItem",
      "position": index + 1,
      "item": {
        "@type": "Service",
        "name": service.title,
        "description": service.description,
        "url": `${baseUrl}/hizmetler/${service.slug}`,
        "provider": {
          "@type": "LocalBusiness",
          "name": "Foto Uğur - Uğur Fotoğrafçılık",
        },
      },
    })),
  }
}

export function generateContactPageSchema() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"

  return {
    "@context": "https://schema.org",
    "@type": "ContactPage",
    "name": "İletişim - Foto Uğur",
    "description": "Randevu almak veya sorularınız için bize ulaşın",
    "url": `${baseUrl}/iletisim`,
    "mainEntity": {
      "@type": "LocalBusiness",
      "name": "Foto Uğur - Uğur Fotoğrafçılık",
      "telephone": "02164724628",
      "email": "info@fotougur.com.tr",
      "address": {
        "@type": "PostalAddress",
        "streetAddress": "Mustafa Kemal Mah. 3001 Cad. No: 49/A",
        "addressLocality": "Ataşehir",
        "addressRegion": "İstanbul",
        "postalCode": "34758",
        "addressCountry": "TR",
      },
    },
  }
}

export function generateBreadcrumbSchema(items: Array<{ name: string; url: string }>) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"

  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": items.map((item, index) => ({
      "@type": "ListItem",
      "position": index + 1,
      "name": item.name,
      "item": item.url.startsWith("http") ? item.url : `${baseUrl}${item.url}`,
    })),
  }
}

export function generateOrganizationSchema() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"

  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Foto Uğur - Uğur Fotoğrafçılık",
    "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
    "url": baseUrl,
    "logo": `${baseUrl}/logo.png`,
    "image": `${baseUrl}/logo.png`,
    "description": "Ataşehir fotoğrafçı ve İstanbul fotoğrafçı hizmetleri. 1997'den beri profesyonel fotoğraf hizmetleri sunuyoruz.",
    "address": {
      "@type": "PostalAddress",
      "streetAddress": "Mustafa Kemal Mah. 3001 Cad. No: 49/A",
      "addressLocality": "Ataşehir",
      "addressRegion": "İstanbul",
      "postalCode": "34758",
      "addressCountry": "TR",
    },
    "contactPoint": {
      "@type": "ContactPoint",
      "telephone": "+90-216-472-46-28",
      "contactType": "customer service",
      "areaServed": "TR",
      "availableLanguage": ["Turkish"],
    },
    "sameAs": [
      "https://www.facebook.com/fotougur",
      "https://www.instagram.com/fotougur",
    ],
    "foundingDate": "1997",
  }
}

export function generateReviewSchema(reviews: Array<{
  name: string
  rating: number
  comment: string
  date?: Date | null
}>) {
  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Foto Uğur - Uğur Fotoğrafçılık",
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": reviews.length > 0
        ? (reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length).toFixed(1)
        : "5.0",
      "reviewCount": reviews.length,
      "bestRating": "5",
      "worstRating": "1",
    },
    "review": reviews.map((review) => ({
      "@type": "Review",
      "author": {
        "@type": "Person",
        "name": review.name,
      },
      "datePublished": review.date?.toISOString() || new Date().toISOString(),
      "reviewBody": review.comment,
      "reviewRating": {
        "@type": "Rating",
        "ratingValue": review.rating,
        "bestRating": "5",
        "worstRating": "1",
      },
    })),
  }
}

export function generateWebSiteSchema() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com.tr"

  return {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "Foto Uğur - Uğur Fotoğrafçılık",
    "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
    "url": baseUrl,
    "potentialAction": {
      "@type": "SearchAction",
      "target": {
        "@type": "EntryPoint",
        "urlTemplate": `${baseUrl}/blog?search={search_term_string}`,
      },
      "query-input": "required name=search_term_string",
    },
  }
}

