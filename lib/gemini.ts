import { GoogleGenerativeAI } from "@google/generative-ai"

const API_KEY = process.env.GEMINI_API_KEY || "AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"

if (!API_KEY) {
  throw new Error("GEMINI_API_KEY environment variable is not set")
}

const genAI = new GoogleGenerativeAI(API_KEY)

export interface BlogPostData {
  title: string
  slug: string
  excerpt: string
  content: string
  category: string
  seoTitle: string
  seoDescription: string
  seoKeywords: string
}

export async function generateBlogPost(topic?: string): Promise<BlogPostData> {
  // Gemini API model adlarını sırayla dene
  const modelsToTry = ["gemini-1.5-pro", "gemini-pro", "gemini-1.5-flash"]
  let model
  let lastError: Error | null = null

  for (const modelName of modelsToTry) {
    try {
      model = genAI.getGenerativeModel({ model: modelName })
      // Model başarıyla oluşturuldu, döngüden çık
      break
    } catch (error: any) {
      lastError = error
      console.log(`Model ${modelName} deneniyor...`)
      // Sonraki modeli dene
      continue
    }
  }

  if (!model) {
    throw new Error(
      `Hiçbir Gemini modeli çalışmıyor. Son hata: ${lastError?.message || "Bilinmeyen hata"}. Lütfen API key'inizin geçerli olduğundan ve gerekli izinlere sahip olduğundan emin olun.`
    )
  }

  const prompt = `Sen bir profesyonel SEO uzmanı ve içerik yazarısın. Fotoğrafçılık ve düğün fotoğrafçılığı konusunda uzmanlaşmış bir web sitesi için SEO uyumlu, kaliteli bir blog yazısı oluştur.

${topic ? `Konu: ${topic}` : "Konu: Fotoğrafçılık, düğün fotoğrafçılığı, ürün fotoğrafçılığı veya dış mekan çekimi ile ilgili güncel ve değerli bir konu seç."}

Lütfen aşağıdaki formatta JSON yanıt ver:

{
  "title": "SEO uyumlu, çekici başlık (50-60 karakter)",
  "slug": "seo-uyumlu-url-slug",
  "excerpt": "Kısa açıklama (150-160 karakter, SEO için optimize edilmiş)",
  "category": "Kategori adı (örn: Düğün Fotoğrafçılığı, Ürün Fotoğrafçılığı, Teknik İpuçları)",
  "seoTitle": "SEO başlığı (50-60 karakter, title'dan biraz farklı olabilir)",
  "seoDescription": "Meta açıklama (150-160 karakter, arama motorları için optimize edilmiş)",
  "seoKeywords": "anahtar,kelimeler,virgülle,ayrılmış (5-10 anahtar kelime)",
  "content": "HTML formatında zengin içerik. En az 800 kelime. H1, H2, H3 başlıkları kullan. Paragraflar <p> etiketi ile. Liste varsa <ul><li> kullan. SEO için optimize edilmiş, doğal dilde, değerli bilgiler içeren içerik. İçerik Türkçe olmalı."
}

Önemli kurallar:
1. İçerik tamamen Türkçe olmalı
2. SEO için optimize edilmiş olmalı (anahtar kelimeler doğal şekilde kullanılmalı)
3. İçerik en az 800 kelime olmalı
4. H1, H2, H3 başlıkları kullanılmalı
5. Değerli, bilgilendirici içerik olmalı
6. Slug Türkçe karakterler yerine İngilizce karakterler kullanmalı (ı→i, ş→s, ç→c, ğ→g, ü→u, ö→o)
7. JSON formatında yanıt ver, başka açıklama ekleme`

  try {
    const result = await model.generateContent(prompt)
    const response = await result.response
    const text = response.text()

    // JSON'u temizle (markdown code block varsa kaldır)
    let jsonText = text.trim()
    if (jsonText.startsWith("```json")) {
      jsonText = jsonText.replace(/^```json\s*/, "").replace(/\s*```$/, "")
    } else if (jsonText.startsWith("```")) {
      jsonText = jsonText.replace(/^```\s*/, "").replace(/\s*```$/, "")
    }

    const blogData = JSON.parse(jsonText) as BlogPostData

    // Slug'ı temizle ve formatla
    blogData.slug = blogData.slug
      .toLowerCase()
      .replace(/ş/g, "s")
      .replace(/ç/g, "c")
      .replace(/ğ/g, "g")
      .replace(/ı/g, "i")
      .replace(/ö/g, "o")
      .replace(/ü/g, "u")
      .replace(/[^a-z0-9-]/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-|-$/g, "")

    return blogData
  } catch (error: any) {
    console.error("Gemini API error:", error)
    throw new Error(`Blog oluşturma hatası: ${error.message}`)
  }
}

