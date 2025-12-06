import Link from "next/link"
import { Button } from "@/components/ui/button"

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-6xl font-bold mb-4">404</h1>
        <h2 className="text-2xl font-semibold mb-4">Sayfa Bulunamadı</h2>
        <p className="text-muted-foreground mb-8">
          Aradığınız sayfa mevcut değil veya taşınmış olabilir.
        </p>
        <Button asChild>
          <Link href="/">Ana Sayfaya Dön</Link>
        </Button>
      </div>
    </div>
  )
}

