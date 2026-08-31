# Milestone 2 — Share

## What's new in the app

- From a **collection**, click Share to email that set of finds.
- From the **library**, check one or more cards and click Share selected.
- A compose page lets you enter recipient emails, edit the subject and body, add an optional note, and drop an item from this send.
- Recipients get a readable email with titles, links, and thumbnails — they do not need a Folio account.
- Each recipient gets their own copy of the email, so they do not see each other’s addresses.
- The collection page shows a simple **send history** (who you emailed and when).

## What was built

- Models: `Share` (user, optional collection, recipients array, note, subject, body snapshot, sent_at) and join table `share_bookmarks`.
- Routes: `GET /shares/new`, `POST /shares` (authenticated). `Disallow: /shares` in `public/robots.txt`. Not in the sitemap.
- `SharesController` pre-fills subject/body from the collection or selected bookmarks. `collection.ai_summary` is included in the pre-filled body when present.
- Mailer: `ShareMailer#share_email` (HTML + text). One `deliver_later` job per recipient. Reply-To is the sender’s Folio email. From address is `MAIL_FROM` (fallback `Folio <from@example.com>`).
- Production/staging: Resend when `RESEND_API_KEY` is set. Development stays on letter opener (`/letter_opener`). Tests use `:test` delivery and the Active Job test adapter.
- Frontend: `app/javascript/pages/shares/New.tsx` compose page; library card checkboxes + Share selected bar; collection Share button + Sent history.
- Thumbnails in email use `rails_blob_url(..., expires_in: 1.year)`.

## Decisions that weren't pre-specified

- Recipients are a PostgreSQL `text[]`, parsed from comma/space/semicolon/newline input, max 20, unique and downcased.
- Ad-hoc library shares store `collection_id` nil and have no separate history page (PRD only requires history on the collection).
- Recipients field is a single-line input (comma-separated), not a textarea — same parse rules still accept pasted lists.
- Dropping an item regenerates subject/body only if the user has not edited those fields.
- Users have no name field; the email identifies the sender in the message and Reply-To.
- Empty remaining items disables Send.

## Anything the next milestone will need to know

- `collections.ai_summary` is already included in `Share.default_body` when present. Milestone 3 can fill that column (and optionally show it on the collection page); share compose will pick it up with no mailer change.
- Share `body` is a snapshot of what was sent. Editing a collection summary later does not change past emails.
- Thumbnail URLs in mail are long-lived blob redirects; they still require the app (or R2) to be reachable.
- Env vars for live send: `RESEND_API_KEY`, `MAIL_FROM` (verified domain), `APP_HOST` (absolute blob URLs in production).
- Test login: `one@example.com` / `password`. Seeds: `user@test.com` / `test123`.

## Deviations from the PRD

- No global shares index; only collection send history, plus a flash after an ad-hoc library send.
- Original files are not attached; images are inline `<img>` links (or omitted when there is no image), matching the PRD cut.
