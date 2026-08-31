import type { BookmarkCardData, ShareCollection } from "@/types/folio"

export function defaultShareSubject(
  bookmarks: BookmarkCardData[],
  collection?: ShareCollection | null
) {
  if (collection?.name) return collection.name
  if (bookmarks.length === 0) return "Finds from Folio"
  if (bookmarks.length === 1) return bookmarks[0].title
  return `${bookmarks[0].title} and ${bookmarks.length - 1} more`
}

export function defaultShareBody(
  bookmarks: BookmarkCardData[],
  collection?: ShareCollection | null
) {
  const parts: string[] = []
  const summary = collection?.ai_summary?.trim()
  if (summary) parts.push(summary)

  bookmarks.forEach((bookmark) => {
    const lines = [bookmark.title, bookmark.url || "(visual)"]
    const description = bookmark.description?.trim()
    if (description) lines.push(description)
    parts.push(lines.join("\n"))
  })

  return parts.join("\n\n")
}
