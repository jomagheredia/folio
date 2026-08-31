import { Link, Head } from "@inertiajs/react"
import { Button } from "@/components/ui/button"

export default function Home() {
  return (
    <>
      <Head title="Folio">
        <meta
          name="description"
          content="Folio is a personal library for links and visual references you want to keep."
        />
        <meta property="og:title" content="Folio" />
        <meta
          property="og:description"
          content="Folio is a personal library for links and visual references you want to keep."
        />
      </Head>
      <main className="mx-auto flex min-h-screen max-w-2xl flex-col items-center justify-center px-4 py-16 text-center">
        <h1>Folio</h1>
        <p className="mt-2 max-w-md">
          A personal library for links and visual references. Save pages, tag them
          by theme, and find them later.
        </p>
        <div className="mt-6 flex items-center gap-3">
          <Button asChild>
            <Link href="/signup">Sign up</Link>
          </Button>
          <Button asChild variant="secondary">
            <Link href="/login">Log in</Link>
          </Button>
        </div>
      </main>
    </>
  )
}
