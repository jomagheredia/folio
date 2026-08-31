import { usePage } from "@inertiajs/react"
import type { PageProps } from "@/types/inertia"

export function FlashNotice() {
  const { props } = usePage<PageProps>()
  if (!props.flash?.notice && !props.flash?.alert) return null

  return (
    <div className="mt-4 space-y-1">
      {props.flash.notice && (
        <p className="text-sm text-accent">{props.flash.notice}</p>
      )}
      {props.flash.alert && (
        <p className="text-sm text-danger-display">{props.flash.alert}</p>
      )}
    </div>
  )
}
