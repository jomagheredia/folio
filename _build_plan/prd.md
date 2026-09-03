# Folio

> **About these build-plan files:** Everything in `_build_plan/` (this PRD and the per-milestone folders) is a **temporary documentation and guidance artifact** for the initial build-out of this codebase. These files are not functional — no code, configuration, runtime logic, tests, or deployment process should import, read, reference, or depend on anything in `_build_plan/`. Once the initial milestones are built and shipped, the entire `_build_plan/` folder is expected to be deleted from the codebase. Do not treat it as long-living documentation.

## What we're building

Folio is a personal library for links and visual references you want to keep. You save pages from your browser (and images that inspire you), tag them by theme, and search them later. You can share a set of finds with friends or colleagues by email, and use AI to draft descriptions, suggest tags, and summarize a curated collection so organizing and sharing doesn’t become another job.

This is a bookmarking app and an inspiration repository in one: URL bookmarks sit beside image references. The library is yours. Sharing is intentional (email), not a social network. AI is an assistant on save and on collections, not a chat product.

The app is built on the **Build New** starter (Rails 8, Inertia.js, React 19, PostgreSQL). Work is split into three original milestones: a usable personal library, then email sharing, then AI assist. Two later milestones add automatic OpenAI summaries and emailing an individual bookmark.

---

### What the app does

- Save a link by pasting a URL; Folio fills in title, a short snippet, and a preview image when the page provides them.
- Save a visual reference by uploading an image or pasting an image URL; the picture is the card.
- Full **CRUD** on your library: create, view, edit, and delete bookmarks, tags, and collections.
- Tag bookmarks by theme, browse a tag, rename or delete tags.
- Search by title, description, URL, and tag names; filter to links or visuals.
- Group bookmarks into named collections; a bookmark can live in more than one collection.
- Email a collection or a selection of bookmarks to friends or colleagues (no Folio account required to receive).
- See a simple history of who you emailed a collection to and when.
- Ask AI to draft a description and suggest tags on a bookmark, and to summarize a collection for you (and for the share email).
- Get an OpenAI-written summary automatically when you save a find or open a collection that does not have one yet (you can edit or discard it).
- Email a single bookmark from that bookmark’s page.

---

### Already provided by the Build New starter

Do not re-spec or rebuild these:

- Sign up, log in, log out, reset password
- User accounts
- The logged-in app layout
- Profile / settings pages
- Dark mode
- Emails you can preview while building
- Background jobs (for AI and sending email)

---

### External services

These are the only outside vendors for v1. Credentials are obtained by the builder; storage of secrets is an implementation decision.

- **OpenAI** — drafts bookmark descriptions, suggests tags, and summarizes collections. Requires an OpenAI API key. Used in milestone 3, and again in milestone 4 for automatic summaries.
- **Resend** — delivers share emails. Requires a Resend API key, and a verified sending domain when live. Used in milestone 2, and again in milestone 5 for emailing a single bookmark.
- **Cloudflare R2** — stores uploaded images and preview files. Requires a Cloudflare account, R2 bucket, and access keys. Local development may keep files on disk; R2 is what production uses. Needed from milestone 1 (visuals and link previews).

Search stays inside the app. Saving is paste-a-URL (and image upload) on the website; a browser add-on is a later release.

---

### Out of scope

**Product-level cuts (v1):**

- Native iOS/Android apps — use the website on a phone.
- Public profiles / social feed — sharing is email, not a public gallery or follow graph.
- Team workspaces — Folio is one person’s library; colleagues get an email, not a shared account.
- Import from Pocket, Raindrop, or Chrome bookmark folders — start by saving new finds.
- Read-it-later / full page archive — Folio stores the link, preview, and visuals, not a copy of every article for offline reading.
- Payments and plans — one product, no billing.
- Pick-your-AI / bring-your-own API key — one built-in AI (OpenAI).
- Comments on items — no discussion threads on bookmarks.
- **Chrome add-on** (Save this tab / save all tabs in this window) — later release. v1 saves by pasting a URL in the website.

**Feature-level cuts (locked in scoping):**

- Browser extensions of any kind; other browsers (Safari, Firefox, Arc); auto-saving tabs in the background; highlighting or annotating pages.
- Mood boards / freeform canvas; video, PDF, or Figma as their own types; in-app screenshot tools; reverse-image search; crop/filters in Folio.
- Nested tags, tag colors/icons, a global tag dictionary, tag aliases, automatic tag rules.
- Saved searches, boolean search, search inside the full text of original articles, search across other people’s libraries, extra sort modes (newest-first only).
- Nested collections, independent cover images, collaborative editing, public collection URLs, polished drag-and-drop boards.
- Open/click tracking, scheduled send, Slack/iMessage/public-link share, original files as email attachments, recipient comments in Folio.
- Chat with the library, auto-filing into collections, “find similar on the web,” multiple AI write-up alternatives, translation.

