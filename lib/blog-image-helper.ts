/**
 * Blog görsel yardımcı fonksiyonları
 * Görsel yoksa varsayılan görseli ekler
 */

const DEFAULT_BLOG_IMAGE = "/uploads/atasehirfotografci.jpg"

/**
 * Blog için görsel URL'ini döndürür
 * Eğer görsel yoksa varsayılan görseli döndürür
 */
export function getBlogImage(coverImage: string | null | undefined): string {
  // Görsel varsa ve boş değilse kullan
  if (coverImage && coverImage.trim() !== "") {
    return coverImage
  }
  
  // Varsayılan görseli döndür
  return DEFAULT_BLOG_IMAGE
}

/**
 * Blog oluşturma/güncelleme için görsel kontrolü yapar
 * Eğer görsel yoksa varsayılan görseli ekler
 */
export function ensureBlogImage(coverImage: string | null | undefined): string | null {
  // Görsel varsa ve boş değilse kullan
  if (coverImage && coverImage.trim() !== "") {
    return coverImage
  }
  
  // Varsayılan görseli döndür
  return DEFAULT_BLOG_IMAGE
}

