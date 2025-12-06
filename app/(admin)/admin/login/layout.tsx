import { getServerSession } from "next-auth/next"
import { authOptions } from "@/lib/auth"
import { redirect } from "next/navigation"

export default async function LoginLayout({
  children,
}: {
  children: React.ReactNode
}) {
  // Eğer zaten giriş yapmışsa dashboard'a yönlendir
  const session = await getServerSession(authOptions)
  
  if (session) {
    redirect("/admin")
  }

  return <>{children}</>
}

