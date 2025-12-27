import { GoogleGenerativeAI } from "@google/generative-ai"
import { generateImage } from "./gemini-image"

const API_KEY = process.env.GEMINI_API_KEY || "AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ"

if (!API_KEY) {
  throw new Error("GEMINI_API_KEY environment variable is not set")
}

// API key'i logla (sadece ilk 10 karakteri güvenlik için)
console.log(`Gemini API Key kullanılıyor: ${API_KEY.substring(0, 10)}...`)

// API key'i logla (sadece ilk 10 karakteri güvenlik için)
console.log(`Gemini API Key kullanılıyor: ${API_KEY.substring(0, 10)}...`)

const genAI = new GoogleGenerativeAI(API_KEY)

// Çalışan modeli bul (gerçek API çağrısı ile test et)
async function getAvailableModel(): Promise<string> {
  // Öncelik sırasına göre modelleri dene
  // Not: Güncel Gemini API modelleri (2025)
  const modelsToTry = [
    "gemini-2.5-flash",
    "gemini-2.5-pro",
    "gemini-2.0-flash",
    "gemini-flash-latest",
    "gemini-pro-latest",
    "models/gemini-2.5-flash",
    "models/gemini-2.5-pro",
    "models/gemini-2.0-flash",
    "models/gemini-flash-latest",
    "models/gemini-pro-latest",
    // Eski modeller (fallback)
    "gemini-1.5-flash",
    "gemini-1.5-pro",
    "gemini-pro"
  ]
  
  // Her modeli gerçek API çağrısı ile test et
  for (const modelName of modelsToTry) {
    try {
      const testModel = genAI.getGenerativeModel({ model: modelName })
      // Gerçek bir test çağrısı yap (çok kısa bir prompt)
      const testResult = await testModel.generateContent("Hi")
      const testResponse = await testResult.response
      const testText = testResponse.text()
      
      // Model çalışıyor, kullanılabilir
      console.log(`✅ Model ${modelName} çalışıyor!`)
      return modelName
    } catch (error: any) {
      const errorMsg = error.message || String(error)
      console.log(`❌ Model ${modelName} çalışmıyor: ${errorMsg.substring(0, 150)}`)
      
      // Eğer 404 hatası alıyorsak, model adı yanlış olabilir
      if (errorMsg.includes("404") || errorMsg.includes("not found")) {
        continue
      }
      
      // Eğer API key hatası varsa, durdur
      if (errorMsg.includes("API key") || errorMsg.includes("authentication") || errorMsg.includes("401") || errorMsg.includes("403")) {
        throw new Error(
          `API Key hatası: ${errorMsg}. Lütfen API key'inizin geçerli olduğundan ve Gemini API'ye erişim izniniz olduğundan emin olun.`
        )
      }
      
      continue
    }
  }
  
  // Hiçbiri çalışmazsa hata fırlat
  throw new Error(
    "Hiçbir Gemini modeli çalışmıyor. Lütfen:\n" +
    "1. API key'inizin geçerli olduğundan emin olun\n" +
    "2. Google AI Studio'da (https://aistudio.google.com/) API key'inizi kontrol edin\n" +
    "3. API key'inizin Gemini API'ye erişim izni olduğundan emin olun\n" +
    "4. Gerekirse yeni bir API key oluşturun"
  )
}

export interface BlogPostData {
  title: string
  slug: string
  excerpt: string
  content: string
  category: string
  seoTitle: string
  seoDescription: string
  seoKeywords: string
  coverImage?: string
  coverImageAlt?: string
}

export async function generateBlogPost(topic?: string): Promise<BlogPostData> {
  // Mevcut modelleri kontrol et ve çalışan bir model seç
  const modelName = await getAvailableModel()
  const model = genAI.getGenerativeModel({ model: modelName })

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
  "content": "HTML formatında zengin içerik. En az 800 kelime. H1, H2, H3 başlıkları kullan. Paragraflar <p> etiketi ile. Liste varsa <ul><li> kullan. SEO için optimize edilmiş, doğal dilde, değerli bilgiler içeren içerik. İçerik Türkçe olmalı. Görseller için <img> etiketi kullan ve alt attribute'u ekle (SEO için önemli).",
  "coverImageAlt": "Blog görseli için SEO uyumlu alt text (80-100 karakter, anahtar kelimeler içermeli)"
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

    // JSON'daki geçersiz kontrol karakterlerini temizle
    jsonText = jsonText
      // Geçersiz kontrol karakterlerini kaldır (0x00-0x1F arası, \n, \r, \t hariç)
      .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F]/g, "")
      // Çoklu boşlukları tek boşluğa çevir
      .replace(/\s+/g, " ")
      // JSON string içindeki geçersiz karakterleri escape et
      .replace(/\\(?!["\\/bfnrt])/g, "\\\\")

    try {
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

      // İçerikteki görseller için alt text ekle (yoksa)
      if (blogData.content && !blogData.content.includes('alt=')) {
        // İçerikteki <img> etiketlerine alt text ekle
        blogData.content = blogData.content.replace(
          /<img([^>]*?)>/gi,
          (match, attrs) => {
            if (!attrs.includes('alt=')) {
              return `<img${attrs} alt="${blogData.coverImageAlt || blogData.title}">`
            }
            return match
          }
        )
      }

      // Cover image oluşturma devre dışı (kırık link sorunu nedeniyle)
      // Görsel oluşturma özelliği şimdilik kapalı
      // İleride gerçek görsel oluşturma API'si entegre edilebilir
      blogData.coverImage = null

      return blogData
    } catch (parseError: any) {
      // JSON parse hatası durumunda, daha agresif temizleme dene
      console.error("JSON parse hatası, daha agresif temizleme deneniyor...", parseError.message)
      
      // JSON'u daha agresif temizle
      jsonText = jsonText
        .replace(/[\x00-\x1F\x7F-\x9F]/g, "") // Tüm kontrol karakterlerini kaldır
        .replace(/\n/g, " ") // Yeni satırları boşluğa çevir
        .replace(/\r/g, "") // Carriage return'leri kaldır
        .replace(/\t/g, " ") // Tab'leri boşluğa çevir
        .replace(/\\"/g, '"') // Escaped tırnakları düzelt
        .replace(/\\'/g, "'") // Escaped apostrophe'ları düzelt
      
      try {
        const blogData = JSON.parse(jsonText) as BlogPostData
        return blogData
      } catch (secondParseError: any) {
        console.error("JSON parse hatası (ikinci deneme):", secondParseError.message)
        console.error("JSON metni (ilk 500 karakter):", jsonText.substring(0, 500))
        throw new Error(
          `JSON parse hatası: ${parseError.message}. ` +
          `Lütfen Gemini API'nin döndürdüğü JSON formatını kontrol edin. ` +
          `JSON metni: ${jsonText.substring(0, 200)}...`
        )
      }
    }
  } catch (error: any) {
    console.error("Gemini API error:", error)
    throw new Error(`Blog oluşturma hatası: ${error.message}`)
  }
}

