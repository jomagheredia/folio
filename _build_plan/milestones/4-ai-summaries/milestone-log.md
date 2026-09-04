# Milestone 4 — Automatic AI summaries

## What's new in the app

- After you save a find, Folio drafts a short **summary** on the bookmark page. You can edit it, Keep it, or Discard it.
- Opening a collection that has items but no summary yet drafts one for you — you do not have to click Summarize first.
- Words you already saved stay put. Automatic drafts never replace a summary you kept or wrote yourself.
- If AI is unavailable, you can still write a summary by hand (or skip it). Saving and organizing are not blocked.

## What was built

- Migration: `bookmarks.summary` (`text`, nullable). Separate from `description` (notes / Describe with AI).
- Service: `BookmarkAi.summarize` — 1–2 sentence overview, same vision path as describe (base64 image when attached and ≤ 4MB). JSON `{"summary":"..."}`.
- Route: `POST /bookmarks/:bookmark_id/ai/summary` (`Bookmarks::AiController#summary`). Collection still uses `POST /collections/:id/ai/summary`.
- Create redirects to `bookmark_path(bookmark, auto_summary: 1)`. The show page fetches a draft once when that query is present and `summary` is blank, then strips the query with `history.replaceState`.
- Bookmark show: Summary section with Summarize (retry / opt-in), draft textarea, Keep / Discard. Edit form has a Summary field (no auto-trigger).
- Collection show: on mount, if `ai_summary` is blank and the set has bookmarks, auto-calls the existing summarize endpoint. Empty collections skip the API. The Summarize button remains.
- Serialization: `bookmark_card_props` includes `summary`.

## Decisions that weren't pre-specified

- Draft-then-Keep, not a background job. Matches milestone 3 and the PRD “keep, edit, or discard” / “edit before it sticks” wording.
- Bookmark auto-generation runs only after create (`?auto_summary=1`), not when opening older bookmarks. A Summarize button stays on the page so Discard / failure is not a dead end.
- Auto never writes to `description`. The PRD “if a description or collection summary already has your text” line is treated as: do not overwrite a saved bookmark `summary` or collection `ai_summary`.
- Collection auto-summary is on show only (not edit). User-initiated Summarize can still replace a saved summary after Keep.
- Library cards and search are unchanged (title / description / URL / tags). Summary lives on the bookmark show/edit pages.

## Anything the next milestone will need to know

- Bookmark share-by-email (milestone 5) should include `description` or `summary` when present. Collection share already includes `ai_summary` after Keep — no mailer change in this milestone.
- `OpenaiClient.fake_chat` / `stub_openai` is still the test seam. Live AI needs `OPENAI_API_KEY`.
- Opening an existing bookmark with an empty summary does not auto-generate; click Summarize or write it on edit.
- Test login: `one@example.com` / `password`. Seeds: `user@test.com` / `test123`.

## Deviations from the PRD

- None for product scope. Background jobs are still unused for generation (same rationale as milestone 3: request/response drafts fit Keep / Discard better than auto-saving a job result).
