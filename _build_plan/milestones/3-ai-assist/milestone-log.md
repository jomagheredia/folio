# Milestone 3 — AI assist

## What's new in the app

- On a saved bookmark, **Describe with AI** drafts a description from the title, snippet, and picture. You can edit it, then Keep (or Save on the edit page).
- **Suggest tags** offers a short list of theme labels. Tap to add any of them, or ignore the rest.
- On a collection, **Summarize** writes a short overview of what’s in the set. You can edit it, then Keep.
- That collection summary is included automatically when you email the collection.
- If AI is unavailable or fails, you can still write descriptions, tags, and notes by hand. Nothing is blocked.

## What was built

- Gem: `ruby-openai`. Client: `OpenaiClient` (`OPENAI_API_KEY`, optional `OPENAI_MODEL`, default `gpt-4o-mini`). Tests set `OpenaiClient.fake_chat` so CI never calls the network.
- Services: `BookmarkAi` (describe + suggest tags) and `CollectionAi` (summarize). Visuals and link previews send the image as a base64 `data:` URL (local disk URLs are not reachable by OpenAI). Images over 4MB skip vision and fall back to text. Empty collections do not call the API.
- JSON endpoints (Inertia exception, same pattern as URL preview):
  - `POST /bookmarks/:bookmark_id/ai/description`
  - `POST /bookmarks/:bookmark_id/ai/tags`
  - `POST /collections/:collection_id/ai/summary`
- `collections.ai_summary` is now shown and editable. `CollectionsController` permits it. Share compose already prepends it via `Share.default_body` (no mailer change).
- Bookmark `update` only assigns tags/collections when those params are present, so Keep-description does not wipe tags.
- Frontend: Describe / Suggest tags on bookmark show and edit; Summarize on collection show and edit. Drafts fill a field and are not stored until Keep/Save.
- Hatchbox env docs: `OPENAI_API_KEY`, `OPENAI_MODEL`.

## Decisions that weren't pre-specified

- Generation is synchronous (spinner, then draft). No Solid Queue job — matches “edit before keeping” and the existing Fetch preview pattern.
- AI actions are on saved records only (show + edit), not the new-bookmark form.
- Describe replaces the description field; it is not persisted until Keep/Save.
- Suggested tags prefer the user’s existing tag names when they fit. Already-applied tags are omitted.
- Collection summarize is text-only (titles, snippets, tags), not per-item vision.
- Missing key / timeout / API error all surface as an inline message; the rest of the form stays usable.
- Default model is `gpt-4o-mini` (vision-capable, one model for links and visuals).

## Anything the next milestone will need to know

- There is no milestone 4 in the PRD. This completes the v1 build-plan.
- Live AI needs `OPENAI_API_KEY`. Without it, the buttons still show and return “AI isn't available right now.”
- `OpenaiClient.fake_chat` is the test seam (including system tests, because Capybara’s server thread cannot use `Object.stub`).
- Share body is a snapshot at send time. Editing a collection summary later does not change past emails.
- Test login: `one@example.com` / `password`. Seeds: `user@test.com` / `test123`.

## Deviations from the PRD

- None for product scope. Background jobs are not used for generation (the starter mentioned jobs for AI); request/response drafts fit the locked-in UX better than auto-saving a job result.
