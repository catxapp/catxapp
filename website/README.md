# catXapp marketing site

Single-page landing site for pre-launch marketing. Visitors join a waitlist; signups land in your linked **Google Sheet** with email notifications.

**Production URLs (custom domain):**

| Page | URL |
|------|-----|
| Homepage | `https://catxapp.com/` |
| Support | `https://catxapp.com/support.html` |
| Privacy policy | `https://catxapp.com/privacy.html` |

Setup: see [`docs/DOMAIN_SETUP.md`](../docs/DOMAIN_SETUP.md). The repo includes [`CNAME`](CNAME) for GitHub Pages.

| Page | Purpose |
|------|---------|
| `index.html` | Hero, features, waitlist form (or App Store CTA after launch) |
| `support.html` | Contact / support form |
| `privacy.html` | Privacy policy (required for App Store + form compliance) |
| `site-config.js` | Set `launched: true` and App Store URL on launch day; set `metaPixelId` for Facebook ads |

The waitlist uses a **native HTML form** that submits to Google Forms — no iframe, no inner scroll bar.

---

## Local preview

From the repo root:

```bash
cd website && python3 -m http.server 8080
```

Open http://localhost:8080

Or open `index.html` directly in a browser (form submit still works).

---

## Deploy to GitHub Pages

### Step 1 — Push the repo to GitHub

If you have not created a GitHub repo yet:

