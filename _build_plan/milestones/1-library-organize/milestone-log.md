# Milestone 1 — Library & organize

## What's new in the app

- After you sign in, you land in your **library** — a card grid of saved finds, newest first.
- **Save a link** by pasting a URL. Folio can fetch the title, a short snippet, and a preview image when the page provides them. You can edit the title before saving.
- If that URL is already in your library, Folio tells you and still lets you save a second copy.
- **Add a visual** by uploading a PNG, JPG, WebP, or GIF, or by pasting a direct image URL. The picture is the card.
- Open any bookmark to see its title, URL or image, description, tags, and collections. Edit or delete it (delete asks for confirmation).
- **Tag** bookmarks by typing a name (existing tags autocomplete). Click a tag to see everything with that label. Rename or delete a tag without deleting the bookmarks.
- **Search** the library by title, description, URL, or tag names, and filter to links or visuals.
- **Collections** group finds into named sets (a bookmark can live in more than one). Add or remove bookmarks from the collection page or from the bookmark itself.

## What was built

- Models: `Bookmark` (link/visual), `Tag`, `Collection`, join tables `bookmark_tags` and `collection_bookmarks`, Active Storage attachment `bookmark.image`.
- `collections.ai_summary` column exists and is unused in the UI (milestone 3).
- Routes: `resources :bookmarks` (plus `POST /bookmarks/preview`), `resources :tags` (index/show/update/destroy), `resources :collections` (including add/remove bookmark member actions).
- Signed-in home is the library. `/dashboard` redirects there. Login/signup and `/` (when authenticated) go to `/bookmarks`.
- Services: `SafeHttp` (SSRF-guarded fetch), `BookmarkUnfurl`, `BookmarkImageAttacher`.
- Storage: disk in development/test; production/staging use Cloudflare R2 when `R2_*` env vars are present, otherwise disk.
- Frontend pages under `app/javascript/pages/bookmarks|tags|collections`, plus `BookmarkCard`, `BookmarkGrid`, `TagInput`, `BookmarkForm`, `ConfirmDeleteDialog`.
- Nav brand is Folio: Library, Tags, Collections.

## Decisions that weren't pre-specified

- Bookmark STI `type` avoided; used enum `kind` (`link` / `visual`).
- Tags are created only by typing on a bookmark (no standalone new-tag page).
- AI summary column is on `collections` but not shown in the UI, so the slot does not look like a dead control.
- URL preview is a JSON `fetch` endpoint (`POST /bookmarks/preview`), not an Inertia visit.
- Preview images and image-URL visuals are downloaded on save and stored in Active Storage (not hotlinked).
- Tag uniqueness is per-user and case-insensitive.
- Library layout uses a wider `AppShell` (`wide`); profile/settings stay at `max-w-4xl`.
- Folio-specific components rather than new design-system sections; composed from existing tokens/primitives.

## Anything the next milestone will need to know

- Share is not modeled yet. Add a `Share` model in milestone 2; collections already have `ai_summary` for milestone 3.
- Bookmark cards pass `image_url` as a Rails blob path. Share emails will need absolute URLs for thumbnails.
- Preview/unfurl is `SafeHttp` + `BookmarkUnfurl`. Reuse `SafeHttp` if share or AI needs to fetch remote images.
- R2 is env-driven (`R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET`, `R2_ENDPOINT`, `R2_REGION`). No credentials are required for local/dev.
- Inertia mutations always redirect (never `head :ok`). The preview endpoint is the JSON exception because the client calls it with `fetch`.
- Test login: fixture user `one@example.com` / `password`. Seeds: `user@test.com` / `test123`.

## Deviations from the PRD

- No standalone “new tag” screen; create is in-context on the bookmark form, which matches the PRD create path.
- AI summary is stored but not rendered, so users do not see an empty AI control before milestone 3.
