import { Link } from "@inertiajs/react"
import { Image as ImageIcon, Link as LinkIcon } from "lucide-react"
import type { ReactNode } from "react"
import { Badge } from "@/components/ui/badge"
import type { BookmarkCardData } from "@/types/folio"

export function BookmarkCard({
  bookmark,
  footer,
}: {
  bookmark: BookmarkCardData
  footer?: ReactNode
}) {
  return (
    <article className="overflow-hidden rounded-md border border-hairline bg-page">
      <Link href={`/bookmarks/${bookmark.id}`} className="block no-underline">
        <div className="relative aspect-[16/10] bg-surface">
          {bookmark.image_url ? (
            <img
              src={bookmark.image_url}
              alt=""
              className="h-full w-full object-cover"
            />
          ) : (
            <div className="flex h-full items-center justify-center text-ink-muted">
              {bookmark.kind === "visual" ? (
                <ImageIcon className="h-8 w-8" />
              ) : (
                <LinkIcon className="h-8 w-8" />
              )}
            </div>
          )}
        </div>
        <div className="space-y-2 p-4">
          <div className="flex items-start justify-between gap-2">
            <div className="min-w-0 truncate text-sm font-medium text-ink-display">
              {bookmark.title}
            </div>
            <Badge tone={bookmark.kind === "visual" ? "signal" : "muted"}>
              {bookmark.kind === "visual" ? "Visual" : "Link"}
            </Badge>
          </div>
          {bookmark.url && (
            <div className="truncate text-xs text-ink-muted">{bookmark.url}</div>
          )}
        </div>
      </Link>
      {bookmark.tags.length > 0 && (
        <div className="flex flex-wrap gap-1.5 px-4 pb-3">
          {bookmark.tags.map((tag) => (
            <Link key={tag.id} href={`/tags/${tag.id}`} className="no-underline">
              <Badge tone="accent">{tag.name}</Badge>
            </Link>
          ))}
        </div>
      )}
      {footer}
    </article>
  )
}
