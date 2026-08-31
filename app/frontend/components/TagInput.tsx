import * as React from "react"
import { X } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import type { TagOption } from "@/types/folio"

export function TagInput({
  value,
  suggestions,
  onChange,
}: {
  value: string[]
  suggestions: TagOption[]
  onChange: (names: string[]) => void
}) {
  const [draft, setDraft] = React.useState("")
  const [open, setOpen] = React.useState(false)

  const selected = value.map((name) => name.trim()).filter(Boolean)
  const query = draft.trim().toLowerCase()
  const matches = suggestions
    .filter((tag) => !selected.some((name) => name.toLowerCase() === tag.name.toLowerCase()))
    .filter((tag) => (query ? tag.name.toLowerCase().includes(query) : true))
    .slice(0, 8)

  const add = (name: string) => {
    const next = name.trim()
    if (!next) return
    if (selected.some((existing) => existing.toLowerCase() === next.toLowerCase())) {
      setDraft("")
      return
    }
    onChange([ ...selected, next ])
    setDraft("")
    setOpen(false)
  }

  const remove = (name: string) => {
    onChange(selected.filter((existing) => existing.toLowerCase() !== name.toLowerCase()))
  }

  return (
    <div>
      <label htmlFor="tag-input">Tags</label>
      <div className="mt-2 flex flex-wrap gap-2">
        {selected.map((name) => (
          <Badge key={name} tone="accent">
            {name}
            <button
              type="button"
              className="inline-flex cursor-pointer items-center"
              onClick={() => remove(name)}
              aria-label={`Remove ${name}`}
            >
              <X className="h-3 w-3" />
            </button>
          </Badge>
        ))}
      </div>
      <div className="relative mt-2">
        <Input
          id="tag-input"
          value={draft}
          placeholder="Type a tag and press Enter"
          autoComplete="off"
          onChange={(event) => {
            setDraft(event.target.value)
            setOpen(true)
          }}
          onFocus={() => setOpen(true)}
          onBlur={() => {
            window.setTimeout(() => setOpen(false), 120)
          }}
          onKeyDown={(event) => {
            if (event.key === "Enter") {
              event.preventDefault()
              if (matches[0] && query && matches[0].name.toLowerCase().startsWith(query)) {
                add(matches[0].name)
              } else {
                add(draft)
              }
            } else if (event.key === "Backspace" && draft === "" && selected.length > 0) {
              remove(selected[selected.length - 1])
            }
          }}
        />
        {open && (matches.length > 0 || query) && (
          <ul className="absolute z-20 mt-1 w-full overflow-hidden rounded-md border border-hairline bg-page shadow-sm">
            {matches.map((tag) => (
              <li key={tag.id}>
                <button
                  type="button"
                  className="flex w-full cursor-pointer px-3 py-2 text-left text-sm text-ink-body hover:bg-surface"
                  onMouseDown={(event) => event.preventDefault()}
                  onClick={() => add(tag.name)}
                >
                  {tag.name}
                </button>
              </li>
            ))}
            {query && !suggestions.some((tag) => tag.name.toLowerCase() === query) && (
              <li>
                <button
                  type="button"
                  className="flex w-full cursor-pointer px-3 py-2 text-left text-sm text-ink-body hover:bg-surface"
                  onMouseDown={(event) => event.preventDefault()}
                  onClick={() => add(draft)}
                >
                  Create “{draft.trim()}”
                </button>
              </li>
            )}
          </ul>
        )}
      </div>
    </div>
  )
}
