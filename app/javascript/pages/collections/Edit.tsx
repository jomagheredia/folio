import { FormEvent, useState } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { requestAi } from "@/lib/ai"
import type { CollectionOption } from "@/types/folio"
import type { PageProps } from "@/types/inertia"

export default function CollectionsEdit({ collection }: { collection: CollectionOption }) {
  const { props } = usePage<PageProps>()
  const errors = props.errors ?? {}
  const form = useForm({
    name: collection.name,
    notes: collection.notes ?? "",
    ai_summary: collection.ai_summary ?? "",
  })
  const [summarizing, setSummarizing] = useState(false)
  const [summaryError, setSummaryError] = useState<string | null>(null)

  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.patch(`/collections/${collection.id}`)
  }

  const summarizeWithAi = async () => {
    if (!collection.id) return
    setSummaryError(null)
    setSummarizing(true)
    try {
      const payload = await requestAi(`/collections/${collection.id}/ai/summary`)
      if (!payload.ok || !payload.summary) {
        setSummaryError(payload.error || "Couldn't summarize this collection.")
        return
      }
      form.setData("ai_summary", payload.summary)
    } finally {
      setSummarizing(false)
    }
  }

  return (
    <>
      <Head title={`Edit ${collection.name}`}>
        <meta name="description" content="Rename this collection or edit your notes." />
        <meta property="og:title" content={`Edit ${collection.name}`} />
        <meta
          property="og:description"
          content="Rename this collection or edit your notes."
        />
      </Head>
      <AppShell>
        <PageHeader title="Edit collection" description="Name, notes, and AI summary. Bookmarks are managed on the collection page." />
        <FlashNotice />
        <form onSubmit={submit} className="mt-8 max-w-xl space-y-4">
          <div className="space-y-2">
            <label htmlFor="name">Name</label>
            <Input
              id="name"
              required
              value={form.data.name}
              aria-invalid={!!errors.name}
              onChange={(event) => form.setData("name", event.target.value)}
            />
            {errors.name && <p className="text-xs text-danger-display">{errors.name}</p>}
          </div>
          <div className="space-y-2">
            <label htmlFor="notes">Notes</label>
            <textarea
              id="notes"
              className="form-control form-control-textarea"
              value={form.data.notes}
              onChange={(event) => form.setData("notes", event.target.value)}
            />
          </div>
          <div className="space-y-2">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <label htmlFor="ai_summary">AI summary</label>
              <Button
                type="button"
                variant="secondary"
                size="sm"
                onClick={summarizeWithAi}
                disabled={summarizing}
                data-testid="summarize-collection"
              >
                {summarizing ? "Summarizing…" : "Summarize"}
              </Button>
            </div>
            <textarea
              id="ai_summary"
              className="form-control form-control-textarea"
              value={form.data.ai_summary}
              onChange={(event) => form.setData("ai_summary", event.target.value)}
            />
            {summaryError && <p className="text-xs text-danger-display">{summaryError}</p>}
          </div>
          <div className="flex items-center gap-3">
            <Button type="submit" disabled={form.processing}>
              Save
            </Button>
            <Button asChild variant="ghost">
              <Link href={`/collections/${collection.id}`}>Cancel</Link>
            </Button>
          </div>
        </form>
      </AppShell>
    </>
  )
}
