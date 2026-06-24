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

Try CatXapp free for 14 days. After your trial, subscribe to keep unlimited access.

Prices are estimates based on catalog data and live metal markets. Always verify before buying.
```

### Keywords (100 chars max, comma-separated)

```
catalytic,converter,PGM,scrap,recycling,platinum,palladium,catalyst,prices,yard
```

### Support URL

```
https://catxapp.com/
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
CatXapp offers a 14-day free trial on device (no payment required). After 14 days, a subscription paywall appears.

To test expired trial on a debug build: Settings → Debug → Access → Trial Ended.

To test purchase: use Sandbox account configured on device. Products: quantumficial.catxapp.monthly ($7.99) and quantumficial.catxapp.annual ($69.99).

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
