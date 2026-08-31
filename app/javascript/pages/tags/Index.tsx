import { Head, Link } from "@inertiajs/react"
import { Tag as TagIcon } from "lucide-react"
import { AppShell } from "@/components/AppShell"
import { EmptyState } from "@/components/EmptyState"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import type { TagOption } from "@/types/folio"

export default function TagsIndex({ tags }: { tags: TagOption[] }) {
  return (
    <>
      <Head title="Tags">
        <meta name="description" content="Browse and manage the tags in your Folio library." />
        <meta property="og:title" content="Tags" />
        <meta
          property="og:description"
          content="Browse and manage the tags in your Folio library."
        />
      </Head>
      <AppShell>
        <PageHeader
          title="Tags"
          description="Tags are created when you type them on a bookmark."
        />
        <FlashNotice />

        {tags.length === 0 ? (
          <EmptyState
            title="No tags yet"
            description="Add a tag by typing a name while saving or editing a bookmark."
            action={
              <Link href="/bookmarks/new">Save a link</Link>
            }
          />
        ) : (
          <ul className="mt-6 divide-y divide-hairline overflow-hidden rounded-md border border-hairline bg-page">
            {tags.map((tag) => (
              <li key={tag.id}>
                <Link
                  href={`/tags/${tag.id}`}
                  className="flex items-center gap-3 px-4 py-3 no-underline hover:bg-surface"
                >
                  <TagIcon className="h-4 w-4 text-ink-muted" />
                  <div className="min-w-0 flex-1">
                    <div className="truncate text-sm font-medium text-ink-display">{tag.name}</div>
                    <div className="truncate text-xs text-ink-muted">
                      {tag.bookmarks_count ?? 0}{" "}
                      {(tag.bookmarks_count ?? 0) === 1 ? "bookmark" : "bookmarks"}
                    </div>
                  </div>
                </Link>
              </li>
            ))}
          </ul>
        )}
      </AppShell>
    </>
  )
}
