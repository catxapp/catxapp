# catxapp.com Domain Setup

Complete these steps to host the marketing site at **https://catxapp.com** (required for App Store privacy and support URLs).

## 1. Buy the domain

Register **catxapp.com** at any registrar (Cloudflare, Namecheap, Squarespace, etc.).

## 2. Push the repo and enable GitHub Pages

1. Push this repo to GitHub (see [`website/README.md`](../website/README.md))
2. Repo → **Settings → Pages**
3. Set **Source** to **GitHub Actions**
4. Push to `main` — workflow [`.github/workflows/deploy-website.yml`](../.github/workflows/deploy-website.yml) deploys automatically

Verify the `github.io` URL loads before configuring DNS.

## 3. Configure DNS

**Root domain (`catxapp.com`)** — four **A records**:

| Type | Host | Value |
|------|------|-------|
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |

**WWW** — **CNAME** record:

| Type | Host | Value |
|------|------|-------|
| CNAME | `www` | `catxapp.github.io` |

DNS can take up to 24–48 hours (often under 1 hour).

## 4. Enable custom domain in GitHub

1. Repo → **Settings → Pages**
2. Under **Custom domain**, enter: `catxapp.com`
3. Wait for DNS check, then enable **Enforce HTTPS**

The repo already includes [`website/CNAME`](../website/CNAME) with `catxapp.com`.

## 5. Verify

- [ ] https://catxapp.com loads the homepage
- [ ] https://catxapp.com/privacy.html loads the privacy policy
- [ ] HTTPS padlock shows (no certificate warnings)
- [ ] Waitlist form submits to Google Sheets

## 6. URLs for Apple

| Field | URL |
|-------|-----|
| Privacy Policy URL | `https://catxapp.com/privacy.html` |
| Support URL | `https://catxapp.com/` |

These match [`AppLinks.swift`](../catxapp/Support/AppLinks.swift) in the iOS app.
