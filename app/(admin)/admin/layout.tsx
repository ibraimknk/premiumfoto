import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import AdminSidebar from "@/components/layout/AdminSidebar"
import { redirect } from "next/navigation"
import { headers } from "next/headers"

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode
}) {
  // Middleware'den gelen pathname'i al
  const headersList = await headers()
  const pathname = headersList.get("x-pathname") || ""
  
  // Login sayfası için layout'u bypass et
  if (pathname === "/admin/login") {
    return <>{children}</>
  }

  const session = await getServerSession(authOptions)
  
  if (!session) {
    redirect("/admin/login")
  }

  return (
    <div className="min-h-screen bg-muted">
      <div className="flex">
        <AdminSidebar />
        <main className="flex-1 p-8">{children}</main>
      </div>
    </div>
  )
}

