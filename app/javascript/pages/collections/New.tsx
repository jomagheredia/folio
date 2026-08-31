import { FormEvent } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import type { PageProps } from "@/types/inertia"

export default function CollectionsNew() {
  const { props } = usePage<PageProps>()
  const errors = props.errors ?? {}
  const form = useForm({ name: "", notes: "" })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.post("/collections")
  }

  return (
    <>
      <Head title="New collection">
        <meta name="description" content="Create a named collection of bookmarks." />
        <meta property="og:title" content="New collection" />
        <meta
          property="og:description"
          content="Create a named collection of bookmarks."
        />
      </Head>
      <AppShell>
        <PageHeader
          title="New collection"
          description="Give the set a name. You can add bookmarks next."
        />
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
          <div className="flex items-center gap-3">
            <Button type="submit" disabled={form.processing}>
              Create collection
            </Button>
            <Button asChild variant="ghost">
              <Link href="/collections">Cancel</Link>
            </Button>
          </div>
        </form>
      </AppShell>
    </>
  )
}
