import { NextResponse } from "next/server"
import { prisma } from "@/lib/prisma"
import { z } from "zod"

const contactSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  phone: z.string().optional(),
  subject: z.string().optional(),
  message: z.string().min(1),
})

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const validatedData = contactSchema.parse(body)

    const message = await prisma.contactMessage.create({
      data: validatedData,
    })

    return NextResponse.json(
      { success: true, message: "Mesajınız başarıyla gönderildi." },
      { status: 201 }
    )
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { success: false, error: "Geçersiz form verisi" },
        { status: 400 }
      )
    }

    console.error("Contact form error:", error)
    return NextResponse.json(
      { success: false, error: "Bir hata oluştu" },
      { status: 500 }
    )
  }
}

