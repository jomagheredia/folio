import { FormEvent } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { FlashNotice } from "@/components/FlashNotice"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import type { CollectionOption } from "@/types/folio"
import type { PageProps } from "@/types/inertia"

export default function CollectionsEdit({ collection }: { collection: CollectionOption }) {
  const { props } = usePage<PageProps>()
  const errors = props.errors ?? {}
  const form = useForm({ name: collection.name, notes: collection.notes ?? "" })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.patch(`/collections/${collection.id}`)
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
        <PageHeader title="Edit collection" description="Name and notes only. Bookmarks are managed on the collection page." />
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
