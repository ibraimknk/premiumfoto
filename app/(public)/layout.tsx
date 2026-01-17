import Header from "@/components/layout/Header"
import Footer from "@/components/layout/Footer"
import { GoogleAnalytics } from "@/components/features/GoogleAnalytics"

export default function PublicLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const gaId = process.env.NEXT_PUBLIC_GA_ID

  return (
    <>
      {gaId && <GoogleAnalytics gaId={gaId} />}
      <div className="flex flex-col min-h-screen">
        <Header />
        <main className="flex-1">{children}</main>
        <Footer />
      </div>
    </>
  )
}