---

### Data model

What Folio remembers, in plain language.

#### User

Already in the starter. Email, name, password. Owns every bookmark, tag, collection, and share below.

#### Bookmark

One saved find — a **link** or a **visual**.

- Type — link or visual
- Title — headline (from the page, or a name you give an image)
- URL — the page, if it’s a link (and the image URL when you saved from a link)
- Image — the picture (upload, or a preview of the page)
- Description — notes you write and/or AI drafts
- Summary — a short auto-generated overview (optional, filled in milestone 4; you can edit it)
- Belongs to you
- Can have many tags
- Can sit in many collections

#### Tag

A theme label (e.g. “brutalism”, “recipes”).

- Name
- Belongs to you (your tags, not a global list)
- Many bookmarks can share a tag

#### Collection

A named set you curate.

- Name
- Your notes (optional)
- AI summary (optional, filled when you ask — milestone 3)
- Belongs to you
- Contains many bookmarks

#### Share

A record that you emailed a set of finds.

- Who you sent it to
- Optional short message from you
- Which collection (or which bookmarks)
- The summary (and body copy) that went in the email
- When it was sent

Relationships: every bookmark, tag, collection, and share belongs to one user. Bookmarks and tags are many-to-many. Bookmarks and collections are many-to-many. A share points at a collection and/or a specific set of bookmarks.

---

## Milestone 1 — Library & organize

A signed-in user can run Folio as a personal library: full **CRUD** (create, view, edit, delete) on bookmarks, tags, and collections, plus search. No email or AI yet.

### What gets built

**CRUD (required)**

Every library object in this milestone has create, read, update, and delete. Empty states and confirmation on delete are in scope.

- **Bookmarks (links and visuals)**
  - **Create** — paste a URL, or add a visual (upload or image URL).
  - **Read** — library of cards (newest first); open a bookmark to see its title, URL or image, description, tags, and collections.
  - **Update** — edit title, description, and URL (for links); replace the image (for visuals); change tags and which collections it belongs to.
  - **Delete** — remove the bookmark from the library (it leaves every collection it was in).
- **Tags**
  - **Create** — add a tag by typing a name on a bookmark (autocomplete if it already exists).
  - **Read** — see tags on a bookmark and in a tag list; open a tag to see its bookmarks.
  - **Update** — rename a tag (the new name shows everywhere it was used).
  - **Delete** — remove the tag from the library (bookmarks stay; the label is gone).
- **Collections**
  - **Create** — make a named collection.
  - **Read** — collection page with name, notes, and bookmark cards; library can filter to one collection.
  - **Update** — rename; edit notes; add or remove bookmarks (a bookmark can be in more than one collection).
  - **Delete** — delete the collection (bookmarks stay in the library).

**Save links (website)**

- From the app: paste a URL. Folio fills in title, a short snippet, and a preview image when the page provides them. You can edit the title, then save.
- If that URL is already in your library, Folio tells you and still lets you save a second copy if you want.
- After save, you land on the bookmark (ready for tags; AI comes in milestone 3).

**Visual references**

- Add a visual by uploading an image (png, jpg, webp, gif) from your computer.
- Save an image from a URL (paste a direct image link).
- Each visual shows as a card with the picture prominent.

**Tags & themes**

- Add one or more tags on a bookmark (type a name; if it already exists, it autocomplete-matches).
- Remove a tag from a bookmark without deleting the tag itself.
- Click a tag (on a bookmark or in a tag list) to see all bookmarks with that tag.
- Library can filter to “has this tag.”

**Search**

- A search box in the library.
- Find bookmarks by title, description, URL, and tag names.
- Combine with a simple type filter: all / links / visuals.
- Empty search + a tag filter still works (browse by tag).
- Results are newest-first.

**Collections**

- Create a named collection (e.g. “Spring campaign refs”).
- Add or remove bookmarks from a collection (from the bookmark, or from the collection page).
- A bookmark can live in more than one collection.
- Collection page: name, your notes, the bookmarks as cards. (AI summary slot can exist as empty; filling it is milestone 3.)

### What milestone 1 explicitly does NOT include

- Email sharing or send history
- AI describe, suggest tags, or collection summarize
- Browser add-ons; importing Pocket/Raindrop/Chrome bookmark folders
- Mood boards, extra file types, nested tags, saved/boolean search, public collection URLs, team libraries

### Done when

A signed-in user can create, open, edit, and delete bookmarks (links and visuals), tags, and collections — full CRUD. They can paste a URL, upload an image, search and filter, and file items into collections. Nothing in this milestone depends on OpenAI or Resend.

