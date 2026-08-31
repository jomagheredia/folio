import * as React from "react"
import { FormEvent } from "react"
import { Link, useForm, usePage } from "@inertiajs/react"
import { TagInput } from "@/components/TagInput"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Input } from "@/components/ui/input"
import { csrfToken } from "@/lib/csrf"
import { cn } from "@/lib/utils"
import type { BookmarkKind, CollectionOption, TagOption } from "@/types/folio"
import type { PageProps } from "@/types/inertia"

export type BookmarkFormValues = {
  id: number | null
  kind: BookmarkKind
  title: string
  url: string | null
  description: string | null
  image_url: string | null
  tag_names: string[]
  collection_ids: number[]
}

type PreviewResponse = {
  ok: boolean
  error: string | null
  title?: string | null
  description?: string | null
  image_url?: string | null
  duplicate?: boolean
  existing?: { id: number; title: string; path: string } | null
}

export function BookmarkForm({
  bookmark,
  tags,
  collections,
  mode,
}: {
  bookmark: BookmarkFormValues
  tags: TagOption[]
  collections: CollectionOption[]
  mode: "new" | "edit"
}) {
  const { props } = usePage<PageProps>()
  const errors = props.errors ?? {}
  const lockedKind = mode === "edit"

  const form = useForm({
    kind: bookmark.kind,
    title: bookmark.title,
    url: bookmark.url ?? "",
    description: bookmark.description ?? "",
    image: null as File | null,
    preview_image_url: "",
    tag_names: bookmark.tag_names ?? [],
    collection_ids: (bookmark.collection_ids ?? []).map(String),
  })

  const [previewing, setPreviewing] = React.useState(false)
  const [previewError, setPreviewError] = React.useState<string | null>(null)
  const [duplicate, setDuplicate] = React.useState<PreviewResponse["existing"]>(null)
  const [imagePreview, setImagePreview] = React.useState<string | null>(bookmark.image_url)

  React.useEffect(() => {
    if (!form.data.image) return
    const objectUrl = URL.createObjectURL(form.data.image)
    setImagePreview(objectUrl)
    return () => URL.revokeObjectURL(objectUrl)
  }, [form.data.image])

  const setKind = (kind: BookmarkKind) => {
    if (lockedKind) return
    form.setData("kind", kind)
  }

  const fetchPreview = async () => {
    setPreviewError(null)
    setDuplicate(null)
    if (!form.data.url.trim()) {
      setPreviewError("Paste a URL first.")
      return
    }

    setPreviewing(true)
    try {
      const response = await fetch("/bookmarks/preview", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": csrfToken(),
        },
        body: JSON.stringify({ url: form.data.url }),
      })
      const payload = (await response.json()) as PreviewResponse
      if (!payload.ok) {
        setPreviewError(payload.error || "Couldn't fetch a preview.")
        return
      }
      if (payload.title && !form.data.title) form.setData("title", payload.title)
      if (payload.description && !form.data.description) {
        form.setData("description", payload.description)
      }
      if (payload.image_url) {
        form.setData("preview_image_url", payload.image_url)
        setImagePreview(payload.image_url)
      }
      if (payload.duplicate) setDuplicate(payload.existing ?? null)
    } catch {
      setPreviewError("Couldn't fetch a preview. You can still save.")
    } finally {
      setPreviewing(false)
    }
  }

  const submit = (event: FormEvent) => {
    event.preventDefault()
    const options = form.data.image ? { forceFormData: true } : {}
    if (mode === "new") {
      form.post("/bookmarks", options)
    } else {
      form.patch(`/bookmarks/${bookmark.id}`, options)
    }
  }

  const toggleCollection = (id: number, checked: boolean) => {
    const current = form.data.collection_ids
    const key = String(id)
    form.setData(
      "collection_ids",
      checked ? [ ...current, key ] : current.filter((value) => value !== key),
    )
  }

  return (
    <form onSubmit={submit} noValidate className="mt-8 max-w-xl space-y-6">
      <fieldset className="space-y-2">
        <legend>Type</legend>
        <div className="flex gap-2">
          <button
            type="button"
            className={cn("toggle-button", form.data.kind === "link" && "toggle-button-on")}
            aria-pressed={form.data.kind === "link"}
            disabled={lockedKind}
            onClick={() => setKind("link")}
          >
            Link
          </button>
          <button
            type="button"
            className={cn("toggle-button", form.data.kind === "visual" && "toggle-button-on")}
            aria-pressed={form.data.kind === "visual"}
            disabled={lockedKind}
            onClick={() => setKind("visual")}
          >
            Visual
          </button>
        </div>
      </fieldset>

      {form.data.kind === "link" ? (
        <div className="space-y-2">
          <label htmlFor="url">URL</label>
          <div className="flex flex-col gap-2 sm:flex-row">
            <Input
              id="url"
              name="url"
              type="url"
              required
              placeholder="https://"
              value={form.data.url}
              aria-invalid={!!errors.url}
              onChange={(event) => form.setData("url", event.target.value)}
            />
            <Button type="button" variant="secondary" onClick={fetchPreview} disabled={previewing}>
              {previewing ? "Fetching…" : "Fetch preview"}
            </Button>
          </div>
          {errors.url && <p className="text-xs text-danger-display">{errors.url}</p>}
          {previewError && <p className="text-xs text-danger-display">{previewError}</p>}
          {duplicate && (
            <p className="text-sm">
              This URL is already in your library as{" "}
              <Link href={duplicate.path}>{duplicate.title}</Link>. You can still save another copy.
            </p>
          )}
        </div>
      ) : (
        <div className="space-y-4">
          <div className="space-y-2">
            <label htmlFor="image">Image</label>
            <Input
              id="image"
              type="file"
              accept="image/png,image/jpeg,image/webp,image/gif"
              onChange={(event) => form.setData("image", event.target.files?.[0] ?? null)}
            />
            {errors.image && <p className="text-xs text-danger-display">{errors.image}</p>}
          </div>
          <div className="space-y-2">
            <label htmlFor="image-url">Or paste an image URL</label>
            <Input
              id="image-url"
              type="url"
              placeholder="https://"
              value={form.data.preview_image_url}
              onChange={(event) => {
                form.setData("preview_image_url", event.target.value)
                form.setData("url", event.target.value)
                if (event.target.value) setImagePreview(event.target.value)
              }}
            />
          </div>
        </div>
      )}

      {imagePreview && (
        <div className="overflow-hidden rounded-md border border-hairline">
          <img src={imagePreview} alt="" className="max-h-64 w-full object-cover" />
        </div>
      )}

      <div className="space-y-2">
        <label htmlFor="title">Title</label>
        <Input
          id="title"
          name="title"
          value={form.data.title}
          aria-invalid={!!errors.title}
          onChange={(event) => form.setData("title", event.target.value)}
        />
        {errors.title && <p className="text-xs text-danger-display">{errors.title}</p>}
      </div>

      <div className="space-y-2">
        <label htmlFor="description">Description</label>
        <textarea
          id="description"
          className="form-control form-control-textarea"
          value={form.data.description}
          onChange={(event) => form.setData("description", event.target.value)}
        />
        {errors.description && (
          <p className="text-xs text-danger-display">{errors.description}</p>
        )}
      </div>

      <TagInput
        value={form.data.tag_names}
        suggestions={tags}
        onChange={(names) => form.setData("tag_names", names)}
      />

      {collections.length > 0 && (
        <fieldset className="space-y-2">
          <legend>Collections</legend>
          <ul className="space-y-2">
            {collections.map((collection) => (
              <li key={collection.id}>
                <label htmlFor={`collection-${collection.id}`} className="flex items-center gap-2 font-normal text-ink-body">
                  <Checkbox
                    id={`collection-${collection.id}`}
                    checked={form.data.collection_ids.includes(String(collection.id))}
                    onChange={(event) => toggleCollection(collection.id, event.target.checked)}
                  />
                  {collection.name}
                </label>
              </li>
            ))}
          </ul>
        </fieldset>
      )}

      <div className="flex items-center gap-3">
        <Button type="submit" disabled={form.processing} data-testid="save-bookmark">
          {mode === "new" ? "Save" : "Save changes"}
        </Button>
        <Button asChild variant="ghost">
          <Link href={bookmark.id ? `/bookmarks/${bookmark.id}` : "/bookmarks"}>Cancel</Link>
        </Button>
      </div>
    </form>
  )
}
