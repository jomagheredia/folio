export type BookmarkKind = "link" | "visual"

export type TagOption = {
  id: number
  name: string
  bookmarks_count?: number
}

export type CollectionOption = {
  id: number
  name: string
  notes?: string | null
  bookmarks_count?: number
}

export type BookmarkCardData = {
  id: number
  kind: BookmarkKind
  title: string
  url: string | null
  description: string | null
  image_url: string | null
  tags: TagOption[]
  collections: { id: number; name: string }[]
  created_at: string
  tag_names?: string[]
  collection_ids?: number[]
}

export type LibraryFilters = {
  q: string
  kind: "all" | BookmarkKind
  tag_id: number | null
  tag_name: string | null
  collection_id: number | null
  collection_name: string | null
}

export type ShareHistoryItem = {
  id: number
  recipients: string[]
  subject: string
  sent_at: string
  sent_at_label: string
}

export type ShareCollection = {
  id: number
  name: string
  ai_summary?: string | null
}
