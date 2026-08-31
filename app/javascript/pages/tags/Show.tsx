import { FormEvent } from "react"
import { Head, Link, router, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { BookmarkGrid } from "@/components/BookmarkGrid"
import { ConfirmDeleteDialog } from "@/components/ConfirmDeleteDialog"
import { EmptyState } from "@/components/EmptyState"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import type { BookmarkCardData, TagOption } from "@/types/folio"
import type { PageProps } from "@/types/inertia"

type Props = {
  tag: TagOption
  bookmarks: BookmarkCardData[]
}

export default function TagsShow({ tag, bookmarks }: Props) {
  const { props } = usePage<PageProps<Props>>()
  const errors = props.errors ?? {}
  const form = useForm({ name: tag.name })

  const rename = (event: FormEvent) => {
    event.preventDefault()
    form.patch(`/tags/${tag.id}`, { preserveScroll: true })
  }

  return (
    <>
      <Head title={tag.name}>
        <meta name="description" content={`Bookmarks tagged ${tag.name} in your Folio library.`} />
        <meta property="og:title" content={tag.name} />
        <meta
          property="og:description"
          content={`Bookmarks tagged ${tag.name} in your Folio library.`}
        />
      </Head>
      <AppShell wide>
        <PageHeader
          title={tag.name}
          description="Rename this tag everywhere it is used, or delete the label."
          actions={
            <>
              <Button asChild variant="secondary">
                <Link href={`/bookmarks?tag_id=${tag.id}`}>View in library</Link>
              </Button>
              <ConfirmDeleteDialog
                title="Delete this tag?"
                description="Bookmarks stay in your library. Only the label is removed."
                onConfirm={() => router.delete(`/tags/${tag.id}`)}
                trigger={
                  <Button type="button" variant="danger">
                    Delete tag
                  </Button>
                }
              />
            </>
          }
        />
        <FlashNotice />

        <form onSubmit={rename} className="mt-8 flex max-w-md flex-col gap-3 sm:flex-row sm:items-end">
          <div className="min-w-0 flex-1 space-y-2">
            <label htmlFor="name">Name</label>
            <Input
              id="name"
              value={form.data.name}
              aria-invalid={!!errors.name}
              onChange={(event) => form.setData("name", event.target.value)}
            />
            {errors.name && <p className="text-xs text-danger-display">{errors.name}</p>}
          </div>
          <Button type="submit" variant="secondary" disabled={form.processing}>
            Rename
          </Button>
        </form>

        {bookmarks.length === 0 ? (
          <EmptyState
            title="No bookmarks with this tag"
            description="Add this tag on a bookmark to see it here."
          />
        ) : (
          <BookmarkGrid bookmarks={bookmarks} />
        )}
      </AppShell>
    </>
  )
}
