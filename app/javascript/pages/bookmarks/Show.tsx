import { Head, Link, router } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { ConfirmDeleteDialog } from "@/components/ConfirmDeleteDialog"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import type { BookmarkCardData } from "@/types/folio"

export default function BookmarksShow({ bookmark }: { bookmark: BookmarkCardData }) {
  return (
    <>
      <Head title={bookmark.title}>
        <meta
          name="description"
          content={bookmark.description || "A saved find in your Folio library."}
        />
        <meta property="og:title" content={bookmark.title} />
        <meta
          property="og:description"
          content={bookmark.description || "A saved find in your Folio library."}
        />
      </Head>
      <AppShell>
        <PageHeader
          title={bookmark.title}
          description={bookmark.kind === "visual" ? "Visual reference" : "Saved link"}
          actions={
            <>
              <Button asChild variant="secondary">
                <Link href={`/bookmarks/${bookmark.id}/edit`}>Edit</Link>
              </Button>
              <ConfirmDeleteDialog
                title="Delete this bookmark?"
                description="It will leave every collection it is in. This cannot be undone."
                onConfirm={() => router.delete(`/bookmarks/${bookmark.id}`)}
                trigger={
                  <Button type="button" variant="danger">
                    Delete
                  </Button>
                }
              />
            </>
          }
        />
        <FlashNotice />

        {bookmark.image_url && (
          <div className="mt-8 overflow-hidden rounded-md border border-hairline">
            <img src={bookmark.image_url} alt="" className="max-h-[32rem] w-full object-contain bg-surface" />
          </div>
        )}

        <div className="mt-8 space-y-4">
          {bookmark.url && (
            <p>
              <a href={bookmark.url} target="_blank" rel="noreferrer">
                {bookmark.url}
              </a>
            </p>
          )}
          {bookmark.description && <p>{bookmark.description}</p>}

          <div>
            <h2>Tags</h2>
            {bookmark.tags.length === 0 ? (
              <p className="mt-2">No tags yet. Add some on the edit page.</p>
            ) : (
              <div className="mt-2 flex flex-wrap gap-2">
                {bookmark.tags.map((tag) => (
                  <Link key={tag.id} href={`/tags/${tag.id}`} className="no-underline">
                    <Badge tone="accent">{tag.name}</Badge>
                  </Link>
                ))}
              </div>
            )}
          </div>

          <div>
            <h2>Collections</h2>
            {bookmark.collections.length === 0 ? (
              <p className="mt-2">Not in a collection yet.</p>
            ) : (
              <ul className="mt-2 space-y-1">
                {bookmark.collections.map((collection) => (
                  <li key={collection.id}>
                    <Link href={`/collections/${collection.id}`}>{collection.name}</Link>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </AppShell>
    </>
  )
}
