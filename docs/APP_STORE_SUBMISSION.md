# App Store Submission

Submit the app and subscription metadata together for review.

## Prerequisites

- [ ] TestFlight beta complete with no blockers ([`TESTFLIGHT.md`](TESTFLIGHT.md))
- [ ] Screenshots captured (see below)
- [ ] `https://catxapp.com/privacy.html` live

## Screenshots

**Required:** 6.7" iPhone (1290 × 2796 px)

In Simulator: **iPhone 17 Pro Max** (or largest available) → **⌘S** to save screenshot.

| File | Screen |
|------|--------|
| 01-search.png | Home search with results |
| 02-cart.png | Cart with line items |
| 03-pricing.png | Pricing / margin settings |
| 04-paywall.png | Subscription paywall |

Upload in App Store Connect → your app → **App Store** tab → version → **Screenshots**.

## Metadata template

### Name

```
CatXapp
```

### Subtitle (30 chars max)

```
Converter Price Lookup
```

### Promotional text (optional, 170 chars)

```
Live PGM-adjusted catalytic converter prices. Search 1,500+ codes, build carts, and control your margin. Try free for 14 days.
```

### Description

```
CatXapp is built for scrap yards and catalytic converter buyers who need fast, reliable price lookups in the field.

• Search 1,500+ ACC catalog codes — partial matches work when stamps are hard to read
• Live PGM-adjusted pricing tied to platinum, palladium, and rhodium markets
• Cart tools with gain/loss tracking and PDF export
• Private margin setting so you control your pay price
• Save and recall carts for repeat customers

Try CatXapp Pro free for 14 days through the App Store. After your trial, Pro continues at $13.99/month unless you cancel. Essential lookup-only plans are also available from $7.99/month.

Prices are estimates based on catalog data and live metal markets. Always verify before buying.
```

### Keywords (100 chars max, comma-separated)

```
catalytic,converter,PGM,scrap,recycling,platinum,palladium,catalyst,prices,yard
```

### Support URL

```
https://catxapp.com/support.html
```

### Privacy Policy URL

```
https://catxapp.com/privacy.html
```

### Copyright

```
2026 Quantumficial
```

(Adjust to your legal entity name.)

### Age rating

Complete the questionnaire — expect **4+** (no restricted content).

### App Privacy

- Data not collected (app stores preferences locally on device)
- No tracking

## Review information

**Notes for reviewer:**

```
CatXapp offers Essential ($7.99/mo, $69.99/yr) for unlimited code lookup with live PGM prices, and Pro ($13.99/mo, $119.99/yr) for cart, margin, saved carts, and PDF export. A 14-day free trial is available on Pro monthly via StoreKit introductory offer. Users start the trial through the App Store.

To test without subscribing in a debug build: Settings → Debug → Access → Subscription Required (and set Tier as needed).

To test purchase/trial: use a Sandbox account on device. Products: quantumficial.catxapp.monthly, quantumficial.catxapp.annual, quantumficial.catxapp.pro.monthly, quantumficial.catxapp.pro.annual.

No login required. All data stored locally on device.
```

**Demo account:** Not required (no server login).

**Contact:** Your email and phone for App Review.

## Submit

1. App Store Connect → your app → **App Store** tab
2. Create version **1.0**
3. Select the TestFlight build
4. Fill metadata, screenshots, privacy, age rating
5. Attach subscription products for review
6. **Add for Review** → **Submit to App Review**

Review typically takes 24–48 hours; first submission may take longer.

## If rejected

- Read resolution center message carefully
- Common fixes: clarify trial in review notes, update privacy policy, subscription metadata mismatch
- Fix, bump build number, re-upload, resubmit

## After approval

Proceed to [`LAUNCH_DAY.md`](LAUNCH_DAY.md).
