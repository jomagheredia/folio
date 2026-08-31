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

export default function BookmarksEdit({ bookmark, tags, collections }: Props) {
  return (
    <>
      <Head title={`Edit ${bookmark.title}`}>
        <meta name="description" content="Edit this saved find in your Folio library." />
        <meta property="og:title" content={`Edit ${bookmark.title}`} />
        <meta
          property="og:description"
          content="Edit this saved find in your Folio library."
        />
      </Head>
      <AppShell>
        <PageHeader title="Edit" description="Update the title, description, tags, and collections." />
        <FlashNotice />
        <BookmarkForm bookmark={bookmark} tags={tags} collections={collections} mode="edit" />
      </AppShell>
    </>
  )
}
