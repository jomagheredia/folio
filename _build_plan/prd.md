# Folium

> **About these build-plan files:** Everything in `_build_plan/` (this PRD and the per-milestone folders) is a **temporary documentation and guidance artifact** for the initial build-out of this codebase. These files are not functional — no code, configuration, runtime logic, tests, or deployment process should import, read, reference, or depend on anything in `_build_plan/`. Once the initial milestones are built and shipped, the entire `_build_plan/` folder is expected to be deleted from the codebase. Do not treat it as long-living documentation.

## What we're building

Folium is a personal library for links and visual references you want to keep. You save pages from your browser (and images that inspire you), tag them by theme, and search them later. You can share a set of finds with friends or colleagues by email, and use AI to draft descriptions, suggest tags, and summarize a curated collection so organizing and sharing doesn’t become another job.

This is a bookmarking app and an inspiration repository in one: URL bookmarks sit beside image references. The library is yours. Sharing is intentional (email), not a social network. AI is an assistant on save and on collections, not a chat product.

The app is built on the **Build New** starter (Rails 8, Inertia.js, React 19, PostgreSQL). Work is split into three milestones: a usable personal library, then email sharing, then AI plus a Chrome add-on to grab open tabs.

---

### What the app does

- Save a link by pasting a URL; Folium fills in title, a short snippet, and a preview image when the page provides them.
- Save a visual reference by uploading an image or pasting an image URL; the picture is the card.
- Grab open Chrome tabs later via a small add-on (this tab, or all tabs in the window).
- Tag bookmarks by theme, browse a tag, rename or delete tags.
- Search by title, description, URL, and tag names; filter to links or visuals.
- Group bookmarks into named collections; a bookmark can live in more than one collection.
- Email a collection or a selection of bookmarks to friends or colleagues (no Folium account required to receive).
- See a simple history of who you emailed a collection to and when.
- Ask AI to draft a description and suggest tags on a bookmark, and to summarize a collection for you (and for the share email).

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

- **OpenAI** — drafts bookmark descriptions, suggests tags, and summarizes collections. Requires an OpenAI API key. Used in milestone 3.
- **Resend** — delivers share emails. Requires a Resend API key, and a verified sending domain when live. Used in milestone 2.
- **Cloudflare R2** — stores uploaded images and preview files. Requires a Cloudflare account, R2 bucket, and access keys. Local development may keep files on disk; R2 is what production uses. Needed from milestone 1 (visuals and link previews).

Search stays inside the app. Chrome tab grab is the browser add-on, not a third-party API.

---

### Out of scope

**Product-level cuts (v1):**

- Native iOS/Android apps — use the website on a phone.
- Public profiles / social feed — sharing is email, not a public gallery or follow graph.
- Team workspaces — Folium is one person’s library; colleagues get an email, not a shared account.
- Import from Pocket, Raindrop, or Chrome bookmark folders — start by saving new finds.
- Read-it-later / full page archive — Folium stores the link, preview, and visuals, not a copy of every article for offline reading.
- Payments and plans — one product, no billing.
- Pick-your-AI / bring-your-own API key — one built-in AI (OpenAI).
- Comments on items — no discussion threads on bookmarks.

**Still in:** a Chrome add-on to save tabs (milestone 3). What stays out is replacing Chrome’s bookmark manager or syncing Chrome bookmark folders.

**Feature-level cuts (locked in scoping):**

- Other browsers (Safari, Firefox, Arc); auto-saving tabs in the background; highlighting or annotating pages.
- Mood boards / freeform canvas; video, PDF, or Figma as their own types; in-extension screenshot button; reverse-image search; crop/filters in Folium.
- Nested tags, tag colors/icons, a global tag dictionary, tag aliases, automatic tag rules.
- Saved searches, boolean search, search inside the full text of original articles, search across other people’s libraries, extra sort modes (newest-first only).
- Nested collections, independent cover images, collaborative editing, public collection URLs, polished drag-and-drop boards.
- Open/click tracking, scheduled send, Slack/iMessage/public-link share, original files as email attachments, recipient comments in Folium.
- Chat with the library, auto-filing into collections, “find similar on the web,” multiple AI write-up alternatives, translation.

---

### Data model

What Folium remembers, in plain language.

#### User

Already in the starter. Email, name, password. Owns every bookmark, tag, collection, and share below.

#### Bookmark

One saved find — a **link** or a **visual**.

- Type — link or visual
- Title — headline (from the page, or a name you give an image)
- URL — the page, if it’s a link (and the image URL when you saved from a link)
- Image — the picture (upload, or a preview of the page)
- Description — notes you write and/or AI drafts
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

