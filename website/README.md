# catXapp marketing site

Post-launch landing site for **CatXapp** — App Store download CTAs, product sections, SEO, and ad conversion hooks.

**Production URLs:**

| Page | URL |
|------|-----|
| Homepage | `https://catxapp.com/` |
| Support | `https://catxapp.com/support.html` |
| Privacy policy | `https://catxapp.com/privacy.html` |

Setup: see [`docs/DOMAIN_SETUP.md`](../docs/DOMAIN_SETUP.md). Deploy: GitHub Actions publishes `website/` on push to `main`.

| File | Purpose |
|------|---------|
| `index.html` | SEO landing page + App Store CTAs |
| `support.html` | Contact / support form |
| `privacy.html` | Privacy policy |
| `site-config.js` | App Store URL, Meta Pixel, optional Google Ads IDs |
| `robots.txt` / `sitemap.xml` | Crawling |
| `assets/marketing/` | Feature creatives |

---

## Local preview

```bash
cd website && python3 -m http.server 8080
```

Open http://localhost:8080

---

## Launch config

[`site-config.js`](site-config.js):

```javascript
launched: true,
appStoreURL: "https://apps.apple.com/us/app/catxapp/id6784522794",
metaPixelId: "YOUR_PIXEL_ID",
googleAdsId: "",              // e.g. AW-XXXXXXXXX
googleAdsConversionLabel: ""  // from Google Ads conversion action
```

App Store clicks fire Meta `AppStoreClick` / `Contact`. When Google Ads IDs are set, a conversion event fires too.

Suggested UTM for Search ads:

```
https://catxapp.com/?utm_source=google&utm_medium=cpc&utm_campaign=catxapp_search
```

---

## Support / Google Form

See previous setup notes — support form field IDs live in `site-config.js` → `supportForm`.

---

## Editing

| File | What to change |
|------|----------------|
| `index.html` | Copy, sections, FAQ, schema |
| `styles.css` | Layout / theme |
| `assets/marketing/` | Section images |
| `privacy.html` | Legal text |

Commit and push to `main` — GitHub Pages redeploys automatically.
