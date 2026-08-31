import { Badge } from "@/components/ui/badge"

export function SuggestedTags({
  tags,
  onAdd,
  disabled,
}: {
  tags: string[]
  onAdd: (name: string) => void
  disabled?: boolean
}) {
  if (tags.length === 0) return null

  return (
    <div className="mt-2">
      <p>Suggested tags — tap to add, or ignore.</p>
      <div className="mt-2 flex flex-wrap gap-2">
        {tags.map((name) => (
          <button
            key={name}
            type="button"
            className="cursor-pointer"
            disabled={disabled}
            data-testid={`suggested-tag-${name}`}
            onClick={() => onAdd(name)}
          >
            <Badge tone="muted">{name}</Badge>
          </button>
        ))}
      </div>
    </div>
  )
}