---

## Milestone 2 — Share

You can send finds to friends or colleagues by email. Recipients do not need a Folio account. You can see that you already sent a collection.

### What gets built

- Share on a collection, and from a selection of bookmarks in the library.
- A short form: one or more recipient emails, optional note from you, subject you can edit.
- Body is pre-filled with titles, links, and thumbnails where we have them. You can edit before send. (Collection AI summary is included when it exists; in this milestone it will usually be empty until milestone 3.)
- One click sends. Recipients get a readable email — no Folio account required.
- You can see past shares on that collection (who, when) so you know you already sent it.

### What milestone 2 explicitly does NOT include

- Open or click tracking
- Scheduled send
- Share via Slack, iMessage, or a public link
- Attaching original image files as email attachments (images appear inline or as links)
- Recipients commenting back inside Folio
- AI-written collection summaries (milestone 3 fills that; share still works without it)
- Browser add-ons

### Done when

A signed-in user can email a collection or a selected set of bookmarks to one or more addresses, the message arrives as a readable email, and the collection shows a simple send history. Sending does not require the recipient to sign up.

---

## Milestone 3 — AI assist

Saving and organizing get an assistant. Share emails can include a collection summary you generated and edited.

### What gets built

- On a bookmark: **Describe with AI** fills the description (you can edit before keeping it). For visuals, it looks at the image; for links, it uses the title, snippet, and preview.
- **Suggest tags** — a short list you tap to add; you can ignore any of them.
- On a collection: **Summarize** writes a short overview of what’s in the set. You can edit it. Share-by-email can include that summary.
- If AI is busy or fails, you still save and tag by hand; nothing is blocked.

### What milestone 3 explicitly does NOT include

- Chat (“what did I save about kitchens?”)
- Auto-adding items to collections
- “Find similar on the web”
- Picking a different AI model or bring-your-own key
- Several alternative write-ups to pick from
- Translating descriptions
- Chrome add-on or any browser extension (later release)
- Full copy of the article for offline reading; highlighting or annotating the page

### Done when

A signed-in user can generate and edit an AI description and suggested tags on a bookmark, generate and edit a collection summary, and include that summary when emailing the collection. Hand-filing still works if AI is unavailable.

---

## Milestone 4 — Automatic AI summaries

Folio uses the OpenAI API to write a first-draft summary for you, so you do not have to start from a blank field. You can still edit or throw the draft away.

This milestone is about **automatic summaries**. On-demand “Describe with AI” and “Suggest tags” stay in milestone 3.

### What gets built

- After you save a bookmark, Folio asks OpenAI for a short summary of the find. For a link it uses the title, snippet, and preview; for a visual it uses the picture. The draft shows up as a summary you can keep, edit, or discard.
- On a collection that does not have a summary yet, Folio can generate one from the items in the set without you having to click Summarize first. You can still edit it before it sticks.
- Automatic drafts never overwrite words you already wrote. If a description or collection summary already has your text, Folio leaves it alone.
- If OpenAI is missing, busy, or fails, saving and organizing still work. Summaries stay empty until you write them yourself.

### What milestone 4 explicitly does NOT include

- Chat (“what did I save about kitchens?”)
- Auto-adding items to collections
- “Find similar on the web”
- Suggesting tags (milestone 3)
- Picking a different AI model or bring-your-own key
- Several alternative summaries to pick from
- Translating summaries
- Chrome add-on or any browser extension

### Done when

A signed-in user can save a bookmark and see an OpenAI-written summary they can edit, and can open a collection that has no summary and get one generated without clicking Summarize. Hand-written notes still work if AI is unavailable.

---

## Milestone 5 — Share a bookmark by email

You can email one bookmark from that bookmark’s page. Recipients do not need a Folio account.

Milestone 2 already covers emailing a collection or a multi-select from the library. This milestone adds sharing **a single bookmark** in place.

### What gets built

- On a bookmark, Share opens a short form: one or more recipient emails, optional note from you, subject you can edit.
- Body is pre-filled with the title, the link or image, and the description or summary when we have one. You can edit before send.
- One click sends. Recipients get a readable email — no Folio account required.
- Each recipient gets their own copy of the email, so they do not see each other’s addresses.

### What milestone 5 explicitly does NOT include

- Open or click tracking
- Scheduled send
- Share via Slack, iMessage, or a public link
- Attaching original image files as email attachments (images appear inline or as links)
- Recipients commenting back inside Folio
- A new send-history page for ad-hoc bookmark shares (collection history stays as milestone 2 specified it)
- Browser add-ons

### Done when

A signed-in user can email one bookmark from that bookmark’s page to one or more addresses, the message arrives as a readable email, and the recipient does not need to sign up.
