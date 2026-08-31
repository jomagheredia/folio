import type { ReactNode } from "react"
import { BookmarkCard } from "@/components/BookmarkCard"
import type { BookmarkCardData } from "@/types/folio"

export function BookmarkGrid({
  bookmarks,
  renderFooter,
  selectedIds,
  onToggleSelect,
}: {
  bookmarks: BookmarkCardData[]
  renderFooter?: (bookmark: BookmarkCardData) => ReactNode
  selectedIds?: number[]
  onToggleSelect?: (bookmark: BookmarkCardData) => void
}) {
  const selected = selectedIds ?? []

  return (
    <ul className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {bookmarks.map((bookmark) => (
        <li key={bookmark.id}>
          <BookmarkCard
            bookmark={bookmark}
            footer={renderFooter?.(bookmark)}
            selected={selected.includes(bookmark.id)}
            onToggleSelect={onToggleSelect}
          />
        </li>
      ))}
    </ul>
  )
}
