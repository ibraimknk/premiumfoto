import { withAuth } from "next-auth/middleware"
import { NextResponse } from "next/server"

export default withAuth(
  function middleware(req) {
    const token = req.nextauth.token
    const isLoginPage = req.nextUrl.pathname === "/admin/login"

    // Login sayfasına gidiyorsa ve zaten giriş yapmışsa, dashboard'a yönlendir
    if (isLoginPage && token) {
      return NextResponse.redirect(new URL("/admin", req.url))
    }

    // Pathname'i header'a ekle (layout'ta kullanmak için)
    const response = NextResponse.next()
    response.headers.set("x-pathname", req.nextUrl.pathname)
    
    return response
  },
  {
    callbacks: {
      authorized: ({ token, req }) => {
        const isLoginPage = req.nextUrl.pathname === "/admin/login"
        // Login sayfası herkese açık
        if (isLoginPage) return true
        // Diğer admin sayfaları için token gerekli
        return !!token
      },
    },
  }
)

export const config = {
  matcher: ["/admin/:path*"],
}