1. Go to [github.com/new](https://github.com/new)
2. Name it `catxapp` (or any name you prefer)
3. Leave it empty — do **not** add a README (this repo already has one)
4. Create the repository

Then, from your Mac in the project folder:

```bash
cd /path/to/catxapp
git add .
git commit -m "Initial commit — CatXapp app and marketing site"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/catxapp.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username.

### Step 2 — Enable GitHub Pages

GitHub only offers `/ (root)` or `/docs` for branch deploy, so this repo uses **GitHub Actions** to publish the `website/` folder.

1. Open your repo on GitHub
2. **Settings → Pages**
3. Under **Build and deployment**, set **Source** to **GitHub Actions** (not “Deploy from a branch”)
4. Push to `main` — the workflow in `.github/workflows/deploy-website.yml` runs automatically

On first setup, you may need to allow GitHub Actions in **Settings → Actions → General** (Workflow permissions: read and write).

GitHub builds the site in 1–3 minutes. Your live URL will be:

```
https://YOUR_USERNAME.github.io/catxapp/
```

### Step 3 — Verify

- Homepage: `https://YOUR_USERNAME.github.io/catxapp/`
- Privacy: `https://YOUR_USERNAME.github.io/catxapp/privacy.html`
- Submit a test email on the waitlist and confirm it appears in your Google Sheet

### Step 4 — Use these URLs in App Store Connect

| Field | URL |
|-------|-----|
| Privacy Policy URL | `https://catxapp.com/privacy.html` |
| Support URL | `https://catxapp.com/support.html` |

(Fallback before DNS propagates: `https://YOUR_USERNAME.github.io/catxapp/privacy.html`)

Update the iOS app links in [`catxapp/Support/AppLinks.swift`](../catxapp/Support/AppLinks.swift) — already points to catxapp.com.

---

## Custom domain — catxapp.com

**Primary setup guide:** [`docs/DOMAIN_SETUP.md`](../docs/DOMAIN_SETUP.md)

GitHub Pages supports a custom domain at no extra cost. Plan on using **catxapp.com** as the root and optionally **www.catxapp.com**.

### 1. Buy the domain

Register `catxapp.com` at any registrar (Namecheap, Google Domains / Squarespace, Cloudflare, etc.).

### 2. Add the domain in GitHub

1. Repo → **Settings → Pages**
2. Under **Custom domain**, enter: `catxapp.com`
3. Check **Enforce HTTPS** (available after DNS propagates, usually within an hour)

GitHub may create a `CNAME` file in the repo automatically. This repo already includes `.nojekyll` so Pages serves static files correctly.

### 3. Configure DNS at your registrar

**Root domain (`catxapp.com`)** — add **A records** pointing to GitHub Pages:

| Type | Host | Value |
|------|------|-------|
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |

**WWW subdomain** — add a **CNAME**:

| Type | Host | Value |
|------|------|-------|
| CNAME | `www` | `catxapp.github.io` |

Some registrars use `@` for root; others use a blank host field. DNS can take up to 24–48 hours to propagate (often much faster).

### 4. Update App Store and app links

After `https://catxapp.com` works with HTTPS:

| Field | URL |
|-------|-----|
| Privacy Policy URL | `https://catxapp.com/privacy.html` |
| Support URL | `https://catxapp.com/support.html` |

Use `catxapp.com` in marketing (business cards, Facebook, yard groups) instead of the `github.io` URL.

---

## Waitlist / Google Form

Signups POST to your existing Google Form backend. Responses appear in the linked **Google Sheet**.

**Form (for editing questions):**  
https://docs.google.com/forms/d/e/1FAIpQLSfI0OS_uDrd1K1CpHlz83-EJoM_IIAD23ULeW18U475o3DOcg/viewform

**In the Google Form → Responses tab:**

- Link to **Google Sheets** (if not already)
- Turn on **email notifications** for new responses

If you add or rename fields in Google Forms, the HTML form in `index.html` must be updated with the new `entry.XXXXXXXX` field IDs.

---

## Support / Google Form

The support page (`support.html`) uses the same **Google Forms → Sheet → email** pattern as the waitlist. Submissions land in a Google Sheet; you get notified by email.

### 1. Create the form

1. Go to [Google Forms](https://forms.google.com) → **Blank form**
2. Title: **catXapp Support**
3. Add these questions (short answer unless noted):
   - **Name** (required)
   - **Email** (required)
   - **Phone number** (optional)
   - **Message** (required — Paragraph)

### 2. Link to Google Sheets

1. Open the form → **Responses** tab
2. Click the green **Sheets** icon → **Create a new spreadsheet**
3. In the form **Responses** menu (⋮) → turn on **Get email notifications for new responses**

You can also add a Google Sheets notification rule: **Tools → Notification rules → A user submits a form → Email - daily digest** or immediate.

### 3. Get the form POST URL and field IDs

1. In the form, click **Send** → link icon → copy the share URL  
   Example: `https://docs.google.com/forms/d/e/1FAIpQLSc.../viewform`
2. Change `viewform` to **`formResponse`** — that is your `action` URL.
3. Find each field’s `entry.XXXXXXXX` ID:
   - Open the form in Chrome → **Preview**
   - Right-click a field → **Inspect** → search the HTML for `entry.`
   - Or submit a test response, open the linked Sheet, and check column headers (sometimes shows entry IDs)

### 4. Update `site-config.js`

```javascript
supportForm: {
  action: "https://docs.google.com/forms/d/e/YOUR_FORM_ID/formResponse",
  fields: {
    name: "entry.111111111",
    email: "entry.222222222",
    phone: "entry.333333333",
    message: "entry.444444444"
  }
}
```

Push to `main` — the form appears on `https://catxapp.com/support.html`.

### 5. App Store Connect

Set **Support URL** to `https://catxapp.com/support.html` (matches [`AppLinks.swift`](../catxapp/Support/AppLinks.swift)).

---

## Meta Pixel (Facebook ads)

When running paid waitlist campaigns, set your Pixel ID in `site-config.js`:

```javascript
metaPixelId: "YOUR_PIXEL_ID"
```

The homepage loads the Pixel only when this value is set, and fires a **Lead** event on successful waitlist signup. Full setup: [`docs/FACEBOOK_ADS.md`](../docs/FACEBOOK_ADS.md).

Ad creative templates: [`marketing/`](marketing/) (1080×1080 and 1200×628 HTML files to export as PNG).

---

## Editing the site

| File | What to change |
|------|----------------|
| `index.html` | Copy, pricing, form success message |
| `styles.css` | Colors, spacing, typography |
| `privacy.html` | Legal text, contact email |
| `assets/logo.png` | App logo (also used on splash) |

After edits, commit and push to `main` — GitHub Pages redeploys automatically.

---

## Folder contents

```
website/
├── index.html          # Landing page + waitlist
├── support.html        # Contact / support form
├── privacy.html        # Privacy policy
├── styles.css          # Shared styles (dark theme)
├── site-config.js      # Launch toggle + Meta Pixel ID
├── assets/logo.png     # App icon / logo
├── marketing/          # Facebook ad templates + PNG exports
├── .nojekyll           # Tells GitHub Pages not to use Jekyll
└── README.md           # This file
```
