import { FormEvent } from "react"
import { Head, Link, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { BookmarkGrid } from "@/components/BookmarkGrid"
import { EmptyState } from "@/components/EmptyState"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select } from "@/components/ui/select"
import type { BookmarkCardData, CollectionOption, LibraryFilters, TagOption } from "@/types/folio"
import type { PageProps } from "@/types/inertia"

type Props = {
  bookmarks: BookmarkCardData[]
  tags: TagOption[]
  collections: CollectionOption[]
  filters: LibraryFilters
}

export default function BookmarksIndex({ bookmarks, tags, collections, filters }: Props) {
  const { props } = usePage<PageProps<Props>>()
  const errors = props.errors ?? {}

  const applyFilters = (next: Partial<LibraryFilters>) => {
    const kind = next.kind ?? filters.kind
    const tagId = next.tag_id === undefined ? filters.tag_id : next.tag_id
    const collectionId =
      next.collection_id === undefined ? filters.collection_id : next.collection_id

    router.get(
      "/bookmarks",
      {
        q: (next.q ?? filters.q) || undefined,
        kind: kind === "all" ? undefined : kind,
        tag_id: tagId || undefined,
        collection_id: collectionId || undefined,
      },
      { preserveState: true, preserveScroll: true }
    )
  }

  const submitSearch = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const data = new FormData(event.currentTarget)
    applyFilters({ q: String(data.get("q") ?? "") })
  }

  const hasFilters =
    filters.q.length > 0 ||
    filters.kind !== "all" ||
    filters.tag_id != null ||
    filters.collection_id != null

  return (
    <>
      <Head title="Library">
        <meta
          name="description"
          content="Your Folio library of saved links and visual references."
        />
        <meta property="og:title" content="Library" />
        <meta
          property="og:description"
          content="Your Folio library of saved links and visual references."
        />
      </Head>
      <AppShell wide>
        <PageHeader
          title="Library"
          description="Save links and visuals, then find them by tag, collection, or search."
          actions={
            <>
              <Button asChild variant="secondary">
                <Link href="/bookmarks/new?kind=visual">Add visual</Link>
              </Button>
              <Button asChild>
                <Link href="/bookmarks/new">Save a link</Link>
              </Button>
            </>
          }
        />
        <FlashNotice />
        {errors.base && (
          <p className="mt-4 text-sm text-danger-display">{errors.base}</p>
        )}

        <form onSubmit={submitSearch} className="mt-6 flex flex-col gap-3 sm:flex-row">
          <div className="min-w-0 flex-1">
            <label htmlFor="library-search" className="sr-only">
              Search
            </label>
            <Input
              id="library-search"
              name="q"
              defaultValue={filters.q}
              placeholder="Search title, description, URL, or tags"
            />
          </div>
          <Select
            aria-label="Type"
            value={filters.kind}
            onChange={(event) =>
              applyFilters({ kind: event.target.value as LibraryFilters["kind"] })
            }
          >
            <option value="all">All types</option>
            <option value="link">Links</option>
            <option value="visual">Visuals</option>
          </Select>
          <Button type="submit" variant="secondary">
            Search
          </Button>
        </form>

        {(filters.tag_id || filters.collection_id) && (
          <div className="mt-4 flex flex-wrap items-center gap-2">
            {filters.tag_id && (
              <Button
                type="button"
                variant="soft"
                size="sm"
                onClick={() => applyFilters({ tag_id: null })}
              >
                Tag: {filters.tag_name} ×
              </Button>
            )}
            {filters.collection_id && (
              <Button
                type="button"
                variant="soft"
                size="sm"
                onClick={() => applyFilters({ collection_id: null })}
              >
                Collection: {filters.collection_name} ×
              </Button>
            )}
          </div>
        )}

        {tags.length > 0 && (
          <div className="mt-4 flex flex-wrap gap-2">
            {tags.map((tag) => (
              <Button
                key={tag.id}
                type="button"
                variant={filters.tag_id === tag.id ? "soft" : "ghost"}
                size="sm"
                onClick={() => applyFilters({ tag_id: tag.id })}
              >
                {tag.name}
              </Button>
            ))}
          </div>
        )}

        {bookmarks.length === 0 ? (
          <EmptyState
            title={hasFilters ? "No matches" : "Your library is empty"}
            description={
              hasFilters
                ? "Try a different search or clear filters."
                : "Paste a URL or upload an image to start saving finds."
            }
            action={
              <Button asChild>
                <Link href="/bookmarks/new">Save a link</Link>
              </Button>
            }
          />
        ) : (
          <BookmarkGrid bookmarks={bookmarks} />
        )}

        {collections.length > 0 && !filters.collection_id && (
          <p className="mt-8">
            <Link href="/collections">Browse collections</Link>
          </p>
        )}
      </AppShell>
    </>
  )
}
