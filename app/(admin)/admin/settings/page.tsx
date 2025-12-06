import { prisma } from "@/lib/prisma"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { SettingsForm } from "@/components/features/SettingsForm"

export default async function AdminSettingsPage() {
  const settings = await prisma.siteSetting.findFirst()

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Site Ayarları</h1>
        <p className="text-muted-foreground">Genel site ayarlarını yönetin</p>
      </div>

      <SettingsForm initialData={settings} />
    </div>
  )
}

