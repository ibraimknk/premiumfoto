import type { Metadata } from "next"
import { Inter, Poppins } from "next/font/google"
import "./globals.css"

const inter = Inter({ 
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
})

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-poppins",
  display: "swap",
})

export const metadata: Metadata = {
  title: "Foto Uğur - Ataşehir Fotoğraf Stüdyosu",
  description: "Ataşehir'de premium fotoğraf stüdyosu. Dış çekim, düğün, ürün fotoğrafçılığı ve profesyonel fotoğraf hizmetleri.",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="tr" className={`${inter.variable} ${poppins.variable}`}>
      <body className="font-sans antialiased">{children}</body>
    </html>
  )
}

