import { Head, Link } from "@inertiajs/react"
import { FolderOpen } from "lucide-react"
import { AppShell } from "@/components/AppShell"
import { EmptyState } from "@/components/EmptyState"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import type { CollectionOption } from "@/types/folio"

export default function CollectionsIndex({ collections }: { collections: CollectionOption[] }) {
  return (
    <>
      <Head title="Collections">
        <meta
          name="description"
          content="Named sets of bookmarks you curate in Folio."
        />
        <meta property="og:title" content="Collections" />
        <meta
          property="og:description"
          content="Named sets of bookmarks you curate in Folio."
        />
      </Head>
      <AppShell>
        <PageHeader
          title="Collections"
          description="Group finds into named sets. A bookmark can live in more than one collection."
          actions={
            <Button asChild>
              <Link href="/collections/new">New collection</Link>
            </Button>
          }
        />
        <FlashNotice />

        {collections.length === 0 ? (
          <EmptyState
            title="No collections yet"
            description="Create a named set like “Spring campaign refs” and add bookmarks to it."
            action={
              <Button asChild>
                <Link href="/collections/new">New collection</Link>
              </Button>
            }
          />
        ) : (
          <ul className="mt-6 divide-y divide-hairline overflow-hidden rounded-md border border-hairline bg-page">
            {collections.map((collection) => (
              <li key={collection.id}>
                <Link
                  href={`/collections/${collection.id}`}
                  className="flex items-center gap-3 px-4 py-3 no-underline hover:bg-surface"
                >
                  <FolderOpen className="h-4 w-4 text-ink-muted" />
                  <div className="min-w-0 flex-1">
                    <div className="truncate text-sm font-medium text-ink-display">
                      {collection.name}
                    </div>
                    <div className="truncate text-xs text-ink-muted">
                      {collection.bookmarks_count ?? 0}{" "}
                      {(collection.bookmarks_count ?? 0) === 1 ? "bookmark" : "bookmarks"}
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
