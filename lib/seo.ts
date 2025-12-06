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
}) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://fotougur.com"

  return {
    "@context": "https://schema.org",
    "@type": "BlogPosting",
    "headline": post.title,
    "description": post.excerpt || "",
    "datePublished": post.publishedAt?.toISOString() || new Date().toISOString(),
    "author": {
      "@type": "Organization",
      "name": "Foto Uğur - Uğur Fotoğrafçılık",
      "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
    },
    "publisher": {
      "@type": "Organization",
      "name": "Foto Uğur - Uğur Fotoğrafçılık",
      "alternateName": ["Foto Uğur", "Uğur Fotoğrafçılık"],
    },
    "url": `${baseUrl}/blog/${post.slug}`,
  }
}

