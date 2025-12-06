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

  return (
    <form onSubmit={handleSubmit}>
      <Tabs defaultValue="general" className="space-y-6">
        <TabsList>
          <TabsTrigger value="general">Genel</TabsTrigger>
          <TabsTrigger value="carousel">Ana Sayfa Carousel</TabsTrigger>
          <TabsTrigger value="contact">İletişim</TabsTrigger>
          <TabsTrigger value="social">Sosyal Medya</TabsTrigger>
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

