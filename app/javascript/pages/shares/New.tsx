import { FormEvent, useState } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { BookmarkGrid } from "@/components/BookmarkGrid"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { defaultShareBody, defaultShareSubject } from "@/lib/shareDraft"
import type { BookmarkCardData, ShareCollection } from "@/types/folio"
import type { PageProps } from "@/types/inertia"

type Props = {
  collection: ShareCollection | null
  bookmarks: BookmarkCardData[]
  bookmark_id: number | null
  defaults: {
    subject: string
    body: string
  }
  cancel_path: string
}

export default function SharesNew({
  collection,
  bookmarks: initialBookmarks,
  bookmark_id = null,
  defaults,
  cancel_path,
}: Props) {
  const { props } = usePage<PageProps<Props>>()
  const errors = props.errors ?? {}
  const [items, setItems] = useState(initialBookmarks)
  const [generatedSubject, setGeneratedSubject] = useState(defaults.subject)
  const [generatedBody, setGeneratedBody] = useState(defaults.body)
  const singleBookmark = !collection && initialBookmarks.length === 1

  const form = useForm({
    recipients: "",
    subject: defaults.subject,
    note: "",
    body: defaults.body,
    collection_id: collection?.id?.toString() ?? "",
    bookmark_id: bookmark_id?.toString() ?? "",
    bookmark_ids: initialBookmarks.map((bookmark) => bookmark.id),
  })

  const dropItem = (bookmarkId: number) => {
    const nextItems = items.filter((bookmark) => bookmark.id !== bookmarkId)
    const nextSubject = defaultShareSubject(nextItems, collection)
    const nextBody = defaultShareBody(nextItems, collection)

    setItems(nextItems)
    form.setData((current) => ({
      ...current,
      bookmark_ids: nextItems.map((bookmark) => bookmark.id),
      subject: current.subject === generatedSubject ? nextSubject : current.subject,
      body: current.body === generatedBody ? nextBody : current.body,
    }))
    setGeneratedSubject(nextSubject)
    setGeneratedBody(nextBody)
  }

  const submit = (event: FormEvent) => {
    event.preventDefault()
    if (form.data.bookmark_ids.length === 0) return
    form.post("/shares", { preserveState: true })
  }

  const title = collection
    ? `Share ${collection.name}`
    : singleBookmark
      ? `Share ${initialBookmarks[0].title}`
      : "Share finds"
  const metaDescription = singleBookmark
    ? "Email this bookmark. Recipients do not need a Folio account."
    : "Email a collection or a selection of bookmarks. Recipients do not need a Folio account."

  return (
    <>
      <Head title={title}>
        <meta name="description" content={metaDescription} />
        <meta property="og:title" content={title} />
        <meta property="og:description" content={metaDescription} />
      </Head>
      <AppShell wide>
        <PageHeader
          title={title}
          description="Edit the note and body, then send. Recipients do not need a Folio account."
        />
        <FlashNotice />

        <form onSubmit={submit} className="mt-8 max-w-2xl space-y-4">
          <div className="space-y-2">
            <label htmlFor="recipients">Recipients</label>
            <Input
              id="recipients"
              name="recipients"
              required
              value={form.data.recipients}
              aria-invalid={!!errors.recipients}
              placeholder="friend@example.com, colleague@example.com"
              onChange={(event) => form.setData("recipients", event.target.value)}
            />
            {errors.recipients && (
              <p className="text-xs text-danger-display">{errors.recipients}</p>
            )}
          </div>

          <div className="space-y-2">
            <label htmlFor="subject">Subject</label>
            <Input
              id="subject"
              required
              value={form.data.subject}
              aria-invalid={!!errors.subject}
              onChange={(event) => form.setData("subject", event.target.value)}
            />
            {errors.subject && (
              <p className="text-xs text-danger-display">{errors.subject}</p>
            )}
          </div>

          <div className="space-y-2">
            <label htmlFor="note">Note</label>
            <textarea
              id="note"
              className="form-control form-control-textarea"
              value={form.data.note}
              onChange={(event) => form.setData("note", event.target.value)}
            />
          </div>

          <div className="space-y-2">
            <label htmlFor="body">Body</label>
            <textarea
              id="body"
              required
              rows={10}
              className="form-control form-control-textarea"
              value={form.data.body}
              aria-invalid={!!errors.body}
              onChange={(event) => form.setData("body", event.target.value)}
            />
            {errors.body && <p className="text-xs text-danger-display">{errors.body}</p>}
          </div>

          {errors.bookmarks && (
            <p className="text-sm text-danger-display">{errors.bookmarks}</p>
          )}

          <div className="flex items-center gap-3">
            <Button
              type="submit"
              disabled={form.processing || form.data.bookmark_ids.length === 0}
              data-testid="send-share"
            >
              Send
            </Button>
            <Button asChild variant="ghost">
              <Link href={cancel_path}>Cancel</Link>
            </Button>
          </div>
        </form>

        <section className="mt-10">
          <h2>In this email</h2>
          {items.length === 0 ? (
            <p className="mt-4">Add at least one bookmark before sending.</p>
          ) : (
            <BookmarkGrid
              bookmarks={items}
              renderFooter={
                items.length > 1
                  ? (bookmark) => (
                      <div className="px-4 pb-4">
                        <Button
                          type="button"
                          variant="ghost"
                          size="sm"
                          onClick={() => dropItem(bookmark.id)}
                        >
                          Remove from this email
                        </Button>
                      </div>
                    )
                  : undefined
              }
            />
          )}
        </section>
      </AppShell>
    </>
  )
}