A signed-in user can run Folium as a personal library: save links and visuals, tag them, search, and group them into collections. No email, AI, or Chrome add-on yet.

### What gets built

**Save links (website)**

- From the app: paste a URL. Folium fills in title, a short snippet, and a preview image when the page provides them. You can edit the title, then save.
- If that URL is already in your library, Folium tells you and still lets you save a second copy if you want.
- After save, you land on the bookmark (ready for tags; AI comes in milestone 3).
- You can edit title later, or delete the bookmark.
- Library shows bookmarks as cards (newest first).

**Visual references**

- Add a visual by uploading an image (png, jpg, webp, gif) from your computer.
- Save an image from a URL (paste a direct image link).
- Each visual has a title you can edit, optional description, and shows as a card with the picture prominent.
- Tags, collections, and search apply to visuals the same way they apply to links.
- You can replace the image or delete the visual.

**Tags & themes**

- Add one or more tags on a bookmark (type a name; if it already exists, it autocomplete-matches).
- Remove a tag from a bookmark.
- Click a tag (on a bookmark or in a tag list) to see all bookmarks with that tag.
- Library can filter to “has this tag.”
- Rename or delete a tag (delete removes it from bookmarks; it does not delete the bookmarks).

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
- Rename or delete a collection (bookmarks stay in your library).
- Library can filter to one collection.

### What milestone 1 explicitly does NOT include

- Chrome add-on, Save this tab, or Save all tabs
- Email sharing or send history
- AI describe, suggest tags, or collection summarize
- Other browsers; importing Chrome/Pocket/Raindrop bookmarks
- Mood boards, extra file types, nested tags, saved/boolean search, public collection URLs, team libraries

### Done when

A signed-in user can paste a URL and upload an image, see both as cards, tag them, find them with search and tag/type filters, and put them in named collections. Edit and delete work. Nothing in this milestone depends on OpenAI, Resend, or a browser extension.

---

## Milestone 2 — Share

You can send finds to friends or colleagues by email. Recipients do not need a Folium account. You can see that you already sent a collection.

### What gets built

- Share on a collection, and from a selection of bookmarks in the library.
- A short form: one or more recipient emails, optional note from you, subject you can edit.
- Body is pre-filled with titles, links, and thumbnails where we have them. You can edit before send. (Collection AI summary is included when it exists; in this milestone it will usually be empty until milestone 3.)
- One click sends. Recipients get a readable email — no Folium account required.
- You can see past shares on that collection (who, when) so you know you already sent it.

### What milestone 2 explicitly does NOT include

- Open or click tracking
- Scheduled send
- Share via Slack, iMessage, or a public link
- Attaching original image files as email attachments (images appear inline or as links)
- Recipients commenting back inside Folium
- AI-written collection summaries (milestone 3 fills that; share still works without it)
- Chrome add-on

### Done when

A signed-in user can email a collection or a selected set of bookmarks to one or more addresses, the message arrives as a readable email, and the collection shows a simple send history. Sending does not require the recipient to sign up.

---

## Milestone 3 — AI + Chrome

Saving and organizing get an assistant, and Chrome tabs can land in the library without pasting. Share emails can include a collection summary you generated and edited.

### What gets built

**AI assist**

- On a bookmark: **Describe with AI** fills the description (you can edit before keeping it). For visuals, it looks at the image; for links, it uses the title, snippet, and preview.
- **Suggest tags** — a short list you tap to add; you can ignore any of them.
- On a collection: **Summarize** writes a short overview of what’s in the set. You can edit it. Share-by-email can include that summary.
- If AI is busy or fails, you still save and tag by hand; nothing is blocked.

**Chrome add-on**

- A small Chrome add-on with **Save this tab** and **Save all tabs in this window**.
- Each tab becomes a bookmark in the signed-in user’s library (same save path as paste-a-URL: title, snippet, preview when available).
- After save, items show up in the library to review, tag, and file.

### What milestone 3 explicitly does NOT include

- Chat (“what did I save about kitchens?”)
- Auto-adding items to collections
- “Find similar on the web”
- Picking a different AI model or bring-your-own key
- Several alternative write-ups to pick from
- Translating descriptions
- Safari / Firefox / Arc; auto-save tabs in the background; sync with Chrome bookmark folders
- Full copy of the article for offline reading; highlighting or annotating the page

### Done when

A signed-in user can generate and edit an AI description and suggested tags on a bookmark, generate and edit a collection summary, and include that summary when emailing the collection. From Chrome, they can save the current tab or all tabs in the window into the same library. Hand-filing still works if AI is unavailable.
