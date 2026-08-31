import { FormEvent } from "react"
import { Head, Link, router, useForm } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { BookmarkGrid } from "@/components/BookmarkGrid"
import { ConfirmDeleteDialog } from "@/components/ConfirmDeleteDialog"
import { EmptyState } from "@/components/EmptyState"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Select } from "@/components/ui/select"
import type { BookmarkCardData, CollectionOption, ShareHistoryItem } from "@/types/folio"

type AvailableBookmark = {
  id: number
  title: string
  kind: string
}

type Props = {
  collection: CollectionOption
  bookmarks: BookmarkCardData[]
  available_bookmarks: AvailableBookmark[]
  shares: ShareHistoryItem[]
}

export default function CollectionsShow({
  collection,
  bookmarks,
  available_bookmarks,
  shares = [],
}: Props) {
  const addForm = useForm({ bookmark_id: available_bookmarks[0]?.id?.toString() ?? "" })

  const addBookmark = (event: FormEvent) => {
    event.preventDefault()
    if (!addForm.data.bookmark_id) return
    addForm.post(`/collections/${collection.id}/add_bookmark`)
  }

  const removeBookmark = (bookmarkId: number) => {
    router.delete(`/collections/${collection.id}/remove_bookmark?bookmark_id=${bookmarkId}`)
  }

  return (
    <>
      <Head title={collection.name}>
        <meta
          name="description"
          content={collection.notes || `Collection of bookmarks: ${collection.name}.`}
        />
        <meta property="og:title" content={collection.name} />
        <meta
          property="og:description"
          content={collection.notes || `Collection of bookmarks: ${collection.name}.`}
        />
      </Head>
      <AppShell wide>
        <PageHeader
          title={collection.name}
          description={collection.notes || "A named set of finds from your library."}
          actions={
            <>
              {bookmarks.length > 0 && (
                <Button asChild>
                  <Link href={`/shares/new?collection_id=${collection.id}`}>Share</Link>
                </Button>
              )}
              <Button asChild variant="secondary">
                <Link href={`/bookmarks?collection_id=${collection.id}`}>View in library</Link>
              </Button>
              <Button asChild variant="secondary">
                <Link href={`/collections/${collection.id}/edit`}>Edit</Link>
              </Button>
              <ConfirmDeleteDialog
                title="Delete this collection?"
                description="Bookmarks stay in your library. Only the collection is removed."
                onConfirm={() => router.delete(`/collections/${collection.id}`)}
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

        {available_bookmarks.length > 0 && (
          <form onSubmit={addBookmark} className="mt-8 flex max-w-xl flex-col gap-3 sm:flex-row sm:items-end">
            <div className="min-w-0 flex-1 space-y-2">
              <label htmlFor="bookmark_id">Add a bookmark</label>
              <Select
                id="bookmark_id"
                value={addForm.data.bookmark_id}
                onChange={(event) => addForm.setData("bookmark_id", event.target.value)}
              >
                {available_bookmarks.map((bookmark) => (
                  <option key={bookmark.id} value={bookmark.id}>
                    {bookmark.title}
                  </option>
                ))}
              </Select>
            </div>
            <Button type="submit" variant="secondary" disabled={addForm.processing}>
              Add
            </Button>
          </form>
        )}

        {bookmarks.length === 0 ? (
          <EmptyState
            title="Nothing in this collection yet"
            description="Add a bookmark from this page, or assign collections while editing a bookmark."
            action={
              <Button asChild>
                <Link href={`/bookmarks/new?collection_id=${collection.id}`}>Save a link here</Link>
              </Button>
            }
          />
        ) : (
          <BookmarkGrid
            bookmarks={bookmarks}
            renderFooter={(bookmark) => (
              <div className="px-4 pb-4">
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  onClick={() => removeBookmark(bookmark.id)}
                >
                  Remove from collection
                </Button>
              </div>
            )}
          />
        )}

        {shares.length > 0 && (
          <section className="mt-10 max-w-xl">
            <h2>Sent</h2>
            <ul className="mt-4 space-y-3">
              {shares.map((share) => (
                <li key={share.id} className="border-b border-hairline pb-3">
                  <p>Sent to {share.recipients.join(", ")}</p>
                  <p>
                    {share.sent_at_label}
                    {share.subject ? ` · ${share.subject}` : ""}
                  </p>
                </li>
              ))}
            </ul>
          </section>
        )}
      </AppShell>
    </>
  )
}
