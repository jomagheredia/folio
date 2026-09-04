import { FormEvent, useEffect, useRef, useState } from "react"
import { Head, Link, router, useForm } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { BookmarkGrid } from "@/components/BookmarkGrid"
import { ConfirmDeleteDialog } from "@/components/ConfirmDeleteDialog"
import { EmptyState } from "@/components/EmptyState"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Select } from "@/components/ui/select"
import { requestAi } from "@/lib/ai"
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
  const [summarizing, setSummarizing] = useState(false)
  const [summaryError, setSummaryError] = useState<string | null>(null)
  const [draftSummary, setDraftSummary] = useState<string | null>(null)
  const [keepingSummary, setKeepingSummary] = useState(false)
  const autoSummaryRequested = useRef(false)

  const addBookmark = (event: FormEvent) => {
    event.preventDefault()
    if (!addForm.data.bookmark_id) return
    addForm.post(`/collections/${collection.id}/add_bookmark`)
  }

  const removeBookmark = (bookmarkId: number) => {
    router.delete(`/collections/${collection.id}/remove_bookmark?bookmark_id=${bookmarkId}`)
  }

  const summarizeWithAi = async () => {
    setSummaryError(null)
    setSummarizing(true)
    try {
      const payload = await requestAi(`/collections/${collection.id}/ai/summary`)
      if (!payload.ok || !payload.summary) {
        setSummaryError(payload.error || "Couldn't summarize this collection.")
        return
      }
      setDraftSummary(payload.summary)
    } finally {
      setSummarizing(false)
    }
  }

  const keepSummary = () => {
    if (draftSummary == null) return
    setKeepingSummary(true)
    router.patch(
      `/collections/${collection.id}`,
      { ai_summary: draftSummary },
      {
        preserveScroll: true,
        onFinish: () => {
          setKeepingSummary(false)
          setDraftSummary(null)
        },
      },
    )
  }

  const discardSummary = () => {
    setDraftSummary(null)
    setSummaryError(null)
  }

  useEffect(() => {
    if (autoSummaryRequested.current) return
    if (collection.ai_summary?.trim()) return
    if (bookmarks.length === 0) return

    autoSummaryRequested.current = true
    void summarizeWithAi()
  }, [collection.id, collection.ai_summary, bookmarks.length])

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
                  <Link href={`/shares/new?collection_id=${collection.id}`} data-testid="share-collection">
                    Share
                  </Link>
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

        <section className="mt-8 max-w-xl">
          <h2>Overview</h2>
          <div className="mt-2">
            <Button
              type="button"
              variant="secondary"
              size="sm"
              onClick={summarizeWithAi}
              disabled={summarizing}
              data-testid="summarize-collection"
            >
              {summarizing ? "Summarizing…" : "Summarize"}
            </Button>
          </div>
          {draftSummary != null ? (
            <div className="mt-2 space-y-3">
              <textarea
                id="ai-summary-draft"
                className="form-control form-control-textarea"
                value={draftSummary}
                onChange={(event) => setDraftSummary(event.target.value)}
              />
              <div className="flex items-center gap-3">
                <Button
                  type="button"
                  size="sm"
                  onClick={keepSummary}
                  disabled={keepingSummary}
                  data-testid="keep-summary"
                >
                  Keep summary
                </Button>
                <Button type="button" variant="ghost" size="sm" onClick={discardSummary}>
                  Discard
                </Button>
              </div>
            </div>
          ) : collection.ai_summary ? (
            <p className="mt-2" data-testid="collection-ai-summary">
              {collection.ai_summary}
            </p>
          ) : (
            <p className="mt-2">No summary yet. Generate one to include it when you share this collection.</p>
          )}
          {summaryError && <p className="mt-2 text-xs text-danger-display">{summaryError}</p>}
        </section>

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
