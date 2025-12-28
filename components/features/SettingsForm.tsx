"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { CarouselManager } from "@/components/features/CarouselManager"

interface SettingsFormProps {
  initialData: any
}

export function SettingsForm({ initialData }: SettingsFormProps) {
  const [carouselItems, setCarouselItems] = useState(() => {
    try {
      return initialData?.carouselItems
        ? JSON.parse(initialData.carouselItems)
        : [
            {
              id: "1",
              image: "",
              title: "",
              subtitle: "",
            },
          ]
    } catch {
      return [
        {
          id: "1",
          image: "",
          title: "",
          subtitle: "",
        },
      ]
    }
  })

  const [formData, setFormData] = useState({
    siteName: initialData?.siteName || "",
    defaultTitle: initialData?.defaultTitle || "",
    defaultDescription: initialData?.defaultDescription || "",
    phone1: initialData?.phone1 || "",
    phone2: initialData?.phone2 || "",
    whatsapp: initialData?.whatsapp || "",
    email: initialData?.email || "",
    address: initialData?.address || "",
    workingHours: initialData?.workingHours || "",
    primaryColor: initialData?.primaryColor || "#000000",
    secondaryColor: initialData?.secondaryColor || "#D4AF37",
    socialFacebook: initialData?.socialFacebook || "",
    socialInstagram: initialData?.socialInstagram || "",
  })

  const [isSaving, setIsSaving] = useState(false)
  const [saveStatus, setSaveStatus] = useState<"idle" | "success" | "error">("idle")
  const [isSubmittingSitemap, setIsSubmittingSitemap] = useState(false)
  const [sitemapStatus, setSitemapStatus] = useState<{
    status: "idle" | "success" | "error"
    message?: string
    results?: any
  }>({ status: "idle" })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSaving(true)
    setSaveStatus("idle")

    try {
      const response = await fetch("/api/admin/settings", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          ...formData,
          carouselItems: JSON.stringify(carouselItems),
        }),
      })

      if (response.ok) {
        setSaveStatus("success")
      } else {
        setSaveStatus("error")
      }
    } catch (error) {
      setSaveStatus("error")
    } finally {
      setIsSaving(false)
    }
  }

  const handleSubmitSitemap = async () => {
    setIsSubmittingSitemap(true)
    setSitemapStatus({ status: "idle" })

    try {
      const response = await fetch("/api/sitemap-submit", {
        method: "POST",
      })

      const data = await response.json()

      if (response.ok && data.success) {
        if (data.domains === 0) {
          setSitemapStatus({
            status: "error",
            message: "Domain bulunamadı! Lütfen .env dosyasına NEXT_PUBLIC_SITE_URLS ekleyin.",
            details: data.message,
          })
        } else {
          setSitemapStatus({
            status: "success",
            message: `${data.domains} domain için site haritası başarıyla arama motorlarına gönderildi!`,
            results: data.sitemaps,
          })
        }
      } else {
        setSitemapStatus({
          status: "error",
          message: data.message || data.error || "Site haritası gönderilirken bir hata oluştu.",
          details: data.message,
        })
      }
    } catch (error) {
      setSitemapStatus({
        status: "error",
        message: "Site haritası gönderilirken bir hata oluştu.",
      })
    } finally {
      setIsSubmittingSitemap(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <Tabs defaultValue="general" className="space-y-6">
        <TabsList>
          <TabsTrigger value="general">Genel</TabsTrigger>
          <TabsTrigger value="carousel">Ana Sayfa Carousel</TabsTrigger>
          <TabsTrigger value="contact">İletişim</TabsTrigger>
          <TabsTrigger value="social">Sosyal Medya</TabsTrigger>
          <TabsTrigger value="seo">SEO</TabsTrigger>
          <TabsTrigger value="theme">Tema</TabsTrigger>
        </TabsList>

        <TabsContent value="general">
          <Card>
            <CardHeader>
              <CardTitle>Genel Ayarlar</CardTitle>
              <CardDescription>Site adı ve varsayılan SEO ayarları</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="siteName">Site Adı</Label>
                <Input
                  id="siteName"
                  value={formData.siteName}
                  onChange={(e) => setFormData({ ...formData, siteName: e.target.value })}
                />
              </div>
              <div>
                <Label htmlFor="defaultTitle">Varsayılan Başlık</Label>
                <Input
                  id="defaultTitle"
                  value={formData.defaultTitle}
                  onChange={(e) => setFormData({ ...formData, defaultTitle: e.target.value })}
                />
              </div>
              <div>
                <Label htmlFor="defaultDescription">Varsayılan Açıklama</Label>
                <Textarea
                  id="defaultDescription"
                  value={formData.defaultDescription}
                  onChange={(e) =>
                    setFormData({ ...formData, defaultDescription: e.target.value })
                  }
                  rows={3}
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="carousel">
          <Card>
            <CardHeader>
              <CardTitle>Ana Sayfa Carousel</CardTitle>
              <CardDescription>Ana sayfadaki hero carousel görsellerini yönetin</CardDescription>
            </CardHeader>
            <CardContent>
              <CarouselManager items={carouselItems} onChange={setCarouselItems} />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="contact">
          <Card>
            <CardHeader>
              <CardTitle>İletişim Bilgileri</CardTitle>
              <CardDescription>Telefon, e-posta ve adres bilgileri</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="phone1">Sabit Telefon</Label>
                <Input
                  id="phone1"
                  value={formData.phone1}
                  onChange={(e) => setFormData({ ...formData, phone1: e.target.value })}
                  placeholder="0216 472 46 28"
                />
              </div>
              <div>
                <Label htmlFor="phone2">GSM</Label>
                <Input
                  id="phone2"
                  value={formData.phone2}
                  onChange={(e) => setFormData({ ...formData, phone2: e.target.value })}
                  placeholder="0530 228 56 03"
                />
              </div>
              <div>
                <Label htmlFor="whatsapp">WhatsApp Numarası</Label>
                <Input
                  id="whatsapp"
                  value={formData.whatsapp}
                  onChange={(e) => setFormData({ ...formData, whatsapp: e.target.value })}
                  placeholder="905302285603"
                />
              </div>
              <div>
                <Label htmlFor="email">E-posta</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                />
              </div>
              <div>
                <Label htmlFor="address">Adres</Label>
                <Textarea
                  id="address"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  rows={2}
                />
              </div>
              <div>
                <Label htmlFor="workingHours">Çalışma Saatleri</Label>
                <Input
                  id="workingHours"
                  value={formData.workingHours}
                  onChange={(e) => setFormData({ ...formData, workingHours: e.target.value })}
                  placeholder="Pazartesi - Cumartesi: 09:00 - 19:00"
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="social">
          <Card>
            <CardHeader>
              <CardTitle>Sosyal Medya</CardTitle>
              <CardDescription>Sosyal medya hesap linkleri</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="socialFacebook">Facebook</Label>
                <Input
                  id="socialFacebook"
                  value={formData.socialFacebook}
                  onChange={(e) => setFormData({ ...formData, socialFacebook: e.target.value })}
                  placeholder="https://facebook.com/..."
                />
              </div>
              <div>
                <Label htmlFor="socialInstagram">Instagram</Label>
                <Input
                  id="socialInstagram"
                  value={formData.socialInstagram}
                  onChange={(e) => setFormData({ ...formData, socialInstagram: e.target.value })}
                  placeholder="https://instagram.com/..."
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="seo">
          <Card>
            <CardHeader>
              <CardTitle>SEO ve Arama Motorları</CardTitle>
              <CardDescription>Site haritası ve arama motoru optimizasyonu</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label>Site Haritası (Sitemap)</Label>
                <div className="mt-2 space-y-3">
                  <div className="p-4 bg-blue-50 rounded-md">
                    <p className="text-sm text-gray-700 mb-2 font-medium">
                      ⚙️ Domain Yapılandırması
                    </p>
                    <p className="text-xs text-gray-600 mb-2">
                      Çoklu domain desteği için <code className="bg-gray-200 px-1 rounded">.env</code> dosyasına şunu ekleyin:
                    </p>
                    <code className="block text-xs bg-gray-100 p-2 rounded mb-2 break-all">
                      NEXT_PUBLIC_SITE_URLS=https://domain1.com,https://domain2.com,https://domain3.com
                    </code>
                    <p className="text-xs text-gray-500">
                      Veya tek domain için: <code className="bg-gray-200 px-1 rounded">NEXT_PUBLIC_SITE_URL=https://domain.com</code>
                    </p>
                  </div>
                  <div className="p-4 bg-gray-50 rounded-md">
                    <p className="text-sm text-gray-600 mb-2">
                      Site haritanız otomatik olarak oluşturulmaktadır:
                    </p>
                    <div className="space-y-2">
                      <div>
                        <a
                          href="/sitemap.xml"
                          target="_blank"
                          rel="noopener noreferrer"
                          className="text-blue-600 hover:underline text-sm font-mono break-all font-medium"
                        >
                          /sitemap.xml
                        </a>
                        <p className="text-xs text-gray-500 mt-1">
                          Ana sitemap index - tüm domain sitemap&apos;lerini listeler
                        </p>
                      </div>
                      <div className="mt-2 pt-2 border-t border-gray-200">
                        <p className="text-xs text-gray-600 mb-1 font-medium">
                          Her domain için ayrı sitemap:
                        </p>
                        <ul className="text-xs text-gray-500 space-y-1 list-disc list-inside">
                          <li>/sitemap-fotougur-com-tr.xml (fotougur.com.tr)</li>
                          <li>/sitemap-dugunkarem-com-tr.xml (dugunkarem.com.tr)</li>
                          <li>/sitemap-dugunkarem-com.xml (dugunkarem.com)</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                  <div className="p-4 bg-gray-50 rounded-md">
                    <p className="text-sm text-gray-600 mb-2">Robots.txt dosyanız:</p>
                    <a
                      href="/robots.txt"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-blue-600 hover:underline text-sm font-mono break-all"
                    >
                      /robots.txt
                    </a>
                  </div>
                  <div className="pt-4 border-t">
                    <p className="text-sm text-gray-700 mb-3">
                      Site haritanızı Google, Bing ve Yandex&apos;e göndermek için butona tıklayın:
                    </p>
                    <Button
                      type="button"
                      onClick={handleSubmitSitemap}
                      disabled={isSubmittingSitemap}
                      variant="outline"
                    >
                      {isSubmittingSitemap
                        ? "Gönderiliyor..."
                        : "Site Haritasını Arama Motorlarına Gönder"}
                    </Button>
                  </div>
                  {sitemapStatus.status === "success" && (
                    <div className="p-4 bg-green-50 text-green-800 rounded-md space-y-3">
                      <p className="font-medium">✅ {sitemapStatus.message}</p>
                      {sitemapStatus.results && Array.isArray(sitemapStatus.results) && (
                        <div className="space-y-3">
                          {sitemapStatus.results.map((sitemapData: any, index: number) => (
                            <div key={index} className="border-t pt-2 first:border-t-0 first:pt-0">
                              <p className="font-semibold text-sm mb-1">
                                {sitemapData.domain}
                              </p>
                              <div className="text-xs space-y-1 pl-2">
                                {sitemapData.results?.map((result: any, rIndex: number) => (
                                  <div key={rIndex} className="space-y-1">
                                    <div>
                                      {result.searchEngine}:{" "}
                                      {result.ok ? (
                                        <span className="text-green-600">Başarılı</span>
                                      ) : (
                                        <span className="text-yellow-600">
                                          {result.status || result.error}
                                        </span>
                                      )}
                                    </div>
                                    {result.note && (
                                      <div className="text-xs text-blue-700 bg-blue-50 p-2 rounded mt-1">
                                        ℹ️ {result.note}
                                      </div>
                                    )}
                                  </div>
                                ))}
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                      <div className="mt-3 p-3 bg-yellow-50 border border-yellow-200 rounded text-xs text-yellow-800">
                        <p className="font-semibold mb-1">⚠️ Önemli Not:</p>
                        <p>
                          Google ve Bing ping endpoint&apos;leri artık çalışmıyor. Sitemap&apos;leri{" "}
                          <a
                            href="https://search.google.com/search-console"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="underline font-semibold"
                          >
                            Google Search Console
                          </a>{" "}
                          ve{" "}
                          <a
                            href="https://www.bing.com/webmasters"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="underline font-semibold"
                          >
                            Bing Webmaster Tools
                          </a>{" "}
                          üzerinden manuel olarak göndermeniz gerekiyor.
                        </p>
                      </div>
                    </div>
                  )}
                  {sitemapStatus.status === "error" && (
                    <div className="p-4 bg-red-50 text-red-800 rounded-md space-y-2">
                      <p className="font-medium">❌ {sitemapStatus.message}</p>
                      {sitemapStatus.details && (
                        <div className="mt-2 p-3 bg-yellow-50 border border-yellow-200 rounded text-xs text-yellow-800">
                          <p className="font-semibold mb-1">💡 Çözüm:</p>
                          <p className="mb-2">{sitemapStatus.details}</p>
                          <code className="block bg-gray-100 p-2 rounded mt-2 break-all">
                            NEXT_PUBLIC_SITE_URLS=https://fotougur.com.tr,https://dugunkarem.com.tr,https://dugunkarem.com
                          </code>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
              <div className="pt-4 border-t">
                <p className="text-sm text-gray-600 mb-2">
                  <strong>Not:</strong> Site haritası otomatik olarak güncellenir. Yeni içerik
                  eklediğinizde veya güncellediğinizde, arama motorlarını bilgilendirmek için bu
                  butona tıklayın.
                </p>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="theme">
          <Card>
            <CardHeader>
              <CardTitle>Tema Ayarları</CardTitle>
              <CardDescription>Renk ve görsel ayarları</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="primaryColor">Ana Renk</Label>
                <div className="flex gap-2">
                  <Input
                    id="primaryColor"
                    type="color"
                    value={formData.primaryColor}
                    onChange={(e) => setFormData({ ...formData, primaryColor: e.target.value })}
                    className="w-20 h-10"
                  />
                  <Input
                    value={formData.primaryColor}
                    onChange={(e) => setFormData({ ...formData, primaryColor: e.target.value })}
                    placeholder="#000000"
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="secondaryColor">Vurgu Rengi</Label>
                <div className="flex gap-2">
                  <Input
                    id="secondaryColor"
                    type="color"
                    value={formData.secondaryColor}
                    onChange={(e) => setFormData({ ...formData, secondaryColor: e.target.value })}
                    className="w-20 h-10"
                  />
                  <Input
                    value={formData.secondaryColor}
                    onChange={(e) => setFormData({ ...formData, secondaryColor: e.target.value })}
                    placeholder="#D4AF37"
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {saveStatus === "success" && (
        <div className="mt-6 p-4 bg-green-50 text-green-800 rounded-md">
          Ayarlar başarıyla kaydedildi.
        </div>
      )}

      {saveStatus === "error" && (
        <div className="mt-6 p-4 bg-red-50 text-red-800 rounded-md">
          Bir hata oluştu. Lütfen tekrar deneyin.
        </div>
      )}

      <div className="mt-6">
        <Button type="submit" disabled={isSaving} size="lg">
          {isSaving ? "Kaydediliyor..." : "Ayarları Kaydet"}
        </Button>
      </div>
    </form>
  )
}

