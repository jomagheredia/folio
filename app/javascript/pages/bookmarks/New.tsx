import { Head } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { BookmarkForm, type BookmarkFormValues } from "@/components/BookmarkForm"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import type { CollectionOption, TagOption } from "@/types/folio"

type Props = {
  bookmark: BookmarkFormValues
  tags: TagOption[]
  collections: CollectionOption[]
}

export default function BookmarksNew({ bookmark, tags, collections }: Props) {
  return (
    <>
      <Head title="Save to library">
        <meta
          name="description"
          content="Paste a URL or add a visual reference to your Folio library."
        />
        <meta property="og:title" content="Save to library" />
        <meta
          property="og:description"
          content="Paste a URL or add a visual reference to your Folio library."
        />
      </Head>
      <AppShell>
        <PageHeader
          title={bookmark.kind === "visual" ? "Add a visual" : "Save a link"}
          description="Folio fills in a title, snippet, and preview when the page provides them."
        />
        <FlashNotice />
        <BookmarkForm bookmark={bookmark} tags={tags} collections={collections} mode="new" />
      </AppShell>
    </>
  )
}
