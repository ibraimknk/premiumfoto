"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Textarea } from "@/components/ui/textarea"

export default function InstagramImportPage() {
  const [profileUrl, setProfileUrl] = useState("https://www.instagram.com/dugunkaremcom/")
  const [mediaUrls, setMediaUrls] = useState("")
  const [category, setCategory] = useState("Instagram")
  const [isImporting, setIsImporting] = useState(false)
  const [isFetching, setIsFetching] = useState(false)
  const [status, setStatus] = useState<{
    type: "idle" | "success" | "error"
    message?: string
    details?: any
  }>({ type: "idle" })

  const handleFetchProfile = async () => {
    if (!profileUrl.trim()) {
      setStatus({
        type: "error",
        message: "Lütfen Instagram profil URL'sini girin",
      })
      return
    }

    setIsFetching(true)
    setStatus({ type: "idle" })

    try {
      const response = await fetch("/api/admin/instagram/fetch-profile", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          profileUrl,
        }),
      })

      const data = await response.json()

      if (response.ok) {
        // Şimdilik manuel indirme talimatı göster
        setStatus({
          type: "error",
          message: data.message || "Instagram'dan otomatik içerik çekmek için ek araçlar gerekir",
          details: data.instructions,
        })
      } else {
        setStatus({
          type: "error",
          message: data.error || "Profil bilgileri alınamadı",
        })
      }
    } catch (error: any) {
      setStatus({
        type: "error",
        message: "Bir hata oluştu: " + error.message,
      })
    } finally {
      setIsFetching(false)
    }
  }

  const handleImportFromUrls = async () => {
    if (!mediaUrls.trim()) {
      setStatus({
        type: "error",
        message: "Lütfen medya URL'lerini girin (her satıra bir URL)",
      })
      return
    }

    setIsImporting(true)
    setStatus({ type: "idle" })

    try {
      // URL'leri satır satır ayır
      const urls = mediaUrls
        .split("\n")
        .map((url) => url.trim())
        .filter((url) => url.length > 0 && url.startsWith("http"))

      if (urls.length === 0) {
        setStatus({
          type: "error",
          message: "Geçerli URL bulunamadı. Her satıra bir URL girin.",
        })
        setIsImporting(false)
        return
      }

      const response = await fetch("/api/admin/instagram/download", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          mediaUrls: urls,
          category,
        }),
      })

      const data = await response.json()

      if (response.ok && data.success) {
        setStatus({
          type: "success",
          message: data.message || `${data.imported} medya başarıyla eklendi`,
          details: data,
        })
        setMediaUrls("") // Formu temizle
      } else {
        setStatus({
          type: "error",
          message: data.error || "İçerik indirilirken bir hata oluştu",
        })
      }
    } catch (error: any) {
      setStatus({
        type: "error",
        message: "Bir hata oluştu: " + error.message,
      })
    } finally {
      setIsImporting(false)
    }
  }

  return (
    <div className="container mx-auto py-8">
      <Card>
        <CardHeader>
          <CardTitle>Instagram İçerik İçe Aktarma</CardTitle>
          <CardDescription>
            Instagram&apos;dan görsel ve videoları indirip galeriye ekleyin
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Yöntem 1: Profil URL'si ile Otomatik Çekme */}
          <div className="space-y-4 p-4 bg-blue-50 rounded-md">
            <div>
              <Label htmlFor="profileUrl">Instagram Profil URL&apos;si</Label>
              <Input
                id="profileUrl"
                value={profileUrl}
                onChange={(e) => setProfileUrl(e.target.value)}
                placeholder="https://www.instagram.com/dugunkaremcom/"
              />
              <p className="text-xs text-gray-500 mt-1">
                Instagram profil URL&apos;sini girin (örn: https://www.instagram.com/dugunkaremcom/)
              </p>
            </div>

            <Button
              onClick={handleFetchProfile}
              disabled={isFetching}
              className="w-full"
            >
              {isFetching ? "Profil Bilgileri Alınıyor..." : "Profil İçeriklerini Çek"}
            </Button>
          </div>

          {/* Yöntem 2: URL Listesi ile Toplu İçe Aktarma */}
          <div className="space-y-4 border-t pt-6">
            <h3 className="font-medium">Toplu İçe Aktarma (URL Listesi)</h3>
            <div>
              <Label htmlFor="mediaUrls">Medya URL&apos;leri (Her satıra bir URL)</Label>
              <Textarea
                id="mediaUrls"
                value={mediaUrls}
                onChange={(e) => setMediaUrls(e.target.value)}
                placeholder="https://example.com/image1.jpg&#10;https://example.com/video1.mp4&#10;https://example.com/image2.jpg"
                rows={8}
                className="font-mono text-sm"
              />
              <p className="text-xs text-gray-500 mt-1">
                Instagram görsel/video URL&apos;lerini buraya yapıştırın. Her satıra bir URL.
              </p>
            </div>

            <div>
              <Label htmlFor="category">Kategori</Label>
              <Input
                id="category"
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                placeholder="Instagram"
              />
            </div>

            <Button
              onClick={handleImportFromUrls}
              disabled={isImporting}
              className="w-full"
            >
              {isImporting ? "İçe Aktarılıyor..." : "URL&apos;lerden İçe Aktar"}
            </Button>
          </div>

          {/* Durum Mesajları */}
          {status.type === "success" && (
            <div className="p-4 bg-green-50 text-green-800 rounded-md">
              <p className="font-medium">✅ {status.message}</p>
              {status.details?.imported && (
                <p className="text-sm mt-1">
                  {status.details.imported} medya başarıyla galeriye eklendi.
                </p>
              )}
            </div>
          )}

          {status.type === "error" && (
            <div className="p-4 bg-red-50 text-red-800 rounded-md">
              <p className="font-medium">❌ {status.message}</p>
            </div>
          )}

          {/* Talimatlar */}
          <div className="p-4 bg-blue-50 rounded-md space-y-2">
            <p className="font-medium text-sm">📋 Nasıl Kullanılır:</p>
            <ol className="text-xs space-y-1 list-decimal list-inside">
              <li>Instagram&apos;dan görsel/video URL&apos;lerini kopyalayın</li>
              <li>URL&apos;leri yukarıdaki alana yapıştırın (her satıra bir URL)</li>
              <li>Kategori seçin (opsiyonel)</li>
              <li>&quot;URL&apos;lerden İçe Aktar&quot; butonuna tıklayın</li>
              <li>Medyalar otomatik olarak indirilip galeriye eklenecek</li>
            </ol>
            <p className="text-xs mt-2 text-gray-600">
              <strong>Not:</strong> Instagram URL&apos;lerini doğrudan kullanamazsınız. 
              Görsel/video dosyalarının doğrudan URL&apos;lerini kullanmanız gerekir. 
              Instagram içeriklerini indirmek için üçüncü parti araçlar kullanabilirsiniz.
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

