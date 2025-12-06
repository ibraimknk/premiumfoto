"use client"

import { Button } from "@/components/ui/button"
import { Trash2 } from "lucide-react"

interface DeleteButtonProps {
  onDelete: () => void
}

export function DeleteButton({ onDelete }: DeleteButtonProps) {
  return (
    <Button variant="ghost" size="sm" onClick={onDelete}>
      <Trash2 className="h-4 w-4" />
    </Button>
  )
}

