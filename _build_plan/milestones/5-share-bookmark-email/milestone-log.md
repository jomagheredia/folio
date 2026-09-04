# Milestone 5 — Share a bookmark by email

## What's new in the app

- On a **bookmark**, click Share to email that one find.
- The compose page is pre-filled with the title, the link or image, and the description or summary when those exist. You can edit the subject, body, and an optional note before sending.
- Recipients get a readable email — they do not need a Folio account.
- Each recipient gets their own copy of the email, so they do not see each other’s addresses.

## What was built

- Bookmark show: primary **Share** action (`data-testid="share-bookmark"`) linking to `GET /shares/new?bookmark_id=:id`.
- `SharesController` accepts singular `bookmark_id` in addition to `bookmark_ids` / `collection_id`. Compose cancel and post-send redirect return to that bookmark. Library multi-select and collection share still land on the library / collection.
- Compose (`shares/New`): title is `Share {bookmark title}` for a single non-collection send; **Remove from this email** is hidden when only one item remains. Hidden `bookmark_id` is posted so create knows the source page.
- `Share.default_body` / client `defaultShareBody` include the bookmark `description` and `summary` when present (and not identical).
- Mailer intro is “shared a find” vs “shared finds” based on item count. Still one `deliver_later` per recipient. No new send-history UI.

## Decisions that weren't pre-specified

- Reused the milestone 2 compose page and mailer instead of a nested `/bookmarks/:id/share` resource.
- `bookmark_id` is a source-page flag, not a new share column. Ad-hoc library shares still have `collection_id` nil and no history page.
- Description and summary are both included when both exist, so the email can carry notes and the short overview.
- No bookmark send history (explicit PRD cut).

## Anything the next milestone will need to know

- Collection send history is unchanged. Bookmark-page shares are stored as ad-hoc `Share` rows (`collection_id` nil) with `share_bookmarks`.
- Env vars for live send are still `RESEND_API_KEY`, `MAIL_FROM`, `APP_HOST`.
- Test login: `one@example.com` / `password`. Seeds: `user@test.com` / `test123`.

## Deviations from the PRD

- None for product scope. Sharing still uses the existing compose page rather than a bookmark-only form, which matches the same fields the PRD specifies (recipients, note, editable subject, pre-filled body).
