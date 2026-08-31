import { useState } from "react"
import { Head, Link, router } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { ConfirmDeleteDialog } from "@/components/ConfirmDeleteDialog"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { SuggestedTags } from "@/components/SuggestedTags"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { requestAi } from "@/lib/ai"
import type { BookmarkCardData } from "@/types/folio"

export default function BookmarksShow({ bookmark }: { bookmark: BookmarkCardData }) {
  const [describing, setDescribing] = useState(false)
  const [describeError, setDescribeError] = useState<string | null>(null)
  const [draftDescription, setDraftDescription] = useState<string | null>(null)
  const [keepingDescription, setKeepingDescription] = useState(false)

  const [suggesting, setSuggesting] = useState(false)
  const [suggestError, setSuggestError] = useState<string | null>(null)
  const [suggestedTags, setSuggestedTags] = useState<string[]>([])
  const [addingTag, setAddingTag] = useState(false)

  const tagNames = bookmark.tags.map((tag) => tag.name)

  const describeWithAi = async () => {
    setDescribeError(null)
    setDescribing(true)
    try {
      const payload = await requestAi(`/bookmarks/${bookmark.id}/ai/description`)
      if (!payload.ok || !payload.description) {
        setDescribeError(payload.error || "Couldn't draft a description.")
        return
      }
      setDraftDescription(payload.description)
    } finally {
      setDescribing(false)
    }
  }

  const keepDescription = () => {
    if (draftDescription == null) return
    setKeepingDescription(true)
    router.patch(
      `/bookmarks/${bookmark.id}`,
      { description: draftDescription },
      {
        preserveScroll: true,
        onFinish: () => {
          setKeepingDescription(false)
          setDraftDescription(null)
        },
      },
    )
  }

  const discardDescription = () => {
    setDraftDescription(null)
    setDescribeError(null)
  }

  const suggestTagsWithAi = async () => {
    setSuggestError(null)
    setSuggesting(true)
    try {
      const payload = await requestAi(`/bookmarks/${bookmark.id}/ai/tags`)
      if (!payload.ok || !payload.tags?.length) {
        setSuggestError(payload.error || "Couldn't suggest tags.")
        return
      }
      const selected = tagNames.map((name) => name.toLowerCase())
      setSuggestedTags(payload.tags.filter((name) => !selected.includes(name.toLowerCase())))
    } finally {
      setSuggesting(false)
    }
  }

  const addSuggestedTag = (name: string) => {
    if (tagNames.some((existing) => existing.toLowerCase() === name.toLowerCase())) {
      setSuggestedTags((current) => current.filter((tag) => tag.toLowerCase() !== name.toLowerCase()))
      return
    }
    setAddingTag(true)
    router.patch(
      `/bookmarks/${bookmark.id}`,
      { tag_names: [ ...tagNames, name ] },
      {
        preserveScroll: true,
        onFinish: () => {
          setAddingTag(false)
          setSuggestedTags((current) => current.filter((tag) => tag.toLowerCase() !== name.toLowerCase()))
        },
      },
    )
  }

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
                <Link href={`/bookmarks/${bookmark.id}/edit`} data-testid="edit-bookmark">
                  Edit
                </Link>
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

          <div>
            <h2>Description</h2>
            <div className="mt-2">
              <Button
                type="button"
                variant="secondary"
                size="sm"
                onClick={describeWithAi}
                disabled={describing}
                data-testid="describe-with-ai"
              >
                {describing ? "Describing…" : "Describe with AI"}
              </Button>
            </div>
            {draftDescription != null ? (
              <div className="mt-2 space-y-3">
                <textarea
                  id="ai-description-draft"
                  className="form-control form-control-textarea"
                  value={draftDescription}
                  onChange={(event) => setDraftDescription(event.target.value)}
                />
                <div className="flex items-center gap-3">
                  <Button
                    type="button"
                    size="sm"
                    onClick={keepDescription}
                    disabled={keepingDescription}
                    data-testid="keep-description"
                  >
                    Keep description
                  </Button>
                  <Button type="button" variant="ghost" size="sm" onClick={discardDescription}>
                    Discard
                  </Button>
                </div>
              </div>
            ) : bookmark.description ? (
              <p className="mt-2">{bookmark.description}</p>
            ) : (
              <p className="mt-2">No description yet. Draft one with AI, or add it on the edit page.</p>
            )}
            {describeError && <p className="mt-2 text-xs text-danger-display">{describeError}</p>}
          </div>

          <div>
            <h2>Tags</h2>
            <div className="mt-2">
              <Button
                type="button"
                variant="secondary"
                size="sm"
                onClick={suggestTagsWithAi}
                disabled={suggesting}
                data-testid="suggest-tags"
              >
                {suggesting ? "Suggesting…" : "Suggest tags"}
              </Button>
            </div>
            {bookmark.tags.length === 0 ? (
              <p className="mt-2">No tags yet. Tap a suggestion or add some on the edit page.</p>
            ) : (
              <div className="mt-2 flex flex-wrap gap-2">
                {bookmark.tags.map((tag) => (
                  <Link key={tag.id} href={`/tags/${tag.id}`} className="no-underline">
                    <Badge tone="accent">{tag.name}</Badge>
                  </Link>
                ))}
              </div>
            )}
            {suggestError && <p className="mt-2 text-xs text-danger-display">{suggestError}</p>}
            <SuggestedTags tags={suggestedTags} onAdd={addSuggestedTag} disabled={addingTag} />
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
