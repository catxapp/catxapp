# Launch Day

Checklist for when CatXapp status is **Ready for Sale** in App Store Connect.

## 1. Get your App Store URL

App Store Connect → your app → **App Information** → **Apple ID** (numeric).

Your public URL:

```
https://apps.apple.com/app/idYOUR_APPLE_ID
```

## 2. Update the website

Edit [`website/site-config.js`](../website/site-config.js):

```javascript
window.SITE_CONFIG = {
  launched: true,
  appStoreURL: "https://apps.apple.com/app/idYOUR_APPLE_ID"
};
```

Commit and push to `main` — GitHub Pages redeploys automatically.

The homepage will hide the waitlist and show **Download on the App Store**.

## 3. Update the iOS app (next release)

Edit [`catxapp/Support/AppLinks.swift`](../catxapp/Support/AppLinks.swift) — replace the placeholder `appStore` URL with the real link. Ship in v1.0.1 or include before launch if you submit an updated build.

## 4. Email the waitlist

Export emails from your Google Sheet (linked to the waitlist form).

**Subject:** CatXapp is live on the App Store

**Body template:**

```
Hi,

CatXapp is now available for iPhone.

Download: https://apps.apple.com/app/idYOUR_APPLE_ID

• Search 1,500+ catalytic converter codes
• Live PGM-adjusted pricing
• Cart, margin tools, and PDF export
• 14-day free trial, then $7.99/month

https://catxapp.com

Thanks for joining the waitlist!
```

## 5. Marketing

- [ ] Post in yard Facebook groups / industry forums
- [ ] Update business cards and flyers with **catxapp.com**
- [ ] Share App Store link directly for fastest installs

## 6. Monitor first week

| Check | Where |
|-------|-------|
| Crashes | Xcode Organizer → Crashes (after users install) |
| Reviews | App Store Connect → Ratings and Reviews |
| Subscriptions | App Store Connect → Sales and Trends |
| Support | Watch waitlist email / add support@catxapp.com if needed |

## 7. Post-launch maintenance

| Task | When |
|------|------|
| New ACC price list PDFs | Re-run `scripts/extract_catalog.py`, ship app update |
| PGM pricing | Automatic via Kitco in app |
| Bug fixes | TestFlight or direct App Store update |

## Related docs

- [`DOMAIN_SETUP.md`](DOMAIN_SETUP.md)
- [`APP_STORE_CONNECT.md`](APP_STORE_CONNECT.md)
