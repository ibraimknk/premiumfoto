/**
 * Image URL'nin unoptimized olması gerekip gerekmediğini kontrol eder
 */
export function shouldUnoptimizeImage(src: string | null | undefined): boolean {
  if (!src) return false
  // Local uploads klasöründeki dosyalar için unoptimized kullan
  if (src.startsWith("/uploads/")) return true
  // Blob URL'leri için unoptimized kullan
  if (src.startsWith("blob:")) return true
  // Data URL'leri için unoptimized kullan
  if (src.startsWith("data:")) return true
  return false
}

