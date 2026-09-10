# Deployment

Folio is a **Rails 8 + Inertia.js + PostgreSQL** app with a long-lived Puma process, a Node SSR server, Solid Queue workers, and Active Storage. It needs a host that can run persistent processes and a Postgres database.

## Netlify is not supported

**Do not deploy this app on Netlify.** Netlify hosts static sites and short-lived serverless functions. It cannot run:

- A persistent Rails/Puma server
- PostgreSQL (or Solid Queue / Cache / Cable on Postgres)
- The Inertia SSR Node process (`bin/vite ssr`)
- Background workers (`bin/jobs`)

Connecting a Netlify site to this repo will produce a static publish of source files (or a failed build), not a working Folio install.

**Use Hatchbox** (documented path for this stack): see [`hatchbox-deployment-guide.md`](./hatchbox-deployment-guide.md).

Other hosts that *can* run this architecture: Render, Fly.io, Railway, Heroku, or any VPS with Ruby 3.3.6 + Node 22.12+ + PostgreSQL. Those are not documented here; adapt the Hatchbox checklist (env vars, SSR process, jobs process, R2, Resend).

## Pre-deploy checklist

Before the first production deploy, confirm:

| Item | Status / notes |
| --- | --- |
| `RAILS_MASTER_KEY` | Contents of `config/master.key` (never commit the key). Required to decrypt `config/credentials.yml.enc`. |
| `APP_HOST` | Public origin, e.g. `https://folio.example.com` (sitemap + mailer links). |
| `DATABASE_URL` | Postgres connection string (Hatchbox sets this when you attach a DB). |
| `RESEND_API_KEY` + `MAIL_FROM` | Live share/password emails. `MAIL_FROM` must be on a Resend-verified domain. |
| `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET`, `R2_ENDPOINT` | Cloudflare R2 for uploaded images / previews. Optional `R2_REGION` (default `auto`). Without these, production falls back to local disk (not durable across deploys). |
| `OPENAI_API_KEY` | AI describe / tags / summaries. Optional `OPENAI_MODEL` (default `gpt-4o-mini`). |
| SSR process | `bin/vite ssr` on the web server (see Hatchbox guide). |
| Jobs process | `bin/jobs` on a worker (preferred). Or set `SOLID_QUEUE_IN_PUMA=1` and skip the separate jobs process — do **not** run both. |
| `public/robots.txt` | Update the `Sitemap:` host after you know the real domain. |
| `public/llms.txt` | Replace `https://example.com` with the real origin. |
| Ruby / Node | Ruby `3.3.6` (`.ruby-version`), Node `22.12.0+` (`.nvmrc`). |

## After deploy

1. Hit `/up` — should return 200.
2. View source on the home page — `<div id="app">` should contain HTML (SSR), not be empty.
3. Upload a visual bookmark — file should land in R2, not disappear on the next deploy.
4. Send a share or password-reset email — Resend delivery logs should show success.
5. Trigger an AI action — confirm `OPENAI_API_KEY` is wired.
6. Regenerate the sitemap: `bin/rails sitemap:refresh:no_ping` (or schedule it).
