import type { ReactNode } from "react"

export function EmptyState({
  title,
  description,
  action,
}: {
  title: string
  description: string
  action?: ReactNode
}) {
  return (
    <div className="callout mt-8">
      <p>
        <strong>{title}</strong>
      </p>
      <p className="mt-1">{description}</p>
      {action && <div className="mt-4">{action}</div>}
    </div>
  )
}
