# Launch Day

Checklist for when CatXapp status is **Ready for Sale** in App Store Connect.

## 1. Get your App Store URL

App Store Connect → your app → **App Information** → **Apple ID** (numeric).

Your public URL:

```
https://apps.apple.com/app/idYOUR_APPLE_ID
```

## 2. Update the website

Post-launch homepage is already live-oriented. Confirm [`website/site-config.js`](../website/site-config.js):

```javascript
window.SITE_CONFIG = {
  launched: true,
  appStoreURL: "https://apps.apple.com/us/app/catxapp/id6784522794",
  metaPixelId: "YOUR_PIXEL_ID"
};
```

Commit and push to `main` — GitHub Pages redeploys automatically.

## 3. Update the iOS app (next release)

[`catxapp/Support/AppLinks.swift`](../catxapp/Support/AppLinks.swift) should use the live App Store URL. Ship in the next app update if not already included.

## 4. Email the waitlist

Export emails from your Google Sheet (linked to the waitlist form).

**Subject:** CatXapp is live on the App Store

**Body template:**

```
Hi,

CatXapp is now available for iPhone.

Download: https://apps.apple.com/us/app/catxapp/id6784522794

• Search 20,000+ catalytic converter codes
• Live PGM-adjusted pricing
• Essential from $7.99/mo — unlimited code lookup & live PGM prices
• Pro from $13.99/mo — cart, margin, saved loads & PDF export
• 14-day free trial on Pro monthly

https://catxapp.com

Thanks for joining the waitlist!
```

## 5. Marketing

- [ ] Post in yard Facebook groups / industry forums
- [ ] Run pre-launch waitlist ads — see [`FACEBOOK_ADS.md`](FACEBOOK_ADS.md)
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
